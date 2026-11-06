"""Downhill Dispatcher - parametric test pieces (sorter rig + Task 2 collector).

Every dimension comes from the `Params` spreadsheet in the document. Each part is
a Part::FeaturePython object that links to that sheet, so editing a cell and
recomputing (Ctrl+R) regenerates the geometry.

FreeCAD must be able to import this module when the .FCStd is opened. Either
symlink cad/lib into your FreeCAD Mod folder (see cad/README.md) or run
`sys.path.insert(0, "<repo>/cad/lib")` in the Python console first.

Frames (all mm / degrees):
  World:      x east (up the ramp), y north, z up.  x = 0 is the ramp foot, which
              is also the east edge of the 19" footprint.
  Ramp-local: s up the slope from the foot, v = y, w normal to the ramp surface.
  Sorter:     x downhill along the flow, y across, z normal to the deck; the top
              of the upstream deck is z = 0.
"""

import math

import FreeCAD as App
import Part

V = App.Vector

# alias, value (number or "=formula"), unit, description
PARAMS = [
    ("--- General", None, "", ""),
    ("Clr", 0.2, "mm", "Fit clearance per side"),
    ("Screw_D", 3.4, "mm", "M3 clearance hole"),
    ("Screw_Pilot", 2.5, "mm", "M3 self-tap pilot hole"),
    ("Ball_D", 40.0, "mm", "Ping-pong ball"),
    ("Dowel_D", 8.0, "mm", "Dowel diameter"),
    ("Dowel_L", 40.0, "mm", "Dowel length"),
    ("--- Ramp (reference)", None, "", ""),
    ("Ramp_Ang", 25.05, "deg", "Ramp angle (+/-0.45)"),
    ("Ramp_InnerW", 295.275, "mm", "11.625 in between ramp side walls"),
    ("Ramp_PlateW", 355.6, "mm", "14 in ramp plate width"),
    ("Ramp_Zone", 101.6, "mm", "4 in contact zone, along slope; walls start here"),
    ("Ramp_WallT", 3.2, "mm", "Ramp side-wall thickness (guess, reference only)"),
    ("--- Conveyor interface", None, "", ""),
    ("Belt_ClearW", 60.0, "mm", "Clear width between conveyor side frames"),
    ("Conv_Ang", 65.0, "deg", "Conveyor incline from horizontal (leans west)"),
    ("Pulley_T", 40, "teeth", "GT2 lower pulley tooth count"),
    ("Pulley_PR", "=Pulley_T * 2 / (2 * pi)", "mm", "GT2 pitch radius"),
    ("Belt_T", 1.4, "mm", "Pitch line to belt back"),
    ("Cleat_H", 18.0, "mm", "Cleat height above belt back"),
    ("Axle_D", 5.0, "mm", "Lower pulley axle"),
    ("--- Collector", None, "", ""),
    ("Col_Reach", 95.25, "mm", "Max reach up the ramp along slope (3.75 in < 4 in)"),
    ("Col_InnerW", "=Ramp_InnerW + 6", "mm", "Funnel mouth, 3 mm wider than ramp walls each side"),
    ("Col_Wall", 1.6, "mm", "Wing wall thickness"),
    ("Col_SideH", 60.0, "mm", "Side wall height (normal to ramp)"),
    ("Col_BackH", 100.0, "mm", "Foot wall / rebound backstop height (normal to ramp)"),
    ("Col_FacetH", 40.0, "mm", "Deflector facet height at outer foot corner"),
    ("Col_Sc", 30.0, "mm", "s where the funnel ends and the boot channel starts"),
    ("Col_FlangeL", 14.0, "mm", "Wing-to-boot flange length along s"),
    ("Col_FlangeT", 2.4, "mm", "Wing-to-boot flange thickness"),
    ("Boot_Plate", 3.0, "mm", "Boot side plate thickness"),
    ("Boot_PlateH", 80.0, "mm", "Boot plate height normal to ramp"),
    ("Boot_Gap", 4.0, "mm", "Cleat tip to trough clearance"),
    ("Boot_Shell", 1.6, "mm", "Trough shell thickness"),
    ("Boot_BackL", 60.0, "mm", "Straight back wall length above trough"),
    ("Boot_LipL", 20.0, "mm", "Feathered lip from ramp onto trough"),
    ("Boot_Hole1", 15.0, "mm", "Flange screw 1 height (w)"),
    ("Boot_Hole2", 60.0, "mm", "Flange screw 2 height (w)"),
    ("--- Sorter rig", None, "", ""),
    ("Sort_Gap", 22.0, "mm", "Sorting gap (dowels drop, balls cross)"),
    ("Sort_GapMin", 16.0, "mm", "Slot travel, min gap"),
    ("Sort_GapMax", 28.0, "mm", "Slot travel, max gap"),
    ("Sort_Ang", 10.0, "deg", "Deck angle"),
    ("Sort_W", 62.0, "mm", "Clear width between walls"),
    ("Sort_L1", 120.0, "mm", "Upstream deck length"),
    ("Sort_L2", 80.0, "mm", "Landing deck length"),
    ("Sort_Drop", 3.0, "mm", "Landing deck step-down"),
    ("Sort_LandT", 6.0, "mm", "Landing deck thickness"),
    ("Sort_Wall", 2.0, "mm", "Side wall thickness"),
    ("Sort_WallH", 30.0, "mm", "Side wall height above deck"),
    ("Sort_StandH", 60.0, "mm", "Deck underside height at the gap"),
    ("Sort_CheekT", 3.0, "mm", "Stand cheek thickness"),
    ("Tray_L", 90.0, "mm", "Catch tray inner length (along flow)"),
    ("Tray_W", 70.0, "mm", "Catch tray inner width"),
    ("Tray_H", 35.0, "mm", "Catch tray height"),
    ("Tray_Wall", 1.6, "mm", "Catch tray wall"),
]

