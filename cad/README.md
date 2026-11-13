# Downhill — auger shell v1 (leans back 25°)

Sources (all parametric, OpenSCAD):
- `downhill_shell.scad`: shell, boot, spouts, electronics pod (new)
- `downhill_assembly.scad`: full preview (shell + auger + top drive + frame)
- `downhill_frame.scad`: updated to the real shell (OD 117.2, length 396.8). The old pod is turned off.
- `downhill_top_drive.scad`: `shell_od` set to 117.2 (rim_z 10 matches the shell). Re-exported `motor_mount.stl`.
- `auger.scad`: your v4, unchanged (see the flight note below).

## Layout (tube frame: underside = low side of the lean)
| Feature | Where |
|---|---|
| Bore 114, wall 1.6, OD 117.2, length 396.8 | auger sits 5.8–386.8 |
| Ball port (70 × 54, pointed top) | underside, top of shell. Sill ≈ 295 mm (11.6") above floor |
| Dowel slot (70 × 13, follows the helix) | underside, just below. Low end ≈ 266 mm (10.5") above floor |
| Spout pad + 4 M3 pilots | around both openings |
| Electronics pod | upper face, top end 12 mm under the rim. Driver board is at the top |
| Intake window (84 wide, pointed top) | front/upper face, bottom |
| Joint | z = 180, glued sleeve + key (keeps the frame collar on the upper piece) |
| 627 bearing | printed Ø6.95 pin + inner-race shoulder in the floor (`pin_mode="steel"` gives a socket for a 7 mm pin instead) |

N20 lead: motor terminals → driver board top edge is about 95 mm in a straight line, about 130 mm routed over the rim. Mount the board with its motor connector at the top edge.

## Print (Bambu X2D, PLA, 0.4 nozzle, no supports)
| STL | Orientation | Size (mm) | ≈ g |
|---|---|---|---|
| shell_lower | floor down | 122 × 122 × 192 | 117 |
| shell_upper | as exported (sleeve end down) | 117 × 124 × 217 | 137 |
| boot | sole down | 133 × 143 × 58 | 36 |
| spout_ball / spout_dowel | floor down | 98 × 81 × 62 / 98 × 76 × 32 | 29 / 21 |
| pod | flat | 68 × 126 × 3 | 18 |
| motor_mount, coupler | as exported | | 22 / 6 |
| collar_front/back, foot_left/right | as before | | 21 / 14 / 6 / 6 |

- Use 4 walls so the 1.6 mm shell prints solid. The dowel-slot top is a 70 mm bridge, so turn on bridge settings. A little sag there doesn't matter.
- The printed pin usually comes out slightly fat. Sand it until the 627 slides on.

## Hardware
- 4× M3×8 pan-head (spouts → pad), 4× M3×10 (pod → bosses)
- 2× M3×16 + nuts (collar), 2× M3 self-tap (motor cap skirt)
- 8× M2.5×16 standoffs + screws (driver board, ANO), battery strap
- 2× legs, 1/4" dowel: **ROD CUT LENGTH 213.9 mm**
- CA or epoxy for the shell joint (key on +Y lines up the pod and exits)

## Important: auger flight angle
`auger.scad` v4 has `flight_tilt = -40` (cup). At a 25° lean, objects on a 40° cup slide **toward the shaft**, away from the wall, so they never reach the side exits. Set `flight_tilt = 40` (umbrella) and reprint. At the low side the flight then pushes balls and dowels outward onto the wall, where the slot and port are. Pressing objects against the fixed wall may also stop dowels spinning with the screw, which could be why they slipped back at speed. It prints the same.

## Height check (Task 2 box rims: L1 5.25", L2 10.5", L3 15.75")
The exits sit on the low side of the lean, below the auger top, so the spout lips end around **10.5" (balls) and 9.4" (dowels)**. That reaches Level 1 easily. Level 2 needs roughly 3" more height. Every 100 mm added to auger + shell gives about 3.6".
