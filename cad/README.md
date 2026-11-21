# Downhill — v8.1 (2026-11-21): exit opens north into the team's rail box

- **Shell v8.1:** the open exit arc is re-aimed **north (125–255°)** so objects drop straight into the team's cardboard rail sorter. The backbone now covers 255–485°, so the motor arm (20°) and the pod (+Y) still sit on it. The collector seat hoop moved down (`seat_drop` 60) so the new clamp band clears the pod bosses. **Reprint `shell_upper` from this version.**
- **`downhill_box_mount.scad` (new):** 2-half clamp band on the seat hoop, a back plate against the box's short end, **2 hooks** over the 6 mm cardboard end wall, a **sloped lip** that closes the curved gap between the round shell and the flat box end, and **side wings**. It holds the box level side-to-side (cancelling the 9° lean) and pitched **8° down toward the north** container.
  - `box_mount_north`: ~47 g PLA. Print upright as exported **with tree supports**. M3×6×5 inserts in its 2 ears.
  - `box_mount_south`: ~10 g. Flat, no supports. 2× M3×12.
- **Box length sets the ball distance** (far end 30 mm past the near rim): 286 mm → D = 4" (the rule minimum), 337 mm → 6", 389 mm → 8", 491 mm → 12". The current 260 mm box only reaches ~3.4", which is under the 4" minimum.
- Tie a fishing line from the top of the motor arm to the box's far end. The box is a cantilever.
- The printed collector/splitter concept (`downhill_sorter.scad`) is superseded on the tower. The `gate_test` part and the chute layout math still stand on their own.

---

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

---

# Previous notes (v7 and earlier)

# Downhill — Level 3 build

**Current versions:** shell v7 (tower at the foot of the ramp, 9° lean) · auger v5 · motor bar (top_bar) · coupler v4. See *Revision notes* at the bottom.

All parametric OpenSCAD. Open `downhill_assembly.scad` to see everything together.

| File | What changed from v1 |
|---|---|
| `auger.scad` (v5) | 635 mm / 10 turns, 3 pieces of 211.7 mm, **umbrella flight (+40°)**, 1.2 mm solid flights. Key is male on the bottom of each piece; STLs export **upside down** for printing |
| `downhill_shell.scad` (v7) | 650.2 mm long, 3 dry-fit pieces, 1.2 mm wall, **hex lightening** (5 mm AF, 2.4 mm webs) except a 60° solid strip on the low side, 15° spouts, rim slots for the motor bar. **Sump + intake tray** (`sump`, `wing_left`, `wing_right`) at the foot of the ramp; `shell_lower` prints **upside down** |
| `downhill_frame.scad` | shell 116.4 × 650.2, **lean 9°**, feet ±150 mm. **Rod cut length 359.7 mm** |
| `downhill_top_bar.scad` | drop-in motor bar (prints flat, no supports) through two rim slots |
| `downhill_coupler_v4.scad` | tapered plug + zip-tie collet; the motor shaft drops in with no force |
| `downhill_top_drive.scad` | legacy ring mount + coupler, superseded by the two files above |

> Heights, fit and weight below are from v4 (25° lean). At v7 the exits sit ~2" higher (ball sill ≈ 22.5", rim ≈ 25.3") and the sump + tray add ≈ 80 g net.

## Heights (Task 2 box rims: L3 = 15.75" / 400 mm)
| Exit | At the shell | Spout lip | Clears L3 rim by |
|---|---|---|---|
| Balls | 20.7" (526 mm) | ≈ 20.2" | ≈ 4.4" (112 mm) |
| Dowels | 19.6" (497 mm) | ≈ 19.0" | ≈ 3.3" (83 mm) |

That's the drop budget for the extension chutes out to the containers. At 12–15° (balls roll, and dowels roll crosswise) that's roughly 300–500 mm of run.

## Fit and stability
- Every part is ≤ 142 mm wide and ≤ 234 mm tall (X2D 260 mm Z).
- Ground contact runs from the boot to the feet, about 400 mm, inside the 19" (483 mm) footprint. The top overhangs, which the rules allow.
- Estimated CG ≈ 369 mm high. It tips at about 15° sideways and about 24° backward.
- Joints are dry-fit (16 mm sleeves + key), so everything packs apart. The longest item is the leg rods (351 mm).

## Weight (estimate — weigh the electronics)
| Group | PLA | Shell parts in PLA Aero |
|---|---|---|
| Shell ×3 (v4) | ~313 g | ~205 g |
| Auger ×3 (8% infill) | ~245 g | 245 g (keep PLA) |
| Boot, spouts, pod, collars, feet, cap, coupler | ~135 g | ~100 g |
| Rods, screws, electronics (~75 g guess) | ~100 g | ~100 g |
| **Total** | **~750 g ≈ 26.5 oz** (index 0.75) | **~620 g ≈ 22 oz** (index 1.0) |

The hopper and chutes still have to fit in the budget. Bambu Studio's sliced weight is the number to trust.