# kind -> (label, group, colour, is_reference)
KINDS = {
    "col_wing_r": ("Collector_Wing_N", "Collector", (0.2, 0.5, 0.9), False),
    "col_wing_l": ("Collector_Wing_S", "Collector", (0.2, 0.5, 0.9), False),
    "col_boot_r": ("Collector_Boot_N", "Collector", (0.9, 0.5, 0.1), False),
    "col_boot_l": ("Collector_Boot_S", "Collector", (0.9, 0.5, 0.1), False),
    "ref_ramp": ("REF_Ramp", "Reference", (0.75, 0.75, 0.75), True),
    "ref_floor": ("REF_Floor", "Reference", (0.85, 0.85, 0.8), True),
    "sort_deck": ("Sorter_Deck", "Sorter", (0.2, 0.7, 0.3), False),
    "sort_landing": ("Sorter_Landing", "Sorter", (0.9, 0.8, 0.1), False),
    "sort_cheek_r": ("Sorter_Cheek_N", "Sorter", (0.5, 0.5, 0.5), False),
    "sort_cheek_l": ("Sorter_Cheek_S", "Sorter", (0.5, 0.5, 0.5), False),
    "sort_tray": ("Sorter_Tray", "Sorter", (0.8, 0.3, 0.3), False),
    "sort_gauge": ("Sorter_GapGauge", "Sorter", (0.6, 0.3, 0.8), False),
}


# ---------------------------------------------------------------- helpers
def read_params(sheet):
    P = {}
    for alias, val, _u, _d in PARAMS:
        if val is None:
            continue
        q = sheet.get(alias)
        P[alias] = float(getattr(q, "Value", q))
    return P


def box(x0, y0, z0, dx, dy, dz):
    return Part.makeBox(dx, dy, dz, V(x0, y0, z0))


def xz_prism(pts, y0, y1):
    """Closed polygon of (x, z) points in the XZ plane, extruded from y0 to y1."""
    w = Part.makePolygon([V(x, y0, z) for x, z in pts] + [V(pts[0][0], y0, pts[0][1])])
    return Part.Face(w).extrude(V(0, y1 - y0, 0))


def ycyl(r, x, z, y0, y1):
    return Part.makeCylinder(r, y1 - y0, V(x, y0, z), V(0, 1, 0))


def ramp_matrix(P):
    m = App.Matrix()
    m.rotateY(math.radians(-P["Ramp_Ang"]))  # local x -> up the slope
    return m


def to_world(shape, m):
    s = shape.copy()
    s.transformShape(m)
    return s


def rl_xz(P, s, w):
    """Ramp-local (s, w) -> world (x, z)."""
    a = math.radians(P["Ramp_Ang"])
    return (s * math.cos(a) - w * math.sin(a), s * math.sin(a) + w * math.cos(a))


def onto_bed(shape, rot_x_deg=0.0):
    s = shape.copy()
    if rot_x_deg:
        m = App.Matrix()
        m.rotateX(math.radians(rot_x_deg))
        s.transformShape(m)
    bb = s.BoundBox
    s.translate(V(-bb.XMin, -bb.YMin, -bb.ZMin))
    return s


