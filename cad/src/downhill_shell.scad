// =====================================================================
// Downhill Dispatcher — auger shell + sump + intake tray (v8: open top exit)
// v3..v6: rib/slot/hex lightening experiments.   v7: tower at the foot of the ramp.
// v8 (testing feedback 2026-11-20):
//   * TOP EXIT. The side ball port, dowel slot, spout pad and spouts are gone.
//     The upper piece stops as a full tube one auger pitch below the auger top
//     (z_w0). Above that only a 145 deg BACKBONE rises (bb_a0..bb_a1); the other
//     215 deg is open. Objects ride the flight into the open arc and roll off
//     the 40 deg umbrella flight sideways, mostly right at the backbone's
//     leading edge (bb_a0), into the sorter's collector (downhill_sorter.scad).
// v8.1: the open arc now faces NORTH (125..255 deg) so objects drop straight into the team's
//     rail box, hung on downhill_box_mount.scad. Objects leave heading north / north-west.
//     With the auger turning CW seen from above (the lifting direction for this
//     right-hand flight), the stream leaves heading west / north-west.
//   * The motor ARM (downhill_crown.scad) bolts to a pad on the backbone with
//     2x M3 from outside. Nothing crosses the opening.
//   * JOINTS: keyed 45 deg flanges + 2-piece V clamp (downhill_joint.scad),
//     replacing the 16 mm dry-fit sleeves. Bore is smooth across every joint.
//   * STIFFER: triangular hoops (1.6 mm proud, 45 deg both sides, no supports)
//     every ~3 hex rows stop the wall bulging out between flights.
//   * ANTI-SNAG pattern, identical on every piece and the tray wings: 4 mm AF
//     hex holes (were 5), 2.0 mm webs. A dowel lying across a hole now dips
//     0.5 mm into it (was 1.2 = the whole wall), so it can't catch an edge.
//     Underside 270 +/- 30 deg stays solid (objects ride there).
//   * All screw holes are heat-set insert holes (M3x4x5 in the pod bosses).
//   * Intake (sump + wings) geometry is unchanged from v7 (untested); it picks
//     up the new hole pattern and a hoop just above the intake window.
// ---------------------------------------------------------------------
// Tube frame: z = shell axis, z = 0 = underside of the sump floor.
//   -Y = low side (back, away from the ramp)   +Y = faces UP the ramp
//   +X = south, -X = north (ramp rises toward +Y = east)
// World frame (assembly): ramp's bottom edge = line y = 0, z = 0; ramp rises
//   toward +y at ramp_ang; tile floor z = 0.  world = place_tube(tube).
// CLI: openscad -D 'part="shell_upper"' -o shell_upper.stl downhill_shell.scad
// =====================================================================
use <downhill_joint.scad>

part = "assembly"; // [assembly, shell_lower, shell_middle, shell_upper, sump, wing_right, wing_left, pod, clamp_a, clamp_b, key]

/* [Auger (auger.scad v5)] */
auger_len   = 635;
auger_od    = 110;
tube_id     = 114;    // shell bore
auger_pitch = 63.5;   // total_len / turns

/* [Shell] */
wall      = 1.2;      // 3 lines @ 0.4 nozzle. PLA Aero: try 1.6
floor_t   = 2.4;      // sump floor
floor_hole = 5;       // floor lightening hexes (< 8 mm dowel)
n_pieces  = 3;

/* [Top exit (v8)] */
exit_h    = 64;       // open height below the auger top (>= one pitch, see header)
bb_a0     = 255;      // backbone: leading edge (objects leave here, CW travel). v8.1: open side faces NORTH (-X) into the sorter box
bb_a1     = 485;      // backbone: trailing edge (= 125, covers the pod at +Y). Open arc 125..255
bb_t      = 2.0;      // backbone wall (thicker than the tube)
bb_rib    = 3.0;      // vertical edge ribs: radial depth
bb_rib_w  = 4.0;
arm_a     = 20;       // motor arm direction (deg)
arm_zb    = 7;        // arm underside above the auger top (coupler boss top = 6)
arm_h     = 29;       // arm height -> backbone top = auger top + 36
arm_pad_w = 20;       // pad width (tangential)
arm_pad_t = 4.0;      // pad wall (radial)
arm_screw_dz = [7, 22]; // M3 screws above the arm underside
m3_clear  = 3.4;
wire_a    = [124, 256, 345, 40];  // v8.1 wire holes near the backbone top: 124/256 face the ball (north) side,
                                  // 345/40 the dowel (south) side. For wires holding the paper chutes / box stay