## Bambu Studio settings
**All parts:** PLA, 0.4 nozzle, 0.20 mm layers, **supports OFF** (no part needs them now).

**Walls (most important):**
- Quality → Line width → Outer wall and Inner wall = **0.40**.
- Strength → **Wall loops = 3**.
- The 1.2 mm shell and 1.2 mm flights then print as 3 clean lines. In Preview → Line type, check there's no gap infill inside the walls.

| Part | Orientation | Infill | Brim |
|---|---|---|---|
| shell_lower / middle / upper | as exported (sleeve end up, key end down) | n/a | outer brim 5 mm |
| auger_lower / middle / upper | **as exported: upside down** (top end on the bed, key/hub up). Upright, the umbrella flight's outer edge prints as an unsupported sliver | **8% gyroid** (hollow shaft) | outer brim 8–10 mm |
| boot | sole down | 15% gyroid | — |
| spouts | floor down | 15% | — |
| pod, collars, feet | as exported | 15% | — |
| motor_bar | flat, as exported | 15% | — |
| coupler_v4 | plug down, as exported | 100% | — |

- **Bridges:** the dowel-slot top (in shell_upper and spout_dowel) is a 70 mm bridge. Keep the default bridge settings. Light sag is harmless.
- **Elephant foot:** leave the default 0.15 so the sleeve fits stay true.
- **627 pin:** printed pins come out slightly fat. Sand until the bearing slides on.
- **Test first:** print shell_middle first and check its sleeve fit against the bottom of shell_upper before printing the rest.

**PLA Aero option (shell pieces, boot, spouts, pod, collars only):**
- Use the Bambu "PLA Aero" preset.
- Dry it at 55 °C for 8 h and keep it sealed.
- Use the slower preset speeds.
- Bambu's notes say to reduce or disable retraction and turn off Z-hop.
- It foams: print one shell piece and check the sleeve fit and the 2 mm flight clearance before printing the rest.
- Keep the auger, motor mount, coupler and pin in regular PLA. They need the stiffness and accuracy.

## Hardware
- 627 bearing on the printed pin
- 4× M3×5 (or M3×6 + washer): spouts → pad
- 4× M3×10: pod → bosses
- 2× M3×16 + nuts: collar
- 2× M3 self-tap: motor cap
- 8× M2.5×16 standoffs + screws, battery strap
- **2× 1/4" dowel legs, ROD CUT LENGTH 351.1 mm**

N20 lead routing is the same as v1: about 130 mm over the rim to the driver board's top edge.

## Revision notes
- Flight lightening holes were removed. Holes or slots cut vertically through a sloped flight leave small floating fragments that Bambu flags. Solid flights slice clean (checked at 0.16, 0.20 and 0.24 mm layers).
- Motor drive: the N20 is the 200 rpm version. Start the auger at roughly 20–30% speed (about 40–60 rpm).
- **Shell v3:** the v2 upper's 2 mm ribs flexed into the nozzle, snagged and broke. Ribs went to 4 mm, rows to 24 mm and rings to 5 mm, with no slots in the top 40 mm. Only the upper was printed at v3.
- **Top drive:** the ring mount was replaced by a drop-in bar (`downhill_top_bar.scad`). The coupler is now v4 with a zip-tie collet.
- **Shell v4:** the motor-bar rim slots (5.4 mm wide, 3.2 mm deep on ±X) are built in. The lower and middle pieces were re-exported with the v3 slot pattern (the v2 lower's ribs broke). The upper matches the hand-modified `shell_upper_v4.stl` exactly. Cost: about +11 g lower and +13 g middle over v2.
- **Shell v6:** objects caught on the 24 mm slots, so they became a hex grid (5 mm across flats, 5.8 mm corner to corner, 2.4 mm webs, corners up/down so no supports). Same open area and keep-outs.
- **Shell v7 (tower off the ramp):** objects were thrown back out of the 127 mm-tall v5 intake by the spinning flight. The tower now stands at the ramp's foot, centred, and leans 9° (was 25°) so the tray floor and sump floor form one plane from the ramp down to the tile.
  - The tray's uphill edge is a wedge resting on the ramp 2.8–3.1" up the slope (inside the 4" contact zone). The wings funnel the 11.625" lane into the intake, float ≥3 mm over the ramp past the floor edge and stop 8 mm short of the 4" line.
  - Intake: 150° arc × 50 mm (taller than a ball, lower than one 63.5 mm pitch). Anything flung out lands on the tray and rolls back in.
  - The floor, 627 pin and a locating lip moved to the new `sump`. `shell_lower` is a plain tube that stands in the lip and prints upside down so the window top isn't a bridge. The tray is wider than the bed, so it splits at x = ±100 mm and the wings drop onto puzzle tabs (CA glue on the wall seams if loose).
  - Placement: the tube axis sits ≈ 67 mm in from the ramp's bottom edge; the back of the sump rests on the tile ≈ 126 mm in. `boot` is retired; spouts now tilt with the lean (still 15° below horizontal). Collars and feet were re-exported for the new leg angle.
