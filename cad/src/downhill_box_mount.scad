// =====================================================================
// Downhill Dispatcher — BOX MOUNT v1: hangs the team's cardboard rail sorter on the tower
// ---------------------------------------------------------------------
// The team's sorter: a cardboard box (6 mm walls) with two skewer rails
// along its length. Dowels drop between the rails, balls ride to the far
// end and roll out. This mount replaces the printed collector:
//
//   band   : 2-half clamp on the shell, sitting on the seat hoop just
//            below the exit window (M3x12 + M3x6x5 inserts in the ears)
//   plate  : back plate against the box's SHORT end wall, tied to the
//            band by 3 ribs
//   hooks  : 2 hooks over the end wall's top edge (6 mm cardboard)
//   lip    : sloped plate from the window bottom down over the end wall,
//            closing the curved gap between the round shell and the flat
//            box end, so everything leaving the window lands in the box
//   wings  : side walls along the lip so nothing rolls off sideways
//
// Shell v8.1 opens the exit window NORTH (125..255 deg), so the box hangs
// on the north side and runs north, sloping down by box_pitch toward the
// ball container. The mount levels the box side-to-side (it cancels the
// tower's 9 deg lean).
// The box is a cantilever: tie a fishing line from the top of the motor
// arm to the box's far end.
//
// Box length sets the ball distance: the far end should sit just past the
// near rim of the north container. The console prints the length you need
// for D_ball.
//
// Frames: tube frame like downhill_shell.scad; the box frame B has x along
// the box toward the tower, z up its end wall, origin at the top outside
// edge of the end wall.
// Print: north half upright as exported WITH tree supports (lip and
// hooks overhang); south half flat as exported, no supports.
// CLI: openscad -D 'part="mount_north"' -o box_mount_north.stl downhill_box_mount.scad
// =====================================================================
use <downhill_shell.scad>

part = "assembly"; // [assembly, mount_north, mount_south]

/* [Box (team's cardboard sorter)] */
box_w     = 122;      // outside width
box_h     = 66.5;     // outside height
box_l     = 260.35;   // current length (extend: see console)
box_t     = 6;        // cardboard
box_pitch = 8;        // deg, far (north) end lower
top_gap   = 10;       // box top edge below the window bottom (at the shell)

/* [Mount] */
band_t    = 2.0;
band_h    = 16;
plate_t   = 2.5;
hook_t    = 2.2;
hook_w    = 14;
hook_y    = 38;       // hooks at +-hook_y
hook_drop = 14;       // inner leg length down the inside of the end wall
fit       = 0.4;      // clearance on the cardboard
lip_t     = 1.6;
wing_t    = 1.6;
wing_h    = 22;       // above the lip
rib_t     = 3;
rib_y     = [-40, 0, 40];
m3_ins_d  = 4.5;
m3_ins_l  = 6.5;
m3_clear  = 3.4;
D_ball    = 6;        // inches (for the length readout)
level_z   = 400;

$fn = 96;

// ------------------------------ shell numbers -------------------------
si = shell_info();     // [z_a0, z_a1, shell_len, R, lean, n_pieces, T_y, T_z, z_w0, bb_a0, bb_a1, arm_a, arm_z, arm_screw_dz, z_seat, Ri]
R = si[3]; lean = si[4]; T_y = si[6]; T_z = si[7]; z_w0 = si[8]; z_seat = si[14]; bb_a0 = si[9]; bb_a1 = si[10];
module to_world() translate([0, T_y, T_z]) rotate([lean,0,0]) children();
module to_tube() rotate([-lean,0,0]) translate([0, -T_y, -T_z]) children();
function tw(p) = [p[0], T_y + p[1]*cos(lean) - p[2]*sin(lean), T_z + p[1]*sin(lean) + p[2]*cos(lean)];

// window bottom at the north point (world)
P_w = tw([-R, 0, z_w0]);
// box frame origin (world): top outside edge of the end wall, centred on the tower
ox  = -R - band_t - plate_t - 2 - box_h*sin(box_pitch);     // pitched end wall's foot leans in toward the shell: keep it clear
O_w = [ox, P_w[1], P_w[2] - top_gap];
module to_box_world() translate(O_w) rotate([0, -box_pitch, 0]) children();   // B frame -> world
module B() to_tube() to_box_world() children();                              // B frame -> tube frame

// far end / ball distance readout (world)
far_x = O_w[0] - box_l*cos(box_pitch);
far_z = O_w[2] - box_l*sin(box_pitch);
fp = 241.3;
need_x = fp + D_ball*25.4 - 25.4 + 30;                       // just past the near rim
function len_for(D) = (fp + D*25.4 - 25.4 + 30 + O_w[0])/cos(box_pitch);   // far end 30 mm past the near rim
echo(str("BOX: end wall top at world z ", O_w[2], " mm (", O_w[2]/25.4, " in). Current ", box_l, " mm box reaches D ~ ",
         (-far_x - fp - 30 + 25.4)/25.4, " in"));
echo(str("Box length for D_ball = 4 in: ", len_for(4), " mm;  6 in: ", len_for(6), ";  8 in: ", len_for(8), ";  12 in: ", len_for(12),
         ".  Far-end bottom at D_ball: z ", O_w[2] - len_for(D_ball)*sin(box_pitch) - box_h*cos(box_pitch)));
assert(O_w[2] - len_for(D_ball)*sin(box_pitch) - box_h*cos(box_pitch) > level_z + 5, "box far end would hit the Level 3 container: less pitch or shorter D");