wire_d    = 3.0;
seat_drop = 60;       // collector clamp band sits on this hoop (its top), below the window bottom

/* [Hoops (v8)] */
hoops     = true;
hoop_d    = 1.6;      // radial
hoop_h    = 3.2;      // axial (triangle, 45 deg both sides)
hoop_rows = 4;        // hex rows per hoop pitch (~21 mm, 3 per flight pitch)

/* [Bottom pin for the 627 bearing] */
pin_mode    = "printed"; // [printed, steel]
pin_d       = 6.95;
steel_pin_d = 7.1;
pin_len     = 8;
shoulder_d  = 9.5;
shoulder_h  = 3;

/* [Layout (v7): tower at the foot of the ramp] */
lean        = 9;
ramp_ang    = 25.05;
ramp_zone   = 101.6;
edge_s      = 80;
ramp_in_w   = 295.3;
ramp_out_w  = 355.6;
ramp_len    = 914.4;
ramp_wall_h = 127;

/* [Sump + intake window (v7)] */
win_h     = 50;
win_a0    = 15;
win_a1    = 165;
lintel    = 8;
lip_h     = 6;
lip_t     = 1.6;
lip_fit   = 0.2;

/* [Intake tray (v7)] */
tray_t       = floor_t;
edge_t       = 0.4;
wing_t       = 1.6;
wing_top     = 75;
lip_w        = 6;
mouth_x      = 150;
mouth_margin = 8;
mouth_len    = 25;
float_gap    = 3;
split_x      = 100;
tab_d = 10; tab_neck = 6; tab_len = 6; tab_fit = 0.15;

/* [Lightening: hex grid (v8 anti-snag)] */
lite      = true;
hex_af    = 4;        // across flats (sideways); corners up/down -> no supports
hex_rib   = 2.0;      // web between holes (5 lines @ 0.4)
lite_a0   = -60;
lite_a1   = 240;      // underside 270 +/- 30 stays solid

/* [Electronics pod (upper face)] */
pod_gap    = 4;
plate_t    = 3;
plate_w    = 68;
plate_l    = 126;
end_band   = 8;
boss_d     = 9;
boss_inset = 5;
pod_screw_x = 28;     // M3x10 plate -> M3x4x5 insert in the boss
pod_top_gap = 4;
m3_ins_d   = 4.5;     // M3x4x5 insert hole
m3_ins_l   = 5;
standoff_hole = 2.9;
drv_hole_x = 49;  drv_hole_z = 58;
drv_from_top = 41;
batt_w = 28.7; batt_l = 53.7; strap_w = 2.6; strap_l = 14;
ano_hole_x = 30.48; ano_hole_z = 35.56;
ano_zc     = 30;

/* [Preview] */
show_ramp = true;

$fn = 120;

// ------------------------------ derived -------------------------------
Ri = tube_id/2;
R  = Ri + wall;
z_a0 = floor_t + shoulder_h - 0.2;        // auger bottom face
z_a1 = z_a0 + auger_len;                  // auger top face
z_w0 = z_a1 - exit_h;                     // window bottom (top of the full tube)
shell_len = z_a1 + arm_zb + arm_h;        // backbone top
z_rim = floor_t + win_h;                  // intake window top
z_seat = z_w0 - seat_drop;                // collector seat hoop (top of it)

// placement: tube frame -> world (rotate by lean about X, then translate)
Rs  = R + lip_fit + lip_t;
T_z = Rs*sin(lean);
T_y = edge_s*cos(ramp_ang) + floor_t*sin(lean)
      - (edge_s*sin(ramp_ang) - T_z - floor_t*cos(lean))/tan(lean);
module place_tube() translate([0, T_y, T_z]) rotate([lean,0,0]) children();
rk     = ramp_ang - lean;
ramp_c = sin(ramp_ang)*T_y - cos(ramp_ang)*T_z;
function ramp_z(y) = (ramp_c + sin(rk)*y)/cos(rk);
function ramp_y(z) = (z*cos(rk) - ramp_c)/sin(rk);
function tube_pt(s) = let(dy = s*cos(ramp_ang) - T_y, dz = s*sin(ramp_ang) - T_z)
                      [dy*cos(lean) + dz*sin(lean), -dy*sin(lean) + dz*cos(lean)];
