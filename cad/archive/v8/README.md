# v8 sorter concept (archived 2026-11-21)

Superseded on the tower by the v8.1 box mount and the team's rail box. These are the v8 notes as written, including the sorter parts list. The collector no longer fits the v8.1 shell (the window now faces north and the seat hoop moved). The splitter, `gate_test` and chute layout math still work on their own.

# Downhill — v8 (testing feedback 2026-11-20)

**Current versions:** shell v8 · joint v8 (V-clamp) · motor arm v1 (`downhill_crown.scad`) · coupler v5 · sorter concept v1 · auger v5 (unchanged) · frame (rod length updated).

## What changed and why

| Feedback | v8 answer | File |
|---|---|---|
| Objects should leave from the top, as fast as possible, into a separate sorting hopper | The upper shell stops as a full tube **one auger pitch (64 mm) below the auger top**. Above that only a 145° **backbone** rises; the other **215° is open**. On the 40° umbrella flight, objects roll off sideways as soon as nothing holds them in, mostly at the backbone's leading edge. The side ball port, dowel slot, spout pad and spouts are gone. | `downhill_shell.scad` |
| Motor wobbled in the cap | The cap is gone. The N20 hangs off **one stiff box-beam arm**, bolted to the backbone with 2× M3 from outside. The **factory bracket** clamps the gearbox flat against the arm's T-head (2× M2 heat-set inserts), and a shelf sits under the gearbox face. Nothing crosses the opening. | `downhill_crown.scad` |
| Make the shells and cap screw together | Better than a thread (it keeps every piece clocked the same way): **45° flanges with a loose clocking key + a 2-piece V clamp**, 2× M3×12 into M3×6×5 inserts per joint. Self-centring, the bore stays smooth across the joint, and it comes apart in seconds. The motor arm bolts on, so it doesn't need a joint. | `downhill_joint.scad` |
| Coupler: stronger and reusable | **Coupler v5**: same proven taper plug + **M3 cross-screw** (insert in the plug, one 3.4 mm hole drilled through the auger collar with the printed jig) + **M2 set screw** on the D-flat (insert). No zip ties. | `downhill_coupler_v5.scad` |
| Consistent openings that don't trap dowels; shell more rigid | One pattern everywhere (shells + tray wings): **4 mm hex holes, 2.0 mm webs** (was 5 mm). A dowel lying across a hole now dips 0.5 mm into it (was 1.2 mm, the full wall). **Triangular hoops** every ~21 mm (3 per flight pitch, 45° both sides, no supports) stop the wall bulging out between flights. The underside strip stays solid. | `downhill_shell.scad` |
| Intake | Geometry unchanged (still untested). It picks up the new hole pattern, a hoop just above the intake window, and **4 mm lightening in the tray floor** (−17 g). | `downhill_shell.scad` |
| Sorting hopper (exploration) | **Collector → height-gate splitter → 2 chutes.** Dowels pass under a fence 14 mm off the floor and keep going **south**. Balls (40 mm) can't pass; the 45° fence steers them out a side door onto the ball channel, which runs **north**. The channel tilts 6° toward the east wall, so dowels roll away from the ball door. Passive, no electronics, works for any dowel orientation. | `downhill_sorter.scad` |

