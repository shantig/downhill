#!/usr/bin/env python3
"""Build and validate a merged ESP32 factory image from PlatformIO metadata."""

from __future__ import annotations

import argparse
import configparser
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys


EXPECTED_OFFSETS = (0x1000, 0x8000, 0xE000, 0x10000)
FLASH_SIZE_BYTES = 4 * 1024 * 1024
FLASH_MODES = {0: "qio", 1: "qout", 2: "dio", 3: "dout"}
FLASH_FREQUENCIES = {0: "40m", 1: "26m", 2: "20m", 0xF: "80m"}
FLASH_SIZES = {0: "1MB", 1: "2MB", 2: "4MB", 3: "8MB", 4: "16MB"}


def fail(message: str) -> None:
    raise SystemExit(f"Factory image validation failed: {message}")


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        fail(f"cannot read {path}: {error}")


def resolve_path(project_dir: Path, value: str) -> Path:
    path = Path(value)
    if not path.is_absolute():
        path = project_dir / path
    return path.resolve()


def read_platformio_settings(project_dir: Path, environment: str) -> tuple[str, str, str, Path]:
    config = configparser.ConfigParser(interpolation=None)
    config_path = project_dir / "platformio.ini"
    if not config.read(config_path, encoding="utf-8"):
        fail(f"cannot read {config_path}")

    section = f"env:{environment}"
    if not config.has_section(section):
        fail(f"missing [{section}] in {config_path}")

    board = config.get(section, "board", fallback="").strip()
    platform = config.get(section, "platform", fallback="").split("@", 1)[0].strip()
    if not board or not platform:
        fail(f"[{section}] must define both board and platform")

    core_dir = Path(os.environ.get("PLATFORMIO_CORE_DIR", Path.home() / ".platformio"))
    board_manifest = core_dir / "platforms" / platform / "boards" / f"{board}.json"
    board_data = load_json(board_manifest)

    try:
        flash_mode = str(board_data["build"]["flash_mode"]).lower()
        flash_hz = int(str(board_data["build"]["f_flash"]).rstrip("Ll"))
        flash_size = str(board_data["upload"]["flash_size"])
    except (KeyError, TypeError, ValueError) as error:
        fail(f"invalid flash settings in {board_manifest}: {error}")

    if flash_hz % 1_000_000:
        fail(f"unsupported non-MHz flash frequency {flash_hz} in {board_manifest}")
    flash_frequency = f"{flash_hz // 1_000_000}m"
    if flash_size.upper() != "4MB":
        fail(f"board manifest declares {flash_size}, expected 4MB")

    return flash_mode, flash_frequency, "4MB", board_manifest.resolve()


def read_image_header(path: Path) -> tuple[str, str, str]:
    header = path.read_bytes()[:4]
    if len(header) != 4 or header[0] != 0xE9:
        fail(f"{path} is not an ESP32 image")

    mode = FLASH_MODES.get(header[2])
    frequency = FLASH_FREQUENCIES.get(header[3] & 0x0F)
    size = FLASH_SIZES.get(header[3] >> 4)
    if not mode or not frequency or not size:
        fail(f"{path} has unsupported flash header 0x{header[2]:02x} 0x{header[3]:02x}")
    return mode, frequency, size


def verify_image(esptool: Path, path: Path) -> None:
    command = [
        sys.executable,
        str(esptool),
        "--chip",
        "esp32",
        "image_info",
        "--version",
        "2",
        str(path),
    ]
    result = subprocess.run(command, capture_output=True, text=True, check=False)
    if result.returncode:
        fail(f"esptool rejected {path}:\n{result.stdout}{result.stderr}")
    checksum_valid = any(
        line.startswith("Checksum:") and line.endswith("(valid)")
        for line in result.stdout.splitlines()
    )
    if not checksum_valid:
        fail(f"esptool did not report a valid checksum for {path}")