function slope_s(y, z) = (T_y + y*cos(lean) - z*sin(lean))/cos(ramp_ang);
function world_z(y, z) = T_z + y*sin(lean) + z*cos(lean);
function world_pt(p) = [p[0], T_y + p[1]*cos(lean) - p[2]*sin(lean), T_z + p[1]*sin(lean) + p[2]*cos(lean)];

// tray outline (tube frame, right half; left is the mirror)
y_e  = ramp_y(floor_t - edge_t);
y_c0 = ramp_y(floor_t - tray_t);
y_m  = tube_pt(ramp_zone - mouth_margin)[0];
y_1  = y_m - mouth_len;
J    = [(R + 0.3)*cos(win_a0), (R + 0.3)*sin(win_a0)];
wing_pts = [[(R - 2)*cos(win_a0), (R - 2)*sin(win_a0)], [mouth_x, y_1], [mouth_x, y_m]];
y_split = J[1] + (split_x - J[0])*(y_1 - J[1])/(mouth_x - J[0]);
tab_ys  = [y_split + 0.3*(y_e - 20 - y_split), y_split + 0.75*(y_e - 20 - y_split)];

// pod (on the backbone)
pod_s  = shell_len - pod_top_gap - plate_l;
pod_y0 = R + pod_gap;
boss_ys = sqrt(R*R - pod_screw_x*pod_screw_x);
boss_D  = pod_y0 - boss_ys;
boss_z  = [pod_s + boss_inset, pod_s + plate_l - boss_inset];
boss_a  = [90 - asin(pod_screw_x/R), 90 + asin(pod_screw_x/R)];
// frame collar (downhill_frame.scad: collar_frac 0.55, collar_h 18)
collar_z = 0.55*shell_len;
// hex lightening
hex_hc = hex_af/cos(30);
hex_hp = hex_af + hex_rib;
hex_vp = hex_hp*sqrt(3)/2;
hoop_p = hoop_rows*hex_vp;               // hoop spacing
// pieces
splits = [for (i = [1:n_pieces-1]) round(i*shell_len/n_pieces)];
function pz0(i) = i == 0 ? floor_t : splits[i-1];
function pz1(i) = i == n_pieces - 1 ? shell_len : splits[i];
fh = fl_h();                              // flange height (joint lib)
// keep-outs for hoops (z bands): flanges, collar, collector seat region, pod bosses
function no_hoop(z) = [for (sp = splits) if (abs(z - sp) < fh + 6) 1] != [] ||
                      abs(z - collar_z) < 9 + hoop_h ||
                      z < z_rim + 3;
hoop_list = [for (k = [0:200]) let(z = z_rim + 4 + hoop_h/2 + k*hoop_p) if (z < z_seat - 2*hoop_h - 4 && !no_hoop(z)) z];
hoop_all  = concat(hoop_list, [z_seat - hoop_h/2]);

echo(str("SHELL v8: OD ", 2*R, "  length ", shell_len, "  auger ", z_a0, "..", z_a1, "  lean ", lean));
echo(str("EXIT: full tube up to z ", z_w0, " (", exit_h, " mm below the auger top); open arc ", 360 - (bb_a1 - bb_a0),
         " deg; window bottom above tile: west ", world_z(-R, z_w0), " mm (", world_z(-R, z_w0)/25.4, " in), north/south ", world_z(0, z_w0), " mm"));
echo(str("Backbone top above tile ", world_z(R, shell_len), " mm. Level 3 rim = 400 mm"));
echo(str("PLACE: tube axis ", -T_y, " mm in from the ramp's bottom edge"));
echo(str("Pieces (tall): ", [for (i = [0:n_pieces-1]) pz1(i) - pz0(i)], "  splits ", splits, "  hoops ", len(hoop_all), " at ", hoop_all));
for (i = [0:n_pieces-1]) assert(pz1(i) - pz0(i) <= 255, "piece too tall for the X2D");
for (z = splits) assert(abs(collar_z - z) > 9 + fh + 4, "frame collar lands on a joint");
assert(splits[n_pieces-2] < z_seat - 30, "collector seat must be on the top piece, clear of the joint");
assert(hex_hc < 7.5, "hex holes must stay smaller than a dowel (8 mm)");
assert(win_h < auger_pitch - 8 && win_h > 44, "intake window must fit a ball and stay under one pitch");
assert(exit_h >= auger_pitch, "exit window must be at least one pitch tall (objects must leave before the top)");
assert(pod_s > splits[n_pieces-2] + fh + 4, "pod must sit on the top piece");

