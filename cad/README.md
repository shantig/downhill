# Downhill — Level 3 build (v2)

All parametric OpenSCAD. Open `downhill_assembly.scad` to see everything together.

| File | What changed from v1 |
|---|---|
| `auger.scad` (v5) | 635 mm / 10 turns, 3 pieces of 211.7 mm, **umbrella flight (+40°)**, 1.2 mm solid flights. Key is male on the bottom of each piece; STLs export **upside down** for printing |
| `downhill_shell.scad` (v2) | 650.8 mm long, 3 dry-fit pieces, 1.2 mm wall, 6 mm slots everywhere except a 60° solid strip on the low side, 15° spouts |
| `downhill_frame.scad` | shell 116.4 × 650.8, feet spread to ±150 mm for the taller tower |
| `downhill_top_drive.scad` | shell_od 116.4. Motor hub floor now sits above the coupler boss (fixes a 1.5 mm clash); motor rides 2 mm higher |

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
| Shell ×3 | ~270 g | ~175 g |
| Auger ×3 (8% infill) | ~245 g | 245 g (keep PLA) |
| Boot, spouts, pod, collars, feet, cap, coupler | ~135 g | ~100 g |
| Rods, screws, electronics (~75 g guess) | ~100 g | ~100 g |
| **Total** | **~750 g ≈ 26.5 oz** (index 0.75) | **~620 g ≈ 22 oz** (index 1.0) |

The hopper and chutes still have to fit in the budget. Bambu Studio's sliced weight is the number to trust.

## Bambu Studio settings
**All parts:** PLA, 0.4 nozzle, 0.20 mm layers, **supports OFF**, except motor_mount (see table).

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
| pod, collars, feet, coupler | as exported | 15% (coupler 100%) | — |
| **motor_mount** | as exported (skirt down) | 15% | **supports ON for this part only**: tree, *on build plate only* (the spokes and motor hub start 6–10 mm above the bed) |

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
