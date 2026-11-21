// =====================================================================
// Downhill Dispatcher — SORTER concept v1 (Task 2): collector + height gate + chutes
// ---------------------------------------------------------------------
// Exploration for the team (they're designing their own hopper too).
// Passive, gravity only, no electronics:
//
//  1. COLLECTOR  clamps around the shell just below the v8 exit window
//     (2 halves, the band sits on the seat hoop, M3x12 + M3x6x5 inserts).
//     It covers the whole open arc. A planar floor tilted 12 deg in the tube
//     frame (21 deg in the world with the 9 deg lean) drains everything to
//     ONE outlet on the west side (tube -Y).
//  2. SPLITTER   a single printed block bolted to the collector outlet.
//     Objects land in a south-running channel. An angled FENCE crosses the
//     channel with its lower edge gate_h above the floor:
//        dowels (8 mm, lying down) roll / slide UNDER the fence -> south
//        balls (40 mm) can't pass; they roll along the 45 deg fence, out a
//        side door onto the ball channel 14 mm lower, hit the end stop
//        and roll back NORTH.
//     The dowel channel also tilts 6 deg toward the EAST wall, so dowels
//     roll away from the ball door (west wall); the fence still leads balls
//     west because the 10 deg run beats the 6 deg tilt.
//     Works for any dowel orientation (unlike slot/grate sorters) and
//     doesn't depend on speed. Print the splitter alone first and test it
//     with the real objects (part = "splitter").
//  3. CHUTES     printed U-channel segments (<= 230 mm), sleeve couplers,
//     1.75 mm filament pins. Balls -> NORTH box, dowels -> SOUTH box
//     (Figure 1: ping-pong box north, dowels box south; that's balls on the
//     right / dowels on the left when you face the device from the ramp).
//     Eyelets on every coupler for a fishing-line stay to the top of the
//     motor arm, so the long chutes can stay thin and light.
//
// Rules this respects (DBT V4): containers at Level 3 (rim 15.75 in = 400 mm),
// distance D from the footprint edge to the nearest container BASE, 4-24 in.
// The chutes may overhang the boxes but must never touch them, so the tips
// stop tip_clear above the rim, past the near rim.
// Set the distances, read the console: it prints each chute's slope and length.
// The dowel chute is the limiting one: dowels only roll crosswise and need
// ~8 deg+; balls roll at 3-4 deg.
//
// World frame = downhill_shell.scad assembly: ramp bottom edge on y = 0,
// tile z = 0, +Y = east (up the ramp), +X = south, -X = north.
// CLI: openscad -D 'part="splitter"' -o splitter.stl downhill_sorter.scad
// =====================================================================
use <downhill_shell.scad>
use <downhill_joint.scad>

part = "assembly"; // [assembly, collector_a, collector_b, splitter, gate_test, chute_ball, chute_dowel, sleeve, layout]

/* [Targets (inches, as on the score sheet)] */
D_ball   = 24;        // ping-pong box distance (4..24)
D_dowel  = 12;        // dowel box distance (4..24)
level_z  = 400;       // Level 3 rim (15.75 in)
tip_clear = 10;       // chute floor above the rim at the tip
tip_in   = 55;        // tip reaches this far past the near rim (over the opening)

/* [Collector] */
col_ro    = 120;      // outer wall radius (inner face)
col_beta  = 12;       // floor tilt in the tube frame (world = + lean)
col_t     = 1.2;      // floor
col_wall  = 1.0;
col_above = 15;       // wall top above the window bottom (tube frame)
col_lip   = 6;
band_t    = 1.6;      // clamp band
band_h    = 16;
col_a0    = 140;      // open arc is 125 -> 340; objects leave near 340 and travel CW, so the far end is trimmed
col_a1    = 338;      // backbone leading edge is at 340; objects leave moving CW (toward smaller angles), into the collector
col_split = 210;      // halves split here (band also splits at col_split - 180)
outlet_w  = 56;       // opening in the outer wall at 270 deg (chord)

/* [Splitter] */
cw        = 48;       // channel inside width (ball 40 + 8)
sp_wall   = 1.2;
sp_floor  = 1.2;
gate_h    = 14;       // fence lower edge above the floor: dowel 8 passes, ball 40 can't
fence_t   = 2.0;
land_drop = 6;        // landing floor below the collector outlet lip
s_land    = 10;       // splitter channel slope (deg)
s_cross   = 6;        // dowel channel cross-slope DOWN toward the east wall: keeps dowels away from the ball door
door_sill = 3;        // ball door lip above the (west) floor
s_ball    = 4;        // ball channel slope back north (deg)
tabs      = true;     // collector mounting tabs
drop_b    = 14;       // ball channel floor below the dowel floor at the door
wall_h    = 18;       // channel walls above the floor
back_h    = 36;       // back (west) wall at the landing