// ------------------------------ helpers -------------------------------
module tube(r1, r2, z0, z1) translate([0,0,z0]) difference() {
    cylinder(r = r2, h = z1 - z0); translate([0,0,-1]) cylinder(r = r1, h = z1 - z0 + 2);
}

module sector(r, a0, a1, n = 48)
    polygon(concat([[0,0]], [for (i = [0:n]) let(a = a0 + (a1 - a0)*i/n) r*[cos(a), sin(a)]]));

// everything below the ramp surface (+ dz), tube frame
module below_ramp(dz = 0) translate([0, 0, ramp_c/cos(rk) + dz]) rotate([rk,0,0]) translate([-600,-600,-1200]) cube([1200,1200,1200]);

module hex_hole(a, z, t = wall) rotate(a) translate([Ri - 1, 0, z]) rotate([0,90,0])
    cylinder(d = hex_hc, h = t + 2, $fn = 6);

// triangular hoop, 45 deg both sides (prints either way up)
module hoop(z) translate([0,0,z]) rotate_extrude($fn = 160)
    polygon([[R - 0.01, -hoop_h/2], [R + hoop_d, 0], [R - 0.01, hoop_h/2]]);

// arc band (r1..r2, z0..z1) between angles a0..a1
module arc_band(r1, r2, z0, z1, a0, a1) rotate(a0) rotate_extrude(angle = a1 - a0, $fn = 160)
    translate([r1, z0]) square([r2 - r1, z1 - z0]);

// ------------------------------ intake window ---------------------------
module window_cut() translate([0,0,-1]) linear_extrude(z_rim + 1) sector(R + 10, win_a0, win_a1);

// ------------------------------ lightening (v8 hex) -------------------
module lite_cuts(spans, skip_window = false) {
    rm  = R - wall/2;
    da  = hex_hp/rm*180/PI;
    n   = floor((lite_a1 - lite_a0)/da);
    bda = (boss_d/2 + hex_rib + hex_af/2)/R*180/PI;
    for (s = spans) if (s[1] - s[0] > hex_hc + 1) {
        nz  = floor((s[1] - s[0] - hex_hc)/hex_vp) + 1;
        z00 = s[0] + (s[1] - s[0] - (nz - 1)*hex_vp)/2;
        for (j = [0:nz-1]) let(z = z00 + j*hex_vp, ph = j % 2, zl = z - hex_hc/2, zh = z + hex_hc/2)
            for (i = [0:n - 1 - ph]) let(a = lite_a0 + (i + 0.5 + ph/2)*da, an = (a + 360) % 360)
                if (!(skip_window && zl < z_rim + lintel && an > win_a0 - da && an < win_a1 + da) &&
                    [for (zb = boss_z, ab = boss_a)
                        if (zh > zb - boss_D - boss_d && zl < zb + boss_d && abs(a - ab) < bda) 1] == [])
                    hex_hole(a, z);
    }
}

// ------------------------------ pod bosses (M3x4x5 inserts) ------------
module pod_boss(x, zb) difference() {
    hull() {
        translate([x, 30, zb]) rotate([-90,0,0]) cylinder(d = boss_d, h = pod_y0 - 30, $fn = 32);
        translate([x, 30, zb - boss_D - 1]) rotate([-90,0,0]) cylinder(d = boss_d, h = boss_ys - 30, $fn = 32);
    }
    translate([0,0,zb - boss_D - 10]) cylinder(r = Ri, h = boss_D + 20);
    translate([x, pod_y0 + 1, zb]) rotate([90,0,0]) cylinder(d = m3_ins_d, h = m3_ins_l + 1.5, $fn = 24);
}
module pod_bosses() for (x = [-pod_screw_x, pod_screw_x], z = boss_z) pod_boss(x, z);

