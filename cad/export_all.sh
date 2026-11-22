#!/bin/sh
# Export every printable part of the CURRENT version (v8.1). Archived versions live in cad/archive/. Needs OpenSCAD 2023+ (manifold backend makes the hex shells fast).
# Usage: sh export_all.sh [openscad-binary]
OS=${1:-openscad}
cd "$(dirname "$0")/src" || exit 1
mkdir -p ../stl
ex() { echo "== $2"; $OS --backend=manifold -D "part=\"$2\"" -o "../stl/$3.stl" "$1"; }
for p in shell_lower shell_middle shell_upper sump wing_right wing_left pod clamp_a clamp_b key; do ex downhill_shell.scad $p $p; done
ex downhill_crown.scad arm motor_arm
ex downhill_crown.scad strap motor_strap
ex downhill_coupler_v5.scad coupler coupler_v5
ex downhill_coupler_v5.scad jig coupler_v5_drill_jig
ex downhill_box_mount.scad mount_north box_mount_north
ex downhill_box_mount.scad mount_south box_mount_south
for p in collar_front collar_back foot_left foot_right; do ex downhill_frame.scad $p $p; done
for p in lower middle upper; do echo "== auger_$p (unchanged v5)"; done