/* [Chutes] */
ch_w      = cw;
ch_floor  = 1.0;
ch_wall   = 0.8;      // 2 lines
ch_wall_h = 14;
seg_max   = 230;      // X2D bed diagonal is ~360; keep it printable flat
sl_len    = 30;       // sleeve length
sl_fit    = 0.2;
pin_d     = 1.9;      // 1.75 filament pins
lite_ch   = true;     // 4 mm hex holes in walls + floor (anti-snag size)

/* [Hardware] */
m3_ins_d  = 4.5;
m3_ins_l  = 6.5;
m3_clear  = 3.4;

$fn = 96;

// ------------------------------ shell numbers -------------------------
si = shell_info();     // [z_a0, z_a1, shell_len, R, lean, n_pieces, T_y, T_z, z_w0, bb_a0, bb_a1, arm_a, arm_z, arm_screw_dz, z_seat, Ri]
R = si[3]; lean = si[4]; T_y = si[6]; T_z = si[7]; z_w0 = si[8]; z_seat = si[14]; z_a1 = si[1];
function tw(p) = [p[0], T_y + p[1]*cos(lean) - p[2]*sin(lean), T_z + p[1]*sin(lean) + p[2]*cos(lean)];  // tube -> world
module to_world() translate([0, T_y, T_z]) rotate([lean,0,0]) children();
module to_tube() rotate([-lean,0,0]) translate([0, -T_y, -T_z]) children();

// collector floor plane (tube frame): top surface z = zf(y)
y_hi  = R*sin(col_a0);                                  // highest floor point at the shell, on the open arc
zf0   = z_w0 - 1.5 - y_hi*tan(col_beta);
function zf(y) = zf0 + y*tan(col_beta);
P_out = tw([0, -col_ro, zf(-col_ro)]);                  // outlet lip (world)

// splitter frame (world): origin at the landing, x south, channel spans y in [y_e - cw, y_e]
y_e  = P_out[1] - col_wall - 1.8;                       // channel east face: just outside the collector wall
z_l  = P_out[2] - land_drop;                            // landing floor at x = 0
x_n  = -outlet_w/2 - 8;                                 // north end wall
x_f0 = outlet_w/2 + 37;                                 // fence starts at the east wall here (door must clear the landing)
x_f1 = x_f0 + cw;                                       // ... and meets the west wall here
x_sp1 = x_f1 + 20;                                      // splitter ends (dowel exit)
// ball door: a ball rolling along the 45 deg fence meets the west wall with its centre r/tan(22.5) - r*sqrt2
// = 48 mm upstream of the fence corner, so the door is centred there (70 wide); the fence end lands on wall
x_dr1 = x_f1 - 5;  x_dr0 = x_dr1 - 70;
function zd(x) = z_l - (x - x_n)*tan(s_land);           // dowel floor in the splitter, at the EAST wall
function zw(x) = zd(x) + cw*tan(s_cross);               // ... at the WEST wall (door side)
yb_e = y_e - cw - sp_wall;                              // ball channel east face
z_b0 = zw(x_f1) + door_sill - drop_b;                   // ball floor at the door
x_bn = x_n - 10;                                        // ball exit (north end of the splitter)

// boxes (world): near base edge at the footprint edge + D, rims 1 in further in
fp = 241.3;  box_cy = -241.3;
function near_rim_x(D) = fp + D*25.4 - 25.4;
// chute runs (start -> tip, world). Chutes angle slightly in plan to hit the box centre line.
D0 = [x_sp1, y_e - cw/2, zd(x_sp1) + cw/2*tan(s_cross)];
D1 = [near_rim_x(D_dowel) + tip_in, box_cy, level_z + tip_clear];
B0 = [x_bn, yb_e - cw/2, z_b0 - (x_f1 + 8 - x_bn)*tan(s_ball)];
B1 = [-(near_rim_x(D_ball) + tip_in), box_cy, level_z + tip_clear];
function plan(a, b) = norm([b[0] - a[0], b[1] - a[1]]);
d_slope = atan((D0[2] - D1[2])/plan(D0, D1));
b_slope = atan((B0[2] - B1[2])/plan(B0, B1));
d_len = plan(D0, D1)/cos(d_slope);
b_len = plan(B0, B1)/cos(b_slope);
d_n = ceil(d_len/seg_max);  b_n = ceil(b_len/seg_max);