// ------------------------------ backbone + arm pad (v8) ------------------
arm_z = z_a1 + arm_zb;                     // arm underside
module backbone() {
    H0 = z_w0 - 2;
    difference() {
        union() {
            // wall, thickened outward with a 45 deg foot
            rotate(bb_a0) rotate_extrude(angle = bb_a1 - bb_a0, $fn = 160)
                polygon([[Ri, H0], [R, H0], [Ri + bb_t, H0 + bb_t - wall], [Ri + bb_t, shell_len], [Ri, shell_len]]);
            // vertical edge ribs (outside), 45 deg feet
            for (a = [bb_a0, bb_a1]) rotate(a) {
                w = bb_rib_w; s = a == bb_a0 ? 0 : -w;
                hull() {
                    translate([Ri + 0.5, s, z_w0 - 12]) cube([wall - 0.5, w, 1]);
                    translate([Ri + 0.5, s, z_w0 - 12 + bb_rib + 1]) cube([bb_t + bb_rib - 0.5, w, 1]);
                    translate([Ri + 0.5, s, shell_len - 1]) cube([bb_t + bb_rib - 0.5, w, 1]);
                }
            }
            // top rim rib (outside), 45 deg underside
            rotate(bb_a0) rotate_extrude(angle = bb_a1 - bb_a0, $fn = 160)
                polygon([[Ri + 0.5, shell_len - 3 - bb_rib], [Ri + bb_t + bb_rib, shell_len - 3], [Ri + bb_t + bb_rib, shell_len], [Ri + 0.5, shell_len]]);
            // arm pad
            rotate(arm_a) {
                a0 = -asin(arm_pad_w/2/Ri); a1 = -a0;
                rotate(a0) rotate_extrude(angle = a1 - a0, $fn = 160)
                    polygon([[Ri, arm_z - 8 - arm_pad_t], [Ri + bb_t, arm_z - 8 - arm_pad_t + bb_t - wall],
                             [Ri + arm_pad_t, arm_z - 8], [Ri + arm_pad_t, shell_len], [Ri, shell_len]]);
            }
        }
        // wire holes (radial, through wall + top rib)
        for (a = wire_a) rotate(a) translate([Ri - 3, 0, shell_len - 4]) rotate([0,90,0]) cylinder(d = wire_d, h = 20, $fn = 20);
        // arm screws (M3 clearance, radial; heads outside)
        rotate(arm_a) for (dz = arm_screw_dz) translate([Ri - 5, 0, arm_z + dz]) rotate([0,90,0]) cylinder(d = m3_clear, h = 20, $fn = 24);
        // keep the bore clean
        translate([0,0,H0 - 20]) cylinder(r = Ri, h = shell_len);
    }
}

// ------------------------------ shell pieces --------------------------
function cut_band(spans, c0, c1) = [for (sp = spans) each ((c1 <= sp[0] || c0 >= sp[1]) ? [sp] : [[sp[0], c0], [c1, sp[1]]])];
function cut_bands(spans, bands, k = 0) = k >= len(bands) ? spans : cut_bands(cut_band(spans, bands[k][0], bands[k][1]), bands, k + 1);
function lite_spans(i) = let(top = i == n_pieces - 1,
                             z0 = i == 0 ? floor_t + lip_h + 4 : pz0(i) + fh + 2,
                             z1 = top ? z_w0 - 3 : pz1(i) - fh - 2)
    cut_bands([[z0, z1]], concat([[collar_z - 11, collar_z + 11]],
                                 hoops ? [for (z = hoop_all) [z - hoop_h/2 - 1, z + hoop_h/2 + 1]] : []));

module shell_piece(i) {
    bot = i == 0; top = i == n_pieces - 1;
    z0 = pz0(i); z1 = top ? z_w0 : pz1(i);
    difference() {
        union() {
            tube(Ri, R, z0, z1);
            if (!top) flange(z1, 1, Ri, R);
            if (!bot) flange(z0, -1, Ri, R);
            if (hoops) for (z = hoop_all) if (z > z0 + fh + 2 && z < z1 - (top ? 1 : fh + 2)) hoop(z);
            if (top) { backbone(); pod_bosses(); }
        }
        if (!bot) key_notch(z0, 90, Ri, R, 1);
        if (!top) key_notch(z1, 90, Ri, R, -1);
        translate([0,0,z0 - 1]) cylinder(r = Ri, h = shell_len);
        if (bot) window_cut();
        if (lite) lite_cuts(lite_spans(i), skip_window = bot);
    }
}

// ------------------------------ sump + tray (v7) ----------------------
// 2D: funnel channel between the wing inner faces (both halves)
function chan_r() = concat([[0, J[1]]], wing_pts, [[0, y_m]]);
module chan2d() union() { polygon(chan_r()); mirror([1,0]) polygon(chan_r()); }