Directions follow **Figure 1**: ping-pong box north (that's "right" when you face the device from the ramp), dowels box south. Both are at **Level 3**.
The auger must turn **CW seen from above** (the lifting direction for this right-hand flight). That puts the exit stream on the west side, where the collector is.

## Key numbers (from the OpenSCAD console)
- Shell 676.2 mm long. Pieces 222.6 / 226 / 225.2 mm (X2D OK). Joints at 225 and 451.
- Exit window bottom: **569 mm (22.4") above the tile** on the west side. Backbone top: 686 mm.
- Collector outlet: 522 mm. Chute tips: 410 mm, i.e. 10 mm above the Level 3 rim, past the near rim and over the opening, never touching the box.
- **Dowel chute** at D = 12": 485 mm long at **10.4°**. Up to D ≈ 16" still gives 8.6°; 18" is 7.9° (too flat for dowels).
- **Ball chute** at D = 24": 844 mm long at **5.0°**.
- Frame **rod cut length 373.4 mm** (was 359.7).
- Interference checks (collector, splitter, chutes, arm vs. shell / frame / legs): none.

## Scoring math (one perfect run, all 20 objects)
FoM = Index_W × [100 + 160 + 225·D_ball + 450·D_dowel] (both Level 3, D in inches).
Each inch of dowel distance is worth 450 points, each inch of ball distance 225 (before the weight index).

| D_ball / D_dowel | ×0.75 (24–32 oz) | ×1.0 (16–24 oz) | ×1.75 (14–16 oz) |
|---|---|---|---|
| 24 / 12 | 8,295 | 11,060 | 19,355 |
| 24 / 16 | 9,645 | 12,860 | 22,505 |

## Weight budget (solid-volume estimate, 1.24 g/cm³; "other" = auger + electronics + rods, back-solved from the measured 860 g)
| Configuration | g | oz | Index |
|---|---|---|---|
| Tower only, PLA | 869 | 30.7 | 0.75 |
| Tower + sorter, PLA (test build) | 1,095 | 38.6 | 0.5. **Only 1.4 oz under the 40 oz DQ limit** |
| Tower + sorter in PLA Aero (×0.6), auger PLA | 777 | 27.4 | 0.75 |
| Same + auger reprinted in Aero | 701 | 24.7 | 0.75, ~20 g from 1.0 |

Ways to get under 24 oz (1.0): hex-lighten the auger flights at the reprint (≈ −40 g PLA), make the ball chute two 3 mm carbon rods instead of a printed U (≈ −40 g), and weigh the electronics. The Aero factor is a guess, so trust the scale.
Printed parts in the tower: shells 318 g, clamps 34, sump + wings 124, collars 34, feet 11, pod 18, arm 23, coupler 6. Sorter: collector 76, splitter 45, chutes 92, sleeves 14.

## Parts, quantities, hardware
| Part (STL) | Qty | Print | Hardware |
|---|---|---|---|
| shell_lower | 1 | **upside down as exported** (flange on the bed) | — |
| shell_middle, shell_upper | 1 each | upright as exported | — |
| clamp_a / clamp_b | 2 / 2 | flat as exported | 4× M3×6×5 inserts (clamp_a), 4× M3×12 |
| key | 2 | flat | loose clocking key: drops into the notches in both faces of each joint |
| sump, wing_left, wing_right | 1 each | floor down | 627 bearing |
| pod | 1 | flat | 4× M3×4×5 inserts (shell bosses), 4× M3×10 |
| motor_arm | 1 | **upright as exported** (all bottoms on the bed; box top is a 12 mm bridge), 100% infill or 5 walls | 2× M2×4×3.2 inserts + 2× M2×6 (bracket), 2× M3×6×5 inserts + 2× M3×8 (to backbone) |
| motor_strap | 0–1 | ears down | only if the factory bracket's hole spacing ≠ 18 mm |
| coupler_v5 | 1 | plug down, 100% | M3×4×5 insert + M3×6; M2×4×3.2 insert + M2×5/×6 (or M2 grub) |
| coupler_v5_drill_jig | 1 | lip down | 2.5 then 3.4 mm drill |
| collar_front/back, foot_left/right | 1 each | as before | 2× M3×16 + nuts; rods 373.4 mm |
| sorter_collector_a / _b | 1 each | upright, **tree supports under the floor** | 2× M3×6×5 + 2× M3×12 (band) |
| sorter_splitter | 1 | floor down | 4× M3×8 into collector inserts (4× M3×6×5) |
| sorter_chute_ball / _dowel | 4 / 3 | floor down | 1.75 filament pins |
| sorter_sleeve | 5 | floor down | — |

Heat-set insert holes: M2 → 3.0 mm, M3 (5.0 OD) → 4.5 mm. Tune these in each file's parameters if your inserts go in too loose or too tight.

## Assembly order (top drive)
1. Drill the auger collar with the jig (once): 2.5 mm, then 3.4 mm, 7 mm below the top face.
2. Heat-set the inserts (coupler, arm, clamps, pod bosses, collector).
3. Press the coupler into the auger, turn it until the insert shows through the hole (the notch on the flange marks it), M3×6 in.
4. Motor into the arm: gearbox face on the shelf, factory bracket over the gearbox, 2× M2×6.
5. Lower the arm into the backbone, shaft into the coupler (flat toward the M2 insert), 2× M3×8 through the backbone pad, then M2 set screw.

## Verify before printing everything
- **Bracket hole spacing.** `brk_cc = 18.0` is derived from the 25.0 mm overall and 20.0 mm readings. Check it: measure outer-edge to outer-edge of the two holes, then subtract one hole diameter. Set `brk_cc`, or print `motor_strap`.
- **Encoder length.** `enc_len = 10` is only clearance above the arm (nothing sits there). Fine unless the board is bigger.
- **Print the splitter alone first** and drop the real objects through it. `gate_h` (14 mm), `s_cross` (6°) and `door_sill` (3 mm) are the tuning knobs.
- **Print one clamp pair + shell_middle** before the rest and check the flange fit.