echo(str("COLLECTOR: floor ", col_beta, " deg (tube) / ~", col_beta + lean, " deg (world); outlet lip at world z ", P_out[2], " mm, y ", P_out[1]));
echo(str("SPLITTER: landing z ", z_l, ", fence lower edge ", gate_h, " mm above the floor, ball door floor z ", z_b0));
echo(str("DOWEL chute -> south box at D = ", D_dowel, " in: ", d_len, " mm long at ", d_slope, " deg, tip z ", D1[2], " (", d_n, " segments)"));
echo(str("BALL  chute -> north box at D = ", D_ball, " in: ", b_len, " mm long at ", b_slope, " deg, tip z ", B1[2], " (", b_n, " segments)"));
if (part != "gate_test") assert(d_slope >= 7.5, "dowel chute too flat (dowels need ~8 deg+): lower D_dowel");
assert(b_slope >= 3, "ball chute too flat: lower D_ball");
assert(D_ball >= 4 && D_ball <= 24 && D_dowel >= 4 && D_dowel <= 24, "distances must be 4..24 in");
assert(x_dr0 > outlet_w/2 + 8, "ball door runs into the landing");
assert(gate_h > 8 + 3 && gate_h < 40 - 12, "gate must pass a dowel and stop a ball");
if (part != "gate_test") assert(tan(s_land) > tan(s_cross) + 0.04, "fence won't lead balls west against the cross-slope");
echo(str("Chute tips over the boxes: dowel x ", D1[0], " (near rim ", near_rim_x(D_dowel), "), ball x ", B1[0], " (near rim ", -near_rim_x(D_ball), ")"));

// ------------------------------ helpers -------------------------------
module hexes2d(w, l, af = 4, rib = 2.0) {
    hc = af/cos(30); hp = af + rib; vp = hp*sqrt(3)/2;
    for (i = [0:floor(l/vp)], j = [0:floor(w/hp)]) translate([i*vp, j*hp + (i%2)*hp/2]) rotate(30) circle(d = hc, $fn = 6);
}
// slab between z = f(y) - t and f(y): built as a rotated big box (tube frame)
module floor_slab(t) translate([0, 0, zf0]) rotate([col_beta, 0, 0]) translate([-400, -400, -t]) cube([800, 800, t]);
module above_floor(dz = 0) translate([0, 0, zf0 + dz]) rotate([col_beta, 0, 0]) translate([-400, -400, 0]) cube([800, 800, 400]);
module below_floor(dz = 0) translate([0, 0, zf0 + dz]) rotate([col_beta, 0, 0]) translate([-400, -400, -400]) cube([800, 800, 400]);
module sector2d(r0, r1, a0, a1, n = 96)
    polygon(concat([for (i = [0:n]) let(a = a0 + (a1 - a0)*i/n) r1*[cos(a), sin(a)]],
                   [for (i = [n:-1:0]) let(a = a0 + (a1 - a0)*i/n) r0*[cos(a), sin(a)]]));