// 2D: wall band of width t on the outer side of the right wing path
module wing_band2d(t) intersection() {
    difference() { offset(delta = t) polygon(chan_r()); polygon(chan_r()); }
    translate([wing_pts[0][0] - 0.01, J[1] - 20]) square([400, y_m - J[1] + 20]);
}
// 2D: strip of width w on the inner side of segment p -> q (right wing)
module seg_in(p, q, w) let(d = q - p, L = norm(d), n = [-d[1], d[0]]/L) polygon([p, q, q + n*w, p + n*w]);

// right wing wall (3D, tube frame), before splitting
module wing_wall_r() {
    difference() {
        union() {
            translate([0,0,floor_t - tray_t]) linear_extrude(wing_top - floor_t + tray_t) wing_band2d(wing_t);
            for (k = [0:1]) let(p = wing_pts[k], q = wing_pts[k+1]) {            // top lip + 45 deg gusset
                translate([0,0,wing_top - 1.6]) linear_extrude(1.6) seg_in(p, q, lip_w);
                hull() {
                    translate([0,0,wing_top - 1.6]) linear_extrude(0.01) seg_in(p, q, lip_w);
                    translate([0,0,wing_top - 1.6 - lip_w]) linear_extrude(0.01) seg_in(p, q, 0.01);
                }
            }
        }
        translate([0,0,-1]) cylinder(r = R + 0.15, h = 300);                    // hug the shell
        // past the floor edge: float over the ramp, bottom rises at 45 deg (prints without support)
        rotate([90,0,90]) linear_extrude(800, center = true)
            polygon([[y_e, -60], [y_e, floor_t + float_gap - edge_t], [y_e + 400, floor_t + float_gap - edge_t + 400], [y_e + 400, -60]]);
        // hex lightening (corners up/down), clear of the floor and the lip
        for (k = [0:1]) let(p = wing_pts[k], q = wing_pts[k+1], d = q - p, L = norm(d), u = d/L,
                             nrm = [u[1], -u[0]], ang = atan2(nrm[1], nrm[0]),
                             nu = floor((L - 16)/hex_hp), nzr = floor((wing_top - lip_w - 6 - floor_t - 12 - hex_hc)/hex_vp) + 1)
            for (j = [0:nzr-1], i = [0:nu - 1 - j%2])
                let(t = 8 + hex_hp/2 + (i + (j%2)/2)*hex_hp, z = floor_t + 12 + hex_hc/2 + j*hex_vp, xy = p + u*t + nrm*wing_t/2)
                    if (xy[1] < y_e - 4 || z > floor_t + float_gap + (xy[1] - y_e) + 10)
                        translate([xy[0], xy[1], z]) rotate([0,0,ang]) rotate([0,90,0]) cylinder(d = hex_hc, h = wing_t + 2, center = true, $fn = 6);
    }
}

module puzzle2d(fit = 0) {   // male tab pointing -X from the split line, at the origin
    translate([-tab_len - tab_d/2 + 0.6, 0]) circle(d = tab_d + 2*fit, $fn = 40);
    translate([-tab_len - 0.01, -tab_neck/2 - fit]) square([tab_len + 1, tab_neck + 2*fit]);
}

