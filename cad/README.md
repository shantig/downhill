# CAD

## Test pieces (`test_pieces/`)

`DBT_TestPieces.FCStd` holds the sorter test rig and the Task 2 collector. The
`Params` spreadsheet sets every key dimension: edit a cell, then recompute (Ctrl+R).
The geometry code is in `lib/dbt_testparts.py`, with one `Part::FeaturePython`
object per part.

**One-time setup:** FreeCAD has to be able to import the module, so link it into
your Mod folder:

```sh
ln -sfn "$PWD/cad/lib" "$HOME/Library/Application Support/FreeCAD/v1-1/Mod/dbt_cad"
```

**Re-export** after a change, from the FreeCAD Python console:

```python
import dbt_testparts as D
D.export_all(App.ActiveDocument, "<repo>/cad/test_pieces")
```

The STL and per-part STEP files come out already in print orientation. The two
`*_Assembly.step` files show the parts in their assembled positions.

### Sorter rig
| Part | Qty | Notes |
|---|---|---|
| Sorter_Deck | 1 | Upstream deck, walls, and end stop. Prints flat. |
| Sorter_Landing | 1 | Slides in slots that give a 16–28 mm gap. Fix it with 4× M3 self-tapping screws. |
| Sorter_Cheek_N/S | 1 each | Stand that sets `Sort_Ang`. Fix with 4× M3 screws into the deck block. |
| Sorter_Tray | 1 | Sits under the gap and catches dowels. |
| Sorter_GapGauge | 1 | Tabs of 18/20/22/24/26 mm. The bump count gives the tab index (1 = 18 mm). |

The landing deck sits `Sort_Drop` (3 mm) below the upstream deck, so a ball sinks
about 3.4 mm into a 22 mm gap and still rolls onto the landing deck without catching
the far edge.

### Collector (sits in the bottom 4" of the ramp)
| Part | Qty | Notes |
|---|---|---|
| Collector_Boot_N/S | 1 each | Mirror halves. Glue them at the centre plane. The trough wraps around the lower pulley axle (Ø5) and nests in the floor/ramp corner. |
| Collector_Wing_N/S | 1 each | Funnel wing: side wall, deflector facet, and foot wall (rebound backstop). Fix each to the boot with 2× M3 screws. |

- It reaches 95.25 mm (3.75") up the slope, which leaves 6 mm before the ramp walls start.
- The mouth is 301 mm wide, 3 mm wider than the 11.625" ramp walls on each side.
- The trough radius is pulley pitch radius + belt + 18 mm cleat + 4 mm gap, so the
  cleats sweep the whole trough and leave no dead corner.
- The wing facets are solid wedges. Print them with sparse infill (gyroid 8–10 %) and
  no supports. The facet edge that rests on the ramp is feathered to zero thickness.