// ------------------------------ collector (tube frame) ----------------
module collector_full() {
    ri = R + 0.3;
    difference() {
        union() {
            // floor
            intersection() { floor_slab(col_t); translate([0,0,-10]) linear_extrude(800) sector2d(ri, col_ro + col_wall, col_a0, col_a1); }
            // outer wall + top lip (45 deg)
            intersection() {
                union() {
                    rotate(col_a0) rotate_extrude(angle = col_a1 - col_a0) translate([col_ro, 0]) square([col_wall, z_w0 + col_above]);
                    rotate(col_a0) rotate_extrude(angle = col_a1 - col_a0)
                        polygon([[col_ro + 0.01, z_w0 + col_above - col_lip - 1.6], [col_ro + 0.01, z_w0 + col_above], [col_ro - col_lip, z_w0 + col_above], [col_ro - col_lip, z_w0 + col_above - 1.6]]);
                }
                above_floor(-col_t);
            }
            // end walls of the arc (radial), up to the lip
            for (a = [col_a0, col_a1]) rotate(a) intersection() {
                translate([ri, a == col_a0 ? 0 : -col_wall, 0]) cube([col_ro - ri + col_wall, col_wall, z_w0 + col_above]);
                above_floor(-col_t);
            }
            // clamp band: full ring band_h tall on the seat hoop; under the floor arc it rises to meet the floor
            translate([0,0,z_seat]) difference() { cylinder(r = ri + band_t, h = band_h); translate([0,0,-1]) cylinder(r = ri, h = band_h + 2); }
            intersection() {
                translate([0,0,z_seat]) difference() { cylinder(r = ri + band_t, h = 200); translate([0,0,-1]) cylinder(r = ri, h = 202); }
                below_floor(-0.01);
                translate([0,0,-10]) linear_extrude(900) sector2d(0, 400, col_a0, col_a1);
            }
            // band ears at the two split points
            for (a = [col_split, col_split - 180]) rotate(a) for (s = [-1,1])
                translate([ri + band_t - 1, s > 0 ? 1 : -1 - 7, z_seat]) cube([10, 7, band_h]);
            // splitter mounting bosses (world-flat faces) either side of the outlet
            for (s = [-1,1]) to_tube() translate([s*(outlet_w/2 + 10), P_out[1] - 1.2, P_out[2] - 22]) intersection() {
                translate([-6, 0, 0]) cube([12, 14, 22]);
                to_world() cylinder(r = col_ro + col_wall + 8, h = 800);
            }
        }
        // bore
        translate([0,0,-1]) cylinder(r = ri, h = 800);
        // notches for the electronics-pod bosses (shell v8, +Y face at +-28 mm)
        for (sx = [-1,1]) translate([sx*28, R - 16, z_seat - 1]) hull() {
            cylinder(d = 14, h = band_h + 2); translate([0, 22, 0]) cylinder(d = 14, h = band_h + 2);
        }
        // outlet: opening in the wall + lip down to the floor
        intersection() {
            rotate(270) translate([col_ro - 5, -outlet_w/2, 0]) cube([30, outlet_w, 900]);
            above_floor(0);
        }
        // band ear screws (tangential)
        for (a = [col_split, col_split - 180]) rotate(a) translate([ri + band_t + 4.5, 0, z_seat + band_h/2]) rotate([-90,0,0]) {
            translate([0,0,-10]) cylinder(d = m3_clear, h = 10, $fn = 24);      // -y ear: clearance
            cylinder(d = m3_ins_d, h = m3_ins_l + 1, $fn = 24);                   // +y ear: M3x6x5 insert
        }
        // floor lightening (vertical 4 mm hexes), clear of the outlet and the band
        if (lite_ch) intersection() {
            translate([0,0,-10]) linear_extrude(900) difference() {
                sector2d(ri + 8, col_ro - 6, col_a0 + 4, col_a1 - 4);
                rotate(270) translate([col_ro - 40, -outlet_w/2 - 6]) square([60, outlet_w + 12]);
                translate([-200, -200]) hexes_mask();
            }
            floor_slab(col_t + 2);
        }
        // splitter bolts: M3 inserts, world-horizontal (along -y)
        for (s = [-1,1], dz = [-8, -16]) to_tube() translate([s*(outlet_w/2 + 10), P_out[1] - 2, P_out[2] + dz]) rotate([-90,0,0]) cylinder(d = m3_ins_d, h = m3_ins_l + 1, $fn = 24);
    }
}
module hexes_mask() difference() { square([400, 400]); hexes2d(400, 400); }

module collector_half(which) {   // "a": col_a0..col_split (north side), "b": col_split..col_a1 (west/outlet)
    a0 = which == "a" ? col_split - 180 : col_split;
    a1 = which == "a" ? col_split : col_split + 180;
    intersection() {
        collector_full();
        translate([0,0,-10]) linear_extrude(900) sector2d(0, 400, a0, a1, 64);
    }
    // the halves' floors join with an overlap tab + insert at col_split (b has the tab)
    if (which == "b") intersection() {
        rotate(col_split) translate([R + 10, -12, 0]) cube([col_ro - R - 20, 12, 900]);
        difference() { floor_slab(col_t + 2.4); floor_slab(col_t); }
        rotate(col_split) translate([0, -400, 0]) cube([400, 400, 900]);
    }
}

