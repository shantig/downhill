# Downhill CAD — current version: v8.1 (2026-11-21)

`cad/src` and `cad/stl` always hold the **current** version only. Superseded files live in [`cad/archive/`](archive/). To see the whole tree exactly as it was at a version, check out its commit (e.g. `git checkout 9b4fd3b` for v7).

| Version | Date | Commit | What it was |
|---|---|---|---|
| **v8.1** | 2026-11-21 | `2017c7e` | **Current.** Exit opens north into the team's cardboard rail box; box mount (zip ties); wire holes |
| v8 | 2026-11-20 | `75b3934` | Open top exit, V-clamp joints, motor arm, coupler v5, printed sorter concept ([archive/v8](archive/v8/)) |
| v7 | 2026-11-20 | `9b4fd3b` | Tower at the foot of the ramp, intake tray, hex lightening (v5/v6 folded in) ([archive/v7](archive/v7/)) |
| v4 | 2026-11-19 | `1de7bc3` | Stiff slots on all pieces, drop-in motor bar, zip-tie collet coupler ([archive/v1-v4](archive/v1-v4/)) |
| v3 | 2026-11-19 | `d6b23cf` | Stiffer lightening slots |
| v2 | 2026-11-13 | `b9c1253` | Level 3 build, lighter, slicer-clean auger |
| v1 | 2026-11-13 | `4a8ca8b` | Auger shell, lean-back frame, N20 top drive |

## Current parts (v8.1)

| File | Part(s) | Status |
|---|---|---|
| `downhill_shell.scad` | shell_lower / middle / upper, sump, wings, pod, clamps, key | v8.1 (upper changed: north-facing exit, wire holes, seat hoop lowered) |
| `downhill_joint.scad` | V-clamp flanges, clamp_a / clamp_b, key | v8 |
| `downhill_crown.scad` | motor_arm, motor_strap | v1 (from v8) |
| `downhill_coupler_v5.scad` | coupler_v5, drill jig | v5 (from v8) |
| `downhill_box_mount.scad` | box_mount_north / south | v1 (new in v8.1) |
| `downhill_frame.scad` | collars, feet (rods 373.4 mm) | v7 parts, v8 rod length |
| `auger.scad` | auger_lower / middle / upper | v5 (unchanged) |
| `downhill_assembly.scad` | full preview | v8.1 |

Re-export everything with `sh export_all.sh` (OpenSCAD 2023+ with the manifold backend).

---

## v8.1 changes (2026-11-21): exit opens north into the team's rail box

- **Shell v8.1:** the open exit arc is re-aimed **north (125–255°)** so objects drop straight into the team's cardboard rail sorter. The backbone now covers 255–485°, so the motor arm (20°) and the pod (+Y) still sit on it. The seat hoop moved down (`seat_drop` 60) so the box-mount band clears the pod bosses. **Reprint `shell_upper` from this version.**
- **`downhill_box_mount.scad` (new):** a 2-half clamp band on the seat hoop, a back plate against the box's short end, a **sloped lip** that closes the curved gap between the round shell and the flat box end, and **side wings**. It holds the box level side-to-side (cancelling the 9° lean) and pitched **8° down toward the north** container.
  - `box_mount_north`: ~45 g PLA. Print upright as exported **with tree supports**. M3×6×5 inserts in its 2 ears.
  - `box_mount_south`: ~10 g. Flat, no supports. 2× M3×12.
- **Zip ties:** 4 tie points on the back plate, each a pair of 5.5 × 3 mm slots 9 mm apart (ties up to 4.8 mm). Punch matching holes in the box end wall at ±38 mm from its centreline, 10 mm and 50 mm below its top edge.
- **Box length sets the ball distance** (far end 30 mm past the near rim): 286 mm → D = 4" (the rule minimum), 337 mm → 6", 389 mm → 8", 491 mm → 12". The current 260 mm box only reaches ~3.4", which is under the 4" minimum.
- **Wire holes:** four 3 mm radial holes 4 mm below the backbone top. 124° and 256° face the ball (north) side, 345° and 40° the dowel (south) side. Use them for the paper chutes' support wires and the box's far-end stay.
- **Boundary check (DBT V4):** the box stays inside the footprint's east-west band (y −218…−96 mm, ramp edge at 0) and overhangs north past the footprint edge, which is allowed with no contact. At D = 4–6" its lowest point over the container opening is 456–463 mm, i.e. 56–63 mm above the Level 3 rim. It's nowhere near the ramp, the floor or the Task 1 boxes. Keep the paper chutes and wires clear of the containers too.
- The v8 printed collector/splitter/chute concept moved to [`archive/v8`](archive/v8/). Its `gate_test` part is still there if you want to test a height gate.

## v8 changes (2026-11-20, still current unless v8.1 says otherwise)