def tetra(a, b, c, d):
    faces = [Part.Face(Part.makePolygon([p, q, r, p])) for p, q, r in
             ((a, b, c), (a, b, d), (a, c, d), (b, c, d))]
    sol = Part.Solid(Part.Shell(faces))
    if sol.Volume < 0:
        sol.reverse()
    return sol


# ---------------------------------------------------------------- collector
def boot_geom(P):
    a = math.radians(P["Ramp_Ang"])
    Rt = P["Pulley_PR"] + P["Belt_T"] + P["Cleat_H"] + P["Boot_Gap"]  # trough inner radius
    Ro = Rt + P["Boot_Shell"]
    # Pulley axis placed so the trough's outer skin is tangent to BOTH the floor
    # (z = 0) and the ramp surface: it nests in the corner at the ramp foot.
    zc = Ro
    xc = -Ro * math.tan(a / 2)
    s_t = xc * math.cos(a) + zc * math.sin(a)  # where the trough meets the ramp
    th_ret = 270.0 - P["Conv_Ang"]  # return-run tangent angle
    th_t = 270.0 + P["Ramp_Ang"]  # ramp tangent angle
    return dict(Rt=Rt, Ro=Ro, xc=xc, zc=zc, s_t=s_t, th_ret=th_ret, th_t=th_t)


def build_boot(P):
    g = boot_geom(P)
    xc, zc, Rt, Ro = g["xc"], g["zc"], g["Rt"], g["Ro"]
    hw = P["Belt_ClearW"] / 2
    tb = P["Boot_Plate"]
    sh = P["Boot_Shell"]
    beta = math.radians(P["Conv_Ang"])
    d = (-math.cos(beta), math.sin(beta))  # up the conveyor (west and up)

    def pc(r, th):
        t = math.radians(th)
        return (xc + r * math.cos(t), zc + r * math.sin(t))

    # trough: annular sector from the return-run tangent to the ramp tangent
    th0, th1 = g["th_ret"], g["th_t"]
    thm = (th0 + th1) / 2
    y0, y1 = -hw - tb / 2, hw + tb / 2  # overlap into the plates

    def v3(p, y):
        return V(p[0], y, p[1])

    e = [
        Part.Arc(v3(pc(Ro, th0), y0), v3(pc(Ro, thm), y0), v3(pc(Ro, th1), y0)).toShape(),
        Part.LineSegment(v3(pc(Ro, th1), y0), v3(pc(Rt, th1), y0)).toShape(),
        Part.Arc(v3(pc(Rt, th1), y0), v3(pc(Rt, thm), y0), v3(pc(Rt, th0), y0)).toShape(),
        Part.LineSegment(v3(pc(Rt, th0), y0), v3(pc(Ro, th0), y0)).toShape(),
    ]
    trough = Part.Face(Part.Wire(e)).extrude(V(0, y1 - y0, 0))

    # straight back wall shielding the return run
    pi0, po0 = pc(Rt, th0), pc(Ro, th0)
    L = P["Boot_BackL"]
    back = xz_prism([pi0, po0, (po0[0] + L * d[0], po0[1] + L * d[1]),
                     (pi0[0] + L * d[0], pi0[1] + L * d[1])], y0, y1)

    # feathered lip from the ramp surface up onto the trough skin
    st, lip = g["s_t"], P["Boot_LipL"]
    lipw = xz_prism([rl_xz(P, st, 0), rl_xz(P, st + lip, 0), rl_xz(P, st + lip, 0.4),
                     rl_xz(P, st, sh)], y0, y1)

    shell = trough.fuse([back, lipw])

    # side plates
    sc, ph = P["Col_Sc"], P["Boot_PlateH"]
    s_lo = g["s_t"] - Ro - 10
    rect = [rl_xz(P, s_lo, 0), rl_xz(P, sc, 0), rl_xz(P, sc, ph), rl_xz(P, s_lo, ph)]
    u = (math.cos(math.radians(th0)), math.sin(math.radians(th0)))  # outward, return side
    r_in, r_out = -(Rt + 3), Ro + 3
    band = [(xc + r_in * u[0], zc + r_in * u[1]), (xc + r_out * u[0], zc + r_out * u[1])]
    band += [(band[1][0] + L * d[0], band[1][1] + L * d[1]),
             (band[0][0] + L * d[0], band[0][1] + L * d[1])]

    def plate(ya, yb):
        p = xz_prism(rect, ya, yb).fuse([ycyl(Ro + 3, xc, zc, ya, yb), xz_prism(band, ya, yb)])
        return p

    plates = plate(hw, hw + tb).fuse(plate(-hw - tb, -hw))
    body = plates.fuse(shell)

    # trim: below floor, below ramp surface, beyond the funnel junction
    big = 2000
    body = body.cut(box(-big / 2, -big / 2, -big, big, big, big))
    m = ramp_matrix(P)
    body = body.cut(to_world(box(-big / 2, -big / 2, -big, big, big, big), m))
    body = body.cut(to_world(box(sc, -big / 2, -big / 2, big, big, big), m))

    # axle + flange screw holes
    body = body.cut(ycyl(P["Axle_D"] / 2 + P["Clr"], xc, zc, -big / 2, big / 2))
    for hz in (P["Boot_Hole1"], P["Boot_Hole2"]):
        hx, hzz = rl_xz(P, sc - P["Col_FlangeL"] / 2, hz)
        body = body.cut(ycyl(P["Screw_D"] / 2, hx, hzz, hw - 1, big / 2))
        body = body.cut(ycyl(P["Screw_D"] / 2, hx, hzz, -big / 2, -hw + 1))
    return body.removeSplitter()