// ------------------------------ splitter (world frame) ---------------
// a channel block: floor descends toward +x (dir=1) or -x (dir=-1)
// z_at = floor height at the EAST inner face at x0 (dir = 1) or x1 (dir = -1); cross = tilt down toward the east
module channel(x0, x1, ye, w, z_at, slope, dir, h, walls = [true, true], floor_t = sp_floor, cross = 0) {
    L = x1 - x0;
    translate([x0, ye - w - sp_wall, 0]) multmatrix([[1,0,0,0],[0,1,0,0],
            [-dir*tan(slope), -tan(cross), 1, z_at + (dir > 0 ? 0 : -L*tan(slope)) + (w + sp_wall)*tan(cross)],[0,0,0,1]]) {
        translate([0, sp_wall, -floor_t]) cube([L, w, floor_t]);
        if (walls[0]) translate([0, w + sp_wall, -floor_t]) cube([L, sp_wall, h + floor_t]);   // east
        if (walls[1]) translate([0, 0, -floor_t]) cube([L, sp_wall, h + floor_t]);            // west
    }
}
module splitter() {
    difference() {
        union() {
            // dowel channel (landing -> fence -> exit), east wall only clear of the outlet
            channel(x_n, x_sp1, y_e, cw, z_l, s_land, 1, wall_h, [false, true], cross = s_cross);
            channel(x_f0 - 2, x_sp1, y_e, cw, zd(x_f0 - 2), s_land, 1, wall_h, [true, false], cross = s_cross);
            // tall back wall at the landing (objects arrive moving -y)
            translate([x_n, y_e - cw - sp_wall, zd(x_dr0) - sp_floor]) cube([x_dr0 - x_n, sp_wall, back_h + (x_dr0 - x_n)*tan(s_land)]);
            // north end wall
            translate([x_n - sp_wall, y_e - cw - sp_wall, zd(x_n) - sp_floor]) cube([sp_wall, cw + 2*sp_wall, back_h]);
            // fence: 45 deg across the channel, lower edge gate_h above the floor
            intersection() {
                hull() for (p = [[x_f0, y_e, 0], [x_f1, y_e - cw, cw*tan(s_cross)]]) translate([p[0], p[1], zd(p[0]) + p[2] + gate_h]) cylinder(d = fence_t, h = 60, $fn = 16);
                translate([x_n, y_e - cw, 0]) cube([x_sp1 - x_n, cw, zd(x_f0) + wall_h + 20]);
            }
            // ball channel: from the door, back north to the splitter's north end
            channel(x_bn, x_f1 + 8, yb_e, cw, z_b0, s_ball, -1, wall_h + drop_b, [false, true]);
            translate([x_f1 + 8, yb_e - cw - sp_wall, z_b0 - sp_floor]) cube([sp_wall, cw + sp_wall + 0.01, wall_h + drop_b + 4]);   // end stop
            // mounting tabs to the collector bosses (y = P_out[1] - 1.2 face)
            if (tabs) for (s = [-1,1]) translate([s*(outlet_w/2 + 10) - 6, P_out[1] - 1.2 - 3, P_out[2] - 22]) cube([12, 3, 22]);
        }
        // ball door in the west wall at the fence end
        hull() for (x = [x_dr0, x_dr1 - 0.01]) translate([x, y_e - cw - sp_wall - 1, zw(x) + door_sill]) cube([0.01, sp_wall + 2, 60]);
        // tab bolts
        for (s = [-1,1], dz = [-8, -16]) translate([s*(outlet_w/2 + 10), P_out[1] + 1, P_out[2] + dz]) rotate([90,0,0]) cylinder(d = m3_clear, h = 10, $fn = 24);
    }
}

