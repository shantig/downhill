#!/usr/bin/env bash
# Re-export every printable STL from the OpenSCAD sources.  Usage: cad/export_all.sh
set -euo pipefail
cd "$(dirname "$0")/src"; out=../stl; mkdir -p "$out"
ex() { echo "  $2"; openscad -q -o "$out/$2.stl" -D "part=\"$3\"" "$1"; }
for p in shell_lower shell_middle shell_upper boot spout_ball spout_dowel pod; do
  grep -q "\"$p\"" downhill_shell.scad && ex downhill_shell.scad "$p" "$p"; done
for p in lower middle upper; do grep -q "\"$p\"" auger.scad && ex auger.scad "auger_$p" "$p"; done
for p in collar_front collar_back foot_left foot_right; do ex downhill_frame.scad "$p" "$p"; done
ex downhill_top_bar.scad motor_bar bar
echo "  coupler_v4"; openscad -q -o "$out/coupler_v4.stl" downhill_coupler_v4.scad
# legacy (superseded): downhill_top_drive.scad motor_mount / coupler