def build_boot_half(P, north):
    body = build_boot(P)
    big = 2000
    keep = box(-big / 2, 0, -big / 2, big, big, big) if north else \
        box(-big / 2, -big, -big / 2, big, big, big)
    half = body.common(keep).removeSplitter()
    return half, onto_bed(half, -90.0 if north else 90.0)


def build_wing_local(P):
    wi = P["Col_InnerW"] / 2
    vc = P["Belt_ClearW"] / 2 + P["Boot_Plate"]
    R, sc, t, H = P["Col_Reach"], P["Col_Sc"], P["Col_Wall"], P["Col_FacetH"]
    fl, ft = P["Col_FlangeL"], P["Col_FlangeT"]
    facet = tetra(V(R, wi, 0), V(sc, vc, 0), V(sc, wi, 0), V(sc, wi, H))
    side = box(sc - t, wi, 0, R - (sc - t), t, P["Col_SideH"])
    foot = box(sc - t, vc, 0, t, wi + t - vc, P["Col_BackH"])
    flange = box(sc - fl, vc, 0, fl, ft, P["Boot_PlateH"])
    w = facet.fuse([side, foot, flange])
    for hz in (P["Boot_Hole1"], P["Boot_Hole2"]):
        w = w.cut(ycyl(P["Screw_D"] / 2, sc - fl / 2, hz, vc - 1, vc + ft + 1))
    return w.removeSplitter()


def build_wing(P, north):
    loc = build_wing_local(P)
    if not north:
        loc = loc.mirror(V(0, 0, 0), V(0, 1, 0))
    return to_world(loc, ramp_matrix(P)), onto_bed(loc)


def build_ref_ramp(P):
    hw = P["Ramp_PlateW"] / 2
    iw = P["Ramp_InnerW"] / 2
    z = P["Ramp_Zone"]
    loc = box(0, -hw, -6, 300, 2 * hw, 6)
    for sgn in (1, -1):
        y0 = iw if sgn > 0 else -iw - P["Ramp_WallT"]
        loc = loc.fuse(box(z, y0, 0, 300 - z, P["Ramp_WallT"], 120))
    w = to_world(loc, ramp_matrix(P))
    return w.cut(box(-1000, -1000, -1000, 2000, 2000, 1000)), None


def build_ref_floor(P):
    return box(-482.6, -241.3, -2, 482.6, 482.6, 2), None


# ---------------------------------------------------------------- sorter
def sorter_frame(P):
    th = math.radians(P["Sort_Ang"])
    zbed = -(P["Sort_Drop"] + P["Sort_LandT"])
    zo = P["Sort_StandH"] + P["Sort_L1"] * math.sin(th) - zbed * math.cos(th)
    m = App.Matrix()
    m.rotateY(th)  # local +x -> downhill
    m.move(V(0, 0, zo))

    def w(x, z):
        return (x * math.cos(th) + z * math.sin(th), -x * math.sin(th) + z * math.cos(th) + zo)

    return m, w, zbed