// ------------------------------ chutes --------------------------------
// one straight chute from (x0,z0) to (x1,z1) at y in [ye - w, ye], split into n segments
module u_seg(L, eyelet = true) {
    difference() {
        union() {
            translate([0, 0, 0]) cube([L, ch_w + 2*ch_wall, ch_floor]);
            for (y = [0, ch_w + ch_wall]) translate([0, y, 0]) cube([L, ch_wall, ch_floor + ch_wall_h]);
            if (eyelet) for (y = [-3, ch_w + 2*ch_wall]) translate([L - 14, y, ch_floor + ch_wall_h - 6]) cube([8, 3, 6]);
        }
        if (eyelet) for (y = [-3, ch_w + 2*ch_wall]) translate([L - 10, y - 1, ch_floor + ch_wall_h - 3]) rotate([-90,0,0]) cylinder(d = 2.0, h = 6, $fn = 12);
        for (x = [7, L - 7], y = [-1]) translate([x, y, ch_floor + ch_wall_h/2]) rotate([-90,0,0]) cylinder(d = pin_d, h = ch_w + 4, $fn = 12);
        if (lite_ch && L > 40) {
            translate([18, ch_wall + 3, -1]) linear_extrude(ch_floor + 2) intersection() { square([L - 36, ch_w - 6]); translate([-200,-200]) hexes2d(600, 600, 4, 1.6); }
            for (y = [-1, ch_w + ch_wall - 1]) translate([18, y, ch_floor + 3]) rotate([90,0,0]) mirror([0,0,1])
                linear_extrude(ch_wall + 2) intersection() { square([L - 36, ch_wall_h - 5]); translate([-200,-200]) rotate(90) hexes2d(600, 600, 6, 1.6); }
        }
    }
}
module sleeve() {   // outer U, upstream half 0.6 higher so every seam steps DOWN
    wi = ch_w + 2*ch_wall + 2*sl_fit; t = 1.2;
    difference() {
        translate([0, -t, -t]) cube([sl_len, wi + 2*t, ch_floor + ch_wall_h - 4 + t]);
        translate([-1, 0, 0]) cube([sl_len + 2, wi, 50]);
        translate([sl_len/2, -t - 1, -t - 1]) cube([sl_len, wi + 2*t + 2, 0.6 + 1]);   // downstream half lower
        for (x = [7, sl_len - 7]) translate([x, -t - 1, ch_floor + ch_wall_h/2]) rotate([-90,0,0]) cylinder(d = pin_d, h = wi + 2*t + 2, $fn = 12);
    }
}
module chute(P0, P1, n) {
    Lp = plan(P0, P1); sl = atan((P0[2] - P1[2])/Lp); psi = atan2(P1[1] - P0[1], P1[0] - P0[0]);
    seg = Lp/cos(sl)/n;
    translate([P0[0], P0[1], P0[2] - ch_floor]) rotate(psi) rotate([0, sl, 0]) translate([0, -(ch_w/2 + ch_wall), 0])
        for (k = [0:n-1]) translate([k*seg, 0, 0]) {
            u_seg(seg - 1);
            if (k > 0) color("Orange") translate([-sl_len/2, -sl_fit, -0.01]) sleeve();
        }
}

// ------------------------------ layout --------------------------------
module boxes() {
    for (s = [-1,1]) let(D = s < 0 ? D_ball : D_dowel, xn = fp + D*25.4) color(s < 0 ? "White" : "Tan", 0.35)
        translate([s*xn, box_cy, 0]) mirror([s < 0 ? 1 : 0, 0, 0]) {
            hull() {                                             // stacked: top box rim at 400
                translate([0, -101.6, 0]) cube([146, 203.2, 1]);
                translate([-25.4, -127, level_z - 1]) cube([196.85, 254, 1]);
            }
        }
}
module sorter_assembly() {
    to_world() { color("Khaki", 0.85) collector_half("a"); color("DarkKhaki", 0.85) collector_half("b"); }
    color("Coral") splitter();
    color("Wheat") chute(D0, D1, d_n);
    color("Wheat") chute(B0, B1, b_n);
    boxes();
}

if (part == "assembly")    sorter_assembly();
if (part == "layout")      { sorter_assembly(); use_shell_preview(); }
if (part == "collector_a") collector_half("a");
if (part == "collector_b") collector_half("b");
if (part == "splitter")    splitter();
// GATE TEST: the splitter's fence / door / ball-channel region with every slope set to 0 and a
// solid plinth under the dowel channel, so it prints flat with no supports. Prop it at 10 deg
// (toward the dowel exit) and 6 deg (down toward the east wall) to test. Export with:
//   -D part="gate_test" -D s_land=0 -D s_cross=0 -D s_ball=0 -D tabs=false
module gate_test() {
    xa = x_dr0 - 15;
    zb = z_b0 - sp_floor;                                   // ball floor underside = the bed
    translate([-xa, 0, -zb]) {
        intersection() { splitter(); translate([xa, -1000, -1000]) cube([x_sp1 - xa + 1, 2000, 3000]); }
        translate([xa, y_e - cw - sp_wall, zb]) cube([x_sp1 - xa, cw + 2*sp_wall, zd(0) - sp_floor - zb + 0.01]);
    }
}
if (part == "gate_test")   gate_test();
if (part == "chute_ball")  u_seg(b_len/b_n - 1);
if (part == "chute_dowel") u_seg(d_len/d_n - 1);
if (part == "sleeve")      sleeve();
module use_shell_preview() {}