| Feedback | v8 answer | File |
|---|---|---|
| Objects should leave from the top, as fast as possible | The upper shell stops as a full tube **one auger pitch (64 mm) below the auger top**. Above that only the **backbone** rises. On the 40° umbrella flight, objects roll off sideways as soon as nothing holds them in, mostly at the backbone's leading edge. The side ports and spouts are gone. | `downhill_shell.scad` |
| Motor wobbled in the cap | The cap is gone. The N20 hangs off **one stiff box-beam arm**, bolted to the backbone with 2× M3 from outside. The **factory bracket** clamps the gearbox against the arm's T-head (2× M2 heat-set inserts), and a shelf sits under the gearbox face. | `downhill_crown.scad` |
| Make the shells and cap screw together | Better than a thread (it keeps every piece clocked the same way): **45° flanges with a loose clocking key + a 2-piece V clamp**, 2× M3×12 into M3×6×5 inserts per joint. Self-centring, the bore stays smooth across the joint. | `downhill_joint.scad` |
| Coupler: stronger and reusable | **Coupler v5**: taper plug + **M3 cross-screw** (insert in the plug, one 3.4 mm hole drilled through the auger collar with the printed jig) + **M2 set screw** on the D-flat (insert). No zip ties. | `downhill_coupler_v5.scad` |
| Consistent openings that don't trap dowels; shell more rigid | **4 mm hex holes, 2.0 mm webs** everywhere (was 5 mm). A dowel lying across a hole dips 0.5 mm into it (was 1.2 mm, the full wall). **Triangular hoops** every ~21 mm stop the wall bulging out between flights. The underside strip stays solid. | `downhill_shell.scad` |
| Intake | Geometry unchanged from v7. It picks up the new hole pattern, a hoop above the intake window, and **4 mm lightening in the tray floor** (−17 g). | `downhill_shell.scad` |

The auger must turn **CW seen from above** (the lifting direction for this right-hand flight). Container positions follow **Figure 1**: ping-pong box north, dowels box south, both at **Level 3**.

### Key numbers
- Shell 676.2 mm long. Pieces 222.6 / 226 / 225.2 mm. Joints at 225 and 451.
- Exit window bottom: **569–578 mm (22.4–22.8") above the tile**. Backbone top: 686 mm.
- Frame **rod cut length 373.4 mm** (was 359.7).

### Scoring math (one perfect run, all 20 objects)
FoM = Index_W × [100 + 160 + 225·D_ball + 450·D_dowel] (both Level 3, D in inches).
Each inch of dowel distance is worth 450 points, each inch of ball distance 225 (before the weight index).

### Weight budget (v8 estimate, solid volume at 1.24 g/cm³; "other" = auger + electronics + rods, from the measured 860 g)
| Configuration | g | oz | Index |
|---|---|---|---|
| Tower only, PLA | 869 | 30.7 | 0.75 |
| Tower in PLA Aero (×0.6), auger PLA | ~640 | ~22.6 | 1.0 |
| + box mount in Aero (~33 g) + cardboard box (weigh it, likely 40–80 g) | ~715–755 | ~25–26.5 | 0.75 |

Printed tower parts: shells 318 g, clamps 34, sump + wings 124, collars 34, feet 11, pod 18, arm 23, coupler 6. The Aero factor is a guess, so trust the scale. Ways to get under 24 oz: hex-lighten the auger flights at the reprint (≈ −40 g PLA) and weigh the electronics.

## Parts, quantities, hardware (current)
| Part (STL) | Qty | Print | Hardware |
|---|---|---|---|
| shell_lower | 1 | **upside down as exported** (flange face on the bed) | — |
| shell_middle, shell_upper | 1 each | upright as exported | — |
| clamp_a / clamp_b | 2 / 2 | flat as exported | 4× M3×6×5 inserts (clamp_a), 4× M3×12 |
| key | 2 | flat | loose clocking key: drops into the notches in both faces of each joint |
| sump, wing_left, wing_right | 1 each | floor down | 627 bearing |
| pod | 1 | flat | 4× M3×4×5 inserts (shell bosses), 4× M3×10 |
| motor_arm | 1 | **upright as exported**, 100% infill | 2× M2×4×3.2 inserts + 2× M2×6 (bracket), 2× M3×6×5 inserts + 2× M3×8 (to backbone) |
| motor_strap | 0–1 | ears down | only if the factory bracket's hole spacing ≠ 18 mm |
| coupler_v5 | 1 | plug down, 100% | M3×4×5 insert + M3×6; M2×4×3.2 insert + M2×5/×6 (or M2 grub) |
| coupler_v5_drill_jig | 1 | lip down | 2.5 then 3.4 mm drill |
| box_mount_north / _south | 1 / 1 | north upright **with tree supports**; south flat | 2× M3×6×5 + 2× M3×12; 4 zip ties |
| collar_front/back, foot_left/right | 1 each | as before | 2× M3×16 + nuts; rods 373.4 mm |
| auger_lower / middle / upper | 1 each | as before (v5) | — |

Heat-set insert holes: M2 → 3.0 mm, M3 (5.0 OD) → 4.5 mm. Tune these in each file's parameters if your inserts go in too loose or too tight.

## Assembly order (top drive)
1. Drill the auger collar with the jig (once): 2.5 mm, then 3.4 mm, 7 mm below the top face.
2. Heat-set the inserts (coupler, arm, clamps, pod bosses, box mount).
3. Press the coupler into the auger, turn it until the insert shows through the hole (the notch on the flange marks it), M3×6 in.
4. Motor into the arm: gearbox face on the shelf, factory bracket over the gearbox, 2× M2×6.
5. Lower the arm into the backbone, shaft into the coupler (flat toward the M2 insert), 2× M3×8 through the backbone pad, then M2 set screw.

## Still to verify
- **Bracket hole spacing.** `brk_cc = 18.0` is derived from the caliper readings. Measure outer-edge to outer-edge of the two holes, subtract one hole diameter, and set `brk_cc` (or print `motor_strap`).
- **Clamp fit.** Check one clamp pair on the first two shells before the rest.
- **Box length:** at least 286 mm to reach the 4" minimum distance.