def build_deck_local(P):
    _m, _w, zb = sorter_frame(P)
    W, wl, L1, L2 = P["Sort_W"], P["Sort_Wall"], P["Sort_L1"], P["Sort_L2"]
    gmin, gmax, wh, sd = P["Sort_GapMin"], P["Sort_GapMax"], P["Sort_WallH"], P["Screw_D"]
    lt = P["Sort_LandT"]
    deck = box(0, -W / 2, zb, L1, W, -zb)
    walls = [box(-wl, W / 2, zb, wl + L1 + gmax + L2, wl, wh - zb),
             box(-wl, -W / 2 - wl, zb, wl + L1 + gmax + L2, wl, wh - zb),
             box(-wl, -W / 2, zb, wl, W, wh - zb)]
    d = deck.fuse(walls)
    # slots for the landing-deck screws
    zs = zb + lt / 2
    for xi in (15.0, L2 - 15.0):
        x0, x1 = L1 + gmin + xi, L1 + gmax + xi
        d = d.cut(box(x0 - sd / 2, -W / 2 - wl - 1, zs - sd / 2, x1 - x0 + sd, W + 2 * wl + 2, sd))
    # cheek screws: clearance through walls, pilot into the deck block
    zh = zb / 2
    for xh in cheek_hole_x(P):
        for sgn in (1, -1):
            ya, yb = (W / 2, W / 2 + wl + 1) if sgn > 0 else (-W / 2 - wl - 1, -W / 2)
            d = d.cut(ycyl(sd / 2, xh, zh, ya, yb))
            pa, pb = (W / 2 - 10, W / 2 + 0.1) if sgn > 0 else (-W / 2 - 0.1, -W / 2 + 10)
            d = d.cut(ycyl(P["Screw_Pilot"] / 2, xh, zh, pa, pb))
    return d.removeSplitter()


def cheek_hole_x(P):
    xc = P["Sort_L1"] - 50
    return (15.0, xc - 15.0)


def build_landing_local(P):
    _m, _w, zb = sorter_frame(P)
    W, c, L1, L2, G, lt = P["Sort_W"], P["Clr"], P["Sort_L1"], P["Sort_L2"], P["Sort_Gap"], P["Sort_LandT"]
    ld = box(L1 + G, -W / 2 + c, zb, L2, W - 2 * c, lt)
    for xi in (15.0, L2 - 15.0):
        x = L1 + G + xi
        ld = ld.cut(ycyl(P["Screw_Pilot"] / 2, x, zb + lt / 2, -W / 2 + c - 1, -W / 2 + c + 10))
        ld = ld.cut(ycyl(P["Screw_Pilot"] / 2, x, zb + lt / 2, W / 2 - c - 10, W / 2 - c + 1))
    return ld


def build_sorter_part(P, which):
    m, _w, zb = sorter_frame(P)
    loc = build_deck_local(P) if which == "deck" else build_landing_local(P)
    pr = loc.copy()
    pr.translate(V(0, 0, -zb))
    return to_world(loc, m), onto_bed(pr)


def build_cheek(P, north):
    _m, w, zb = sorter_frame(P)
    W, wl, ct = P["Sort_W"], P["Sort_Wall"], P["Sort_CheekT"]
    xc, ztop = P["Sort_L1"] - 50, 8.0
    t0, t1 = w(0, ztop), w(xc, ztop)
    pts = [t0, t1, (t1[0], 0.0), (t0[0], 0.0)]
    y0 = W / 2 + wl if north else -W / 2 - wl - ct
    ch = xz_prism(pts, y0, y0 + ct)
    for xh in cheek_hole_x(P):
        hx, hz = w(xh, zb / 2)
        ch = ch.cut(ycyl(P["Screw_D"] / 2, hx, hz, y0 - 1, y0 + ct + 1))
    return ch, onto_bed(ch, -90.0 if north else 90.0)


def build_tray(P):
    _m, w, zb = sorter_frame(P)
    xg, _ = w(P["Sort_L1"] + P["Sort_Gap"] / 2, zb)
    L, Wt, H, t = P["Tray_L"], P["Tray_W"], P["Tray_H"], P["Tray_Wall"]
    outer = box(xg - L / 2 - t, -Wt / 2 - t, 0, L + 2 * t, Wt + 2 * t, H)
    tray = outer.cut(box(xg - L / 2, -Wt / 2, t, L, Wt, H))
    return tray, onto_bed(tray)