// whole tray incl. sump, tube frame, unsplit
module tray_body() {
    difference() {
        union() {
            // tray floor (top flush with the sump floor top)
            translate([0,0,floor_t - tray_t]) linear_extrude(tray_t) intersection() {
                chan2d();
                translate([-400, -50]) square([800, y_e + 50]);
            }
            // sump floor
            cylinder(r = Rs, h = floor_t);
            // locating lip around the back of the shell (overlaps the window arc 15 deg -> holds it in place)
            translate([0,0,floor_t - 0.01]) difference() {
                linear_extrude(lip_h + 0.01) sector(R + lip_fit + lip_t, win_a1, win_a0 + 360);
                translate([0,0,-1]) cylinder(r = R + lip_fit, h = lip_h + 2);
            }
            // 627 shoulder + pin
            translate([0,0,floor_t - 0.01]) cylinder(d = shoulder_d, h = shoulder_h + 0.01, $fn = 48);
            if (pin_mode == "printed")
                translate([0,0,floor_t + shoulder_h - 0.01]) {
                    cylinder(d = pin_d, h = pin_len - 0.6, $fn = 48);
                    translate([0,0,pin_len - 0.61]) cylinder(d1 = pin_d, d2 = pin_d - 1.2, h = 0.6, $fn = 48);
                }
            wing_wall_r();
            mirror([1,0,0]) wing_wall_r();
        }
        below_ramp();                                                              // only the wedge edge meets the ramp
        if (pin_mode == "steel") translate([0,0,1]) cylinder(d = steel_pin_d, h = floor_t + shoulder_h, $fn = 48);
        // v8: tray floor lightening outside the tube (4 mm hexes, same anti-snag size), clear of the
        // wedge edge, the wing walls, the puzzle tabs and the sump lip
        translate([0,0,floor_t - tray_t - 1]) linear_extrude(tray_t + 2) intersection() {
            offset(delta = -(wing_t + 5)) chan2d();
            difference() {
                translate([-400, 0]) square([800, y_e - 14]);
                circle(r = Rs + 4);
                for (sx = [-1,1]) translate([sx*split_x - 14, -50]) square([28, 400]);
            }
            for (a = [-40:40], b = [0:40]) translate([a*(hex_af + hex_rib) + (b%2)*(hex_af + hex_rib)/2, b*(hex_af + hex_rib)*sin(60)])
                rotate(30) circle(d = hex_hc, $fn = 6);
        }
        // floor lightening inside the tube
        translate([0,0,-1]) linear_extrude(floor_t + 2) intersection() {
            difference() { circle(r = Ri - 4); circle(r = 14); }
            for (a = [-9:9], b = [-9:9]) translate([a*(floor_hole + 2.6) + (b%2)*(floor_hole + 2.6)/2, b*(floor_hole + 2.6)*sin(60)])
                rotate(30) circle(d = floor_hole/cos(30), $fn = 6);
        }
    }
}

module half_space_x(x0, keep_right) translate([keep_right ? x0 : x0 - 800, -400, -100]) cube([800, 800, 600]);

module sump() difference() {
    intersection() { tray_body(); translate([-split_x, -400, -100]) cube([2*split_x, 800, 600]); }
    for (s = [-1,1], y = tab_ys) translate([s*split_x, y, floor_t - tray_t - 1])
        mirror([s < 0 ? 1 : 0, 0, 0]) linear_extrude(tray_t + 2) puzzle2d(tab_fit);
}
module wing_part(s) {   // s = 1 right, -1 left
    mirror([s < 0 ? 1 : 0, 0, 0]) union() {
        intersection() { tray_body(); half_space_x(split_x, true); }
        for (y = tab_ys) intersection() {
            translate([split_x, y, floor_t - tray_t]) linear_extrude(tray_t) puzzle2d();
            difference() { translate([0,0,-50]) cube([400,400,100], center = false); below_ramp(); }
        }
    }
}


// ------------------------------ pod -----------------------------------
drv_zc = plate_l - drv_from_top;
function drv_holes() = [for (i = [-1,1], j = [-1,1]) [i*drv_hole_x/2, drv_zc + j*drv_hole_z/2]];
function ano_holes() = [for (i = [-1,1], j = [-1,1]) [i*ano_hole_x/2, ano_zc + j*ano_hole_z/2]];
function rib_holes() = [for (i = [-1,1], z = [boss_inset, plate_l - boss_inset]) [i*pod_screw_x, z]];
strap_x = batt_w/2 + 1.2 + strap_w/2;

module hex_grid(af = 9, rib = 2.2) {
    p = af + rib;
    for (i = [-6:6], j = [-1:15]) translate([i*p*cos(30), 0, j*p + (abs(i)%2)*p/2])
        rotate([90,0,0]) cylinder(d = af/cos(30), h = 40, center = true, $fn = 6);
}
module pod_keepouts() {
    for (h = concat(drv_holes(), ano_holes(), rib_holes())) translate([h[0], 0, h[1]]) rotate([90,0,0]) cylinder(r = 5.5, h = 80, center = true);
    for (sx = [-1,1]) translate([sx*strap_x - strap_w/2 - 2.5, -40, drv_zc - strap_l/2 - 2.5]) cube([strap_w + 5, 80, strap_l + 5]);
    translate([-50,-40,-1]) cube([100, 80, end_band + 3]);
    translate([-50,-40,plate_l - end_band - 2]) cube([100, 80, end_band + 3]);
}
module pod_plate() {
    difference() {
        translate([-plate_w/2, 0, 0]) cube([plate_w, plate_t, plate_l]);
        for (h = concat(drv_holes(), ano_holes())) translate([h[0], -1, h[1]]) rotate([-90,0,0]) cylinder(d = standoff_hole, h = plate_t + 2, $fn = 20);
        for (h = rib_holes()) translate([h[0], -1, h[1]]) rotate([-90,0,0]) cylinder(d = 3.4, h = plate_t + 2, $fn = 20);
        for (sx = [-1,1]) translate([sx*strap_x - strap_w/2, -1, drv_zc - strap_l/2]) cube([strap_w, plate_t + 2, strap_l]);
        intersection() {
            translate([0, plate_t/2, 0]) hex_grid();
            difference() { translate([-plate_w/2 + 3.5, -50, 3]) cube([plate_w - 7, 100, plate_l - 6]); pod_keepouts(); }
        }
    }
}
module elec_pod() translate([0, pod_y0, pod_s]) pod_plate();