def image_layout(project_dir: Path, environment: str) -> list[tuple[int, Path]]:
    build_dir = project_dir / ".pio" / "build" / environment
    idedata_path = build_dir / "idedata.json"
    idedata = load_json(idedata_path)

    try:
        extra_images = idedata["extra"]["flash_images"]
        application_offset = int(idedata["extra"]["application_offset"], 0)
    except (KeyError, TypeError, ValueError) as error:
        fail(f"invalid flash layout in {idedata_path}: {error}")

    layout: list[tuple[int, Path]] = []
    for image in extra_images:
        try:
            offset = int(image["offset"], 0)
            path = resolve_path(project_dir, image["path"])
        except (KeyError, TypeError, ValueError) as error:
            fail(f"invalid image entry in {idedata_path}: {error}")
        layout.append((offset, path))

    layout.append((application_offset, (build_dir / "firmware.bin").resolve()))
    layout.sort(key=lambda item: item[0])

    offsets = tuple(offset for offset, _ in layout)
    if offsets != EXPECTED_OFFSETS:
        expected = ", ".join(hex(offset) for offset in EXPECTED_OFFSETS)
        actual = ", ".join(hex(offset) for offset in offsets)
        fail(f"PlatformIO layout changed; expected [{expected}], found [{actual}]")

    for _, path in layout:
        if not path.is_file() or path.stat().st_size == 0:
            fail(f"missing or empty input image: {path}")

    for (offset, path), (next_offset, _) in zip(layout, layout[1:]):
        if offset + path.stat().st_size > next_offset:
            fail(f"{path} overlaps the image at {hex(next_offset)}")

    final_end = layout[-1][0] + layout[-1][1].stat().st_size
    if final_end > FLASH_SIZE_BYTES:
        fail(f"merged content ends at {hex(final_end)}, beyond the 4 MB flash")

    return layout


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--environment", default="waveshare_general_driver")
    parser.add_argument("--project-dir", type=Path, default=Path.cwd())
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()

    project_dir = args.project_dir.resolve()
    build_dir = project_dir / ".pio" / "build" / args.environment
    output = (args.output or build_dir / "downhill-factory.bin").resolve()
    layout = image_layout(project_dir, args.environment)
    flash_mode, flash_frequency, flash_size, board_manifest = read_platformio_settings(
        project_dir, args.environment
    )

    bootloader = layout[0][1]
    header_settings = read_image_header(bootloader)
    board_settings = (flash_mode, flash_frequency, flash_size)
    if header_settings != board_settings:
        fail(
            "bootloader flash header "
            f"{header_settings} does not match board manifest {board_settings}"
        )

    core_dir = Path(os.environ.get("PLATFORMIO_CORE_DIR", Path.home() / ".platformio"))
    esptool = core_dir / "packages" / "tool-esptoolpy" / "esptool.py"
    if not esptool.is_file():
        fail(f"cannot find PlatformIO esptool at {esptool}")

    verify_image(esptool, bootloader)
    verify_image(esptool, layout[-1][1])

    command = [
        sys.executable,
        str(esptool),
        "--chip",
        "esp32",
        "merge_bin",
        "--output",
        str(output),
        "--format",
        "raw",
        "--target-offset",
        "0x0",
        "--flash_mode",
        flash_mode,
        "--flash_freq",
        flash_frequency,
        "--flash_size",
        flash_size,
    ]
    for offset, path in layout:
        command.extend((hex(offset), str(path)))

    output.parent.mkdir(parents=True, exist_ok=True)
    result = subprocess.run(command, capture_output=True, text=True, check=False)
    if result.returncode:
        fail(f"esptool merge failed:\n{result.stdout}{result.stderr}")

    merged = output.read_bytes()
    if not merged or len(merged) > FLASH_SIZE_BYTES:
        fail(f"merged image size {len(merged)} is outside the 4 MB flash")

    expected_end = max(offset + path.stat().st_size for offset, path in layout)
    if len(merged) != expected_end:
        fail(f"merged image ends at {hex(len(merged))}, expected {hex(expected_end)}")

    previous_end = 0
    for offset, path in layout:
        if any(value != 0xFF for value in merged[previous_end:offset]):
            fail(f"merged padding before {hex(offset)} contains unexpected data")
        payload = path.read_bytes()
        if merged[offset : offset + len(payload)] != payload:
            fail(f"merged payload differs from {path} at {hex(offset)}")
        previous_end = offset + len(payload)

    digest = hashlib.sha256(merged).hexdigest()
    print(f"Board manifest: {board_manifest}")
    print(f"Flash configuration: {flash_mode.upper()}, {flash_frequency}, {flash_size}")
    for offset, path in layout:
        print(f"  {hex(offset):>7}  {path}  ({path.stat().st_size} bytes)")
    print(f"Factory image: {output} ({len(merged)} bytes)")
    print(f"SHA-256: {digest}")


if __name__ == "__main__":
    main()