// ------------------------------ parts (B frame) -----------------------
module hooks_B() for (s = [-1,1]) translate([0, s*hook_y - hook_w/2, 0]) {
    translate([-box_t - fit - hook_t, 0, fit]) cube([box_t + 2*fit + hook_t + plate_t, hook_w, hook_t]);          // bridge over the top
    translate([-box_t - fit - hook_t, 0, -hook_drop]) cube([hook_t, hook_w, hook_drop + fit + hook_t]);            // inner leg
}
module plate_B() {
    for (sy = [-1,1]) translate([fit, sy*hook_y - hook_w/2, -box_h + 6]) cube([plate_t, hook_w, box_h - 6 + fit + hook_t]);   // uprights
    translate([fit, -box_w/2 + 4, -box_h + 6]) cube([plate_t, box_w - 8, 10]);                                                  // bottom bar
    for (y = rib_y) translate([fit, y - rib_t/2, -box_h + 6]) cube([plate_t, rib_t, 24]);                                       // rib pads
}

// lip: a ruled surface. Each thin strip joins a short arc segment on the shell (just under the
// window) to the matching segment of a strip over the box end wall, so the lip stays lip_t thick.
lip_a0 = 128; lip_a1 = 252; lip_n = 30;   // inside the open arc (125..255), clear of the backbone ribs
module lip_tube() difference() {
    for (i = [0:lip_n-1]) let(a = lip_a0 + (lip_a1 - lip_a0)*i/lip_n, da = (lip_a1 - lip_a0)/lip_n,
                              y0 = box_w/2 - box_w*i/lip_n, dy = box_w/lip_n) hull() {
        translate([0,0,z_w0 - 1.5 - lip_t]) rotate(a) rotate_extrude(angle = da + 0.01) translate([R + 0.2, 0]) square([band_t, lip_t]);
        B() translate([-box_t - fit - hook_t, y0 - dy - 0.01, fit + hook_t - lip_t]) cube([box_t + 2*fit + hook_t + plate_t, dy + 0.02, lip_t]);
    }
    translate([0,0,-10]) cylinder(r = R + 0.2, h = 900);
}
// wings: vertical (world) side walls along the lip edges
module wings_tube() difference() {
    for (s = [-1,1]) hull() {
        translate([0,0,0]) rotate(s > 0 ? lip_a0 : lip_a1) translate([R + 0.2, -wing_t/2, z_w0 - 1.5 - lip_t]) cube([band_t, wing_t, wing_h]);
        B() translate([-box_t - fit - hook_t, s > 0 ? box_w/2 - wing_t : -box_w/2, fit]) cube([box_t + 2*fit + hook_t + plate_t, wing_t, wing_h]);
    }
    translate([0,0,-10]) cylinder(r = R + 0.2, h = 900);
}
// band: ring on the seat hoop (tube frame), below the pod bosses (shell v8.1 seat_drop 60), split at 140 / 320 deg
split = [140, 320];
module band_half(north = true) {
    ri = R + 0.3;
    difference() {
        union() {
            intersection() {
                translate([0,0,z_seat]) difference() { cylinder(r = ri + band_t, h = band_h); translate([0,0,-1]) cylinder(r = ri, h = band_h + 2); }
                rotate(north ? 230 : 50) translate([0, -400, 0]) cube([400, 800, 900]);
            }
            for (k = [0,1]) let(a = split[k], side = (k == 0) == north ? 1 : -1)
                rotate(a) translate([ri + band_t - 1, side > 0 ? 1 : -8, z_seat]) cube([10, 7, band_h]);
        }
        translate([0,0,-1]) cylinder(r = ri, h = 900);
        for (a = split) rotate(a) translate([ri + band_t + 4.5, 0, z_seat + band_h/2]) rotate([-90,0,0])
            if (north) translate([0,0,-m3_ins_l - 1]) cylinder(d = m3_ins_d, h = 2*m3_ins_l + 2, $fn = 24);
            else translate([0,0,-10]) cylinder(d = m3_clear, h = 20, $fn = 24);
    }
}
// ribs: back plate -> band
module ribs_tube() difference() {
    for (y = rib_y) hull() {
        translate([-sqrt(pow(R + 0.3 + band_t, 2) - y*y) - 0.5, y - rib_t/2, z_seat]) cube([1, rib_t, band_h]);   // on the band's outer face, clear of the seat hoop
        B() translate([fit + plate_t - 0.5, y - rib_t/2, -box_h + 6]) cube([0.5, rib_t, 24]);
    }
    translate([0,0,-10]) cylinder(r = R + 0.3, h = 900);
}

module mount_north() {
    band_half(true);
    ribs_tube();
    B() { plate_B(); hooks_B(); }
    lip_tube();
    wings_tube();
}
module mount_south() band_half(false);

module box_ghost() B() color("BurlyWood", 0.5) difference() {
    translate([-box_l, -box_w/2, -box_h]) cube([box_l, box_w, box_h]);
    translate([-box_l + box_t, -box_w/2 + box_t, -box_h - 1]) cube([box_l - 2*box_t, box_w - 2*box_t, box_h + 2]);
}

if (part == "assembly")    to_world() { color("Orange") mount_north(); color("Gold") mount_south(); box_ghost(); }
// lowest point of the north half = bottom of the back plate (tube frame)
function b2t_z(v) = let(a = -box_pitch, wx = O_w[0] + v[0]*cos(a) + v[2]*sin(a), wy = O_w[1] + v[1], wz = O_w[2] - v[0]*sin(a) + v[2]*cos(a))
                    -(wy - T_y)*sin(lean) + (wz - T_z)*cos(lean);
z_low = min(concat([z_seat], [for (y = [-box_w/2, box_w/2], x = [fit, fit + plate_t]) b2t_z([x, y, -box_h + 6])]));
if (part == "mount_north") translate([0,0,-z_low]) mount_north();     // lowest point on the bed; TREE SUPPORTS
if (part == "mount_south") translate([0,0,-z_seat]) mount_south();
