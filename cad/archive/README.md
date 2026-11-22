# CAD archive

Superseded files, grouped by the version they belong to. The current version is always in `cad/src` and `cad/stl`.
These files are kept for reference. Some `use <...>` other files that have since changed, so to rebuild an old version exactly, check out its tag instead (`git checkout cad-v7`, etc.).

| Folder | Contents | Superseded by |
|---|---|---|
| [`v1-v4/`](v1-v4/) | Top drive v1/v2 (`downhill_top_drive.scad`: ring motor mount + set-screw coupler), v3 (`downhill_top_bar.scad`: drop-in motor bar), coupler v4 (zip-tie collet), shell v2 vs v4 render | v8 motor arm (`downhill_crown.scad`) + coupler v5 |
| [`v7/`](v7/) | Renders of the v7 tower (side exits, spouts, electronics pod) | v8 open top exit |
| [`v8/`](v8/) | Printed sorter concept (`downhill_sorter.scad`: collector, height-gate splitter, chutes, `gate_test`) with its STLs and the v8 renders (exit facing west) | v8.1 north exit + box mount for the team's rail box |

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