// ------------------------------ assembly ------------------------------
module dummy_electronics() translate([0, pod_y0 + plate_t, pod_s]) {
    color("DimGray", 0.9)  translate([-batt_w/2, 0, drv_zc - batt_l/2]) cube([batt_w, 13.8, batt_l]);
    color("SeaGreen", 0.9) translate([-32.5, 16, drv_zc - 32.5]) cube([65, 1.6, 65]);
    color("Black", 0.9)    translate([-17.78, 16, ano_zc - 20.32]) cube([35.56, 1.6, 40.64]);
    color("Black", 0.9)    translate([0, 17.6, ano_zc]) rotate([-90,0,0]) cylinder(d = 31.4, h = 6);
}
// the ramp in WORLD coordinates (bottom edge on y = 0): green = 4 in contact zone
module ramp_world() {
    rotate([ramp_ang,0,0]) {
        color("Green", 0.35)     translate([-ramp_out_w/2, 0, -12]) cube([ramp_out_w, ramp_zone, 12]);
        color("BurlyWood", 0.35) translate([-ramp_out_w/2, ramp_zone, -12]) cube([ramp_out_w, ramp_len - ramp_zone, 12]);
        for (s = [-1,1]) color("SaddleBrown", 0.45)
            translate([s > 0 ? ramp_in_w/2 : -ramp_out_w/2, ramp_zone, 0]) cube([(ramp_out_w - ramp_in_w)/2, ramp_len - ramp_zone, ramp_wall_h]);
    }
}

// ------------------------------ assembly ------------------------------
module clamp_at(z) translate([0,0,z]) { color("Orange") clamp_half(true); color("Gold") rotate(180) clamp_half(false); }
module tube_parts(lower_only = false) {
    for (i = [0:(lower_only ? 0 : n_pieces-1)]) color(i % 2 ? "LightSteelBlue" : "SteelBlue", 0.75) shell_piece(i);
    if (!lower_only) for (z = splits) clamp_at(z);
    color("Orange") sump();
    color("Gold") { wing_part(1); wing_part(-1); }
    if (!lower_only) { color("Orange") elec_pod(); dummy_electronics(); }
}
module shell_assembly() {
    place_tube() tube_parts();
    if (show_ramp) ramp_world();
    color("LightGray", 0.4) translate([-241, -483, -1]) cube([482, 483, 1]);   // 19 x 19 in footprint (east edge on the ramp)
}

if (part == "assembly")     shell_assembly();
if (part == "shell_lower")  translate([0,0,pz1(0)]) rotate([180,0,0]) shell_piece(0);   // UPSIDE DOWN: flange face on the bed
if (part == "shell_middle") translate([0,0,-pz0(1)]) shell_piece(1);
if (part == "shell_upper")  translate([0,0,-pz0(n_pieces-1)]) shell_piece(n_pieces - 1);
if (part == "sump")         sump();                                        // floor down
if (part == "wing_right")   wing_part(1);
if (part == "wing_left")    wing_part(-1);
if (part == "pod")          rotate([90,0,0]) pod_plate();
if (part == "clamp_a")      translate([0,0,fh]) clamp_half(true);          // x2 (one per joint)
if (part == "clamp_b")      translate([0,0,fh]) clamp_half(false);         // x2
if (part == "key")          key_part();                                    // x2, loose clocking key

// values for other files that `use` this one
function shell_info() = [z_a0, z_a1, shell_len, R, lean, n_pieces, T_y, T_z, z_w0, bb_a0, bb_a1, arm_a, arm_z, arm_screw_dz, z_seat, Ri];