def build_gauge(P):
    gaps = [18.0, 20.0, 22.0, 24.0, 26.0]
    total = sum(gaps) + 4 * (len(gaps) + 1)
    g = box(0, 0, 0, total, 8, 4)
    x = 4.0
    for i, gw in enumerate(gaps):
        g = g.fuse(box(x, 8, 0, gw, 15, 4))
        # i+1 index bumps on the spine so the tabs can be told apart
        for k in range(i + 1):
            g = g.fuse(box(x + 2 + 3 * k, 2, 4, 1.5, 4, 1))
        x += gw + 4
    g = g.removeSplitter()
    # assembly view: park it beside the rig
    w = g.copy()
    w.translate(V(0, -P["Sort_W"] - 60, 0))
    return w, onto_bed(g)


BUILDERS = {
    "col_wing_r": lambda P: build_wing(P, True),
    "col_wing_l": lambda P: build_wing(P, False),
    "col_boot_r": lambda P: build_boot_half(P, True),
    "col_boot_l": lambda P: build_boot_half(P, False),
    "ref_ramp": build_ref_ramp,
    "ref_floor": build_ref_floor,
    "sort_deck": lambda P: build_sorter_part(P, "deck"),
    "sort_landing": lambda P: build_sorter_part(P, "landing"),
    "sort_cheek_r": lambda P: build_cheek(P, True),
    "sort_cheek_l": lambda P: build_cheek(P, False),
    "sort_tray": build_tray,
    "sort_gauge": build_gauge,
}


# ---------------------------------------------------------------- document objects
class DBTPart:
    def __init__(self, obj, kind, sheet):
        obj.addProperty("App::PropertyLink", "Params", "DBT", "Parameter spreadsheet")
        obj.addProperty("App::PropertyString", "Kind", "DBT", "Builder key in dbt_testparts")
        obj.Params = sheet
        obj.Kind = kind
        obj.Proxy = self

    def execute(self, obj):
        P = read_params(obj.Params)
        shp = BUILDERS[obj.Kind](P)[0]
        if not shp.Placement.isIdentity():
            # Part::Feature would replace a shape-level placement with its own
            # Placement property; nesting keeps the transform in the geometry.
            shp = Part.makeCompound([shp])
        obj.Shape = shp

    def dumps(self):
        return None

    def loads(self, state):
        return None

    __getstate__ = dumps

    def __setstate__(self, state):
        return None


def make_sheet(doc):
    sh = doc.addObject("Spreadsheet::Sheet", "Params")
    sh.set("A1", "Alias")
    sh.set("B1", "Value")
    sh.set("C1", "Unit")
    sh.set("D1", "Description")
    for i, (alias, val, unit, desc) in enumerate(PARAMS, start=2):
        if val is None:
            sh.set(f"A{i}", alias)
            continue
        sh.set(f"A{i}", alias)
        sh.set(f"B{i}", str(val))
        sh.set(f"C{i}", unit)
        sh.set(f"D{i}", desc)
        sh.setAlias(f"B{i}", alias)
    doc.recompute()
    return sh


def make_document(path=None):
    doc = App.newDocument("DBT_TestPieces")
    sheet = make_sheet(doc)
    groups = {}
    for kind, (label, grp, col, _ref) in KINDS.items():
        if grp not in groups:
            groups[grp] = doc.addObject("App::DocumentObjectGroup", grp)
        o = doc.addObject("Part::FeaturePython", label)
        DBTPart(o, kind, sheet)
        groups[grp].addObject(o)
        if App.GuiUp:
            o.ViewObject.Proxy = 0
            o.ViewObject.ShapeColor = col
            if _ref:
                o.ViewObject.Transparency = 60
    doc.recompute()
    if path:
        doc.saveAs(path)
    return doc


def export_all(doc, out_dir):
    """STL + STEP of every printable part in print orientation, plus assembly STEPs."""
    import os

    import Import
    import MeshPart

    P = read_params(doc.getObject("Params"))
    report = []
    for kind, (label, grp, _c, ref) in KINDS.items():
        if ref:
            continue
        pr = BUILDERS[kind](P)[1]
        mesh = MeshPart.meshFromShape(Shape=pr, LinearDeflection=0.05, AngularDeflection=0.25,
                                      Relative=False)
        mesh.write(os.path.join(out_dir, "stl", label + ".stl"))
        pr.exportStep(os.path.join(out_dir, "step", label + ".step"))
        bb = pr.BoundBox
        report.append((label, pr.Volume / 1000.0, bb.XLength, bb.YLength, bb.ZLength))
    for grp in ("Collector", "Sorter"):
        objs = [o for o in doc.getObject(grp).Group]
        Import.export(objs, os.path.join(out_dir, "step", f"{grp}_Assembly.step"))
    return report
