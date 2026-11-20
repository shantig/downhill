// =====================================================================
// Downhill Dispatcher — auger shell + sump + intake tray (v7: tower at the foot of the ramp)
// v3: v2 ribs (2 mm) flexed and snagged/broke -> 4 mm ribs, 24 mm rows, 5 mm rings.
// v4: rim slots for the drop-in motor bar (downhill_top_bar.scad).
// v5: shell sat on the ramp at 25 deg with floating hopper wings (retired).
// v6: hex lightening (5 mm AF, 2.4 mm webs, corners up/down) in place of slots.
// v7: tower moved OFF the ramp, centred at its foot. Objects were thrown back
//     out of the 127 mm-tall v5 intake by the spinning flight.
//   * The intake floor is ONE plane from the ramp down into the tube: the tray
//     floor and the sump floor are coplanar, perpendicular to the tube axis.
//     That plane can only reach the ramp below the 4 in line if the tube leans
//     ~9 deg (it was 25). lean is a parameter; edge_s sets where the tray meets
//     the ramp.
//   * The tray's uphill edge is a 15-16 deg wedge whose underside rests on the
//     ramp (allowed contact, < 4 in) and whose top is flush with the ramp, so
//     objects roll on with no step. Wings funnel the 11.625 in lane down to
//     the intake; past the floor edge they float 3+ mm above the ramp and stop
//     8 mm short of the 4 in line.
//   * Intake = 150 deg arc, 50 mm tall: lower than one auger pitch (63.5) and
//     taller than a 40 mm ball. Anything flung out lands on the tray, which
//     slopes back into the sump.
//   * The floor, 627 pin and a locating lip moved from shell_lower to the new
//     sump. shell_lower is a plain tube whose back half stands on the sump
//     floor inside the lip; its front half stops at the window top. It prints
//     UPSIDE DOWN (sleeve on the bed) so the window top is not a bridge.
//   * The tray is wider than the X2D bed (256), so it splits at x = +/-100:
//     sump (centre) + wing_left + wing_right, joined by drop-in puzzle tabs.
//   * Spout tilt now follows the lean (still 15 deg below horizontal).
//     middle / upper pieces are unchanged from v6.
// ---------------------------------------------------------------------
// Tube frame: z = shell axis, z = 0 = underside of the sump floor.
//   -Y = low side (back, away from the ramp)   +Y = faces UP the ramp
// World frame (assembly): ramp's bottom edge = line y = 0, z = 0; ramp rises
//   toward +y at ramp_ang; tile floor z = 0.  world = place_tube(tube).
// CLI: openscad -D 'part="sump"' -o sump.stl downhill_shell.scad
// =====================================================================

part = "assembly"; // [assembly, shell_lower, shell_middle, shell_upper, sump, wing_right, wing_left, spout_ball, spout_dowel, pod]

/* [Auger (from auger.scad v5)] */
auger_len   = 635;
auger_od    = 110;
tube_id     = 114;    // shell bore
auger_pitch = 63.5;   // total_len / turns

/* [Shell] */
wall      = 1.2;      // 3 lines @ 0.4 nozzle (set wall line width 0.40)
floor_t   = 2.4;      // sump floor
floor_hole = 5;       // floor lightening hexes (< 8 mm dowel)
rim_z     = 10;       // shell rim above auger top (= rim_z in downhill_top_drive.scad)
n_pieces  = 3;        // ~217 mm each (X2D: 260 mm Z)
sleeve_h  = 16;       // dry-fit joints: pack it apart, push together on site
sleeve_t  = 1.6;
sleeve_fit = 0.15;    // radial (a wrap of tape if loose)

/* [Bottom pin for the 627 bearing] */
pin_mode    = "printed"; // [printed, steel]
pin_d       = 6.95;   // printed pin, snug in the 7 mm bore
steel_pin_d = 7.1;    // socket for a 7 mm steel pin / drill blank (glue in)
pin_len     = 8;      // above the shoulder
shoulder_d  = 9.5;    // touches the inner race only
shoulder_h  = 3;

/* [Layout (v7): tower at the foot of the ramp] */
lean        = 9;      // deg from vertical. Larger moves the ramp contact up toward the 4 in line
ramp_ang    = 25.05;  // +/- 0.45
ramp_zone   = 101.6;  // 4 in contact zone, along the slope from the ramp's bottom edge
edge_s      = 80;     // tray floor meets the ramp this far up the slope
ramp_in_w   = 295.3;  // 11.625 in between the ramp side walls. MEASURE the real ramp
ramp_out_w  = 355.6;  // 14 in deck (side walls start at the 4 in line)
ramp_len    = 914.4;  // 36 in
ramp_wall_h = 127;    // 5 in

/* [Sump + intake window (v7)] */
win_h     = 50;       // window height above the floor (< pitch 63.5, > 40 mm ball)
win_a0    = 15;       // window arc (deg CCW from +X; +Y = 90 faces the ramp)
win_a1    = 165;
lintel    = 8;        // solid band above the window
lip_h     = 6;        // locating lip around the back of the shell
lip_t     = 1.6;
lip_fit   = 0.2;

/* [Intake tray (v7)] */
tray_t       = floor_t; // floor thickness (= sump floor, so the whole underside prints flat on the bed)
edge_t       = 0.4;   // thickness at the uphill edge (top sits this far above the ramp there)
wing_t       = 1.6;
wing_top     = 75;    // above the sump floor top
lip_w        = 6;     // inward lip on top of the wings
mouth_x      = 150;   // wing inner face at the mouth (ramp walls are at 147.6)
mouth_margin = 8;     // wings stop this far below the 4 in line
mouth_len    = 25;    // straight lead-in at the mouth
float_gap    = 3;     // wing clearance over the ramp past the floor edge
split_x      = 100;   // tray splits here (X2D bed is 256)
tab_d = 10; tab_neck = 6; tab_len = 6; tab_fit = 0.15;   // drop-in puzzle tabs

/* [Exits on the underside] */
ball_w       = 70;    // ball port chord width (balls are 40 mm)
ball_rect_h  = 12;    // straight part; roof adds ball_w/2*tan(ball_roof)
ball_roof    = 50;
ball_top_gap = 7;     // port top this far below the auger top
dow_w        = 70;    // dowel slot chord width
dow_h        = 13;    // slot height (dowel 8 mm, ball 40 mm can't pass)
dow_chamfer  = 2.5;   // inner top-edge chamfer so balls don't catch
pad_t        = 3;     // spout pad thickness (outside the wall)
pad_m        = 14;    // pad margin around the openings (screws sit outside the spout walls)
pilot_d      = 2.5;   // M3 self-tap pilot

/* [Spouts] */
spout_drop  = 15;     // deg below horizontal (dowels roll crosswise)
spout_len   = 50;
spout_wall  = 1.2;
spout_floor = 1.6;
flange_t    = 2.0;

/* [Lightening: hex grid (v6)] */
lite      = true;
hex_af    = 5;        // across flats (sideways); corners point up/down -> no supports
hex_rib   = 2.4;      // web between holes (6 lines @ 0.4)
top_solid = 40;       // no holes in the top 40 mm (pad corners, pod bosses, motor-cap rim)
lite_a0   = -60;      // arc that gets holes (deg, CCW from +X; +Y = 90)
lite_a1   = 240;      // underside 270 +/- 30 stays solid (objects ride here)

/* [Motor-bar rim slots (downhill_top_bar.scad)] */
bar_slots   = true;
bar_slot_w  = 5.4;    // tenon 5 + 0.2 per side
bar_slot_z  = 6.8;    // slot floor above the auger top face (bar underside 7 - 0.2)

/* [Electronics pod (upper face)] */
pod_gap    = 4;
plate_t    = 3;
plate_w    = 68;
plate_l    = 126;
end_band   = 8;       // plate ends kept solid
boss_d     = 9;
boss_inset = 5;       // boss centre from plate end
pod_screw_x = 28;     // M3x10 plate -> boss
pod_top_gap = 12;     // clear of the motor-cap skirt (10 mm)
standoff_hole = 2.9;  // M2.5
drv_hole_x = 49;  drv_hole_z = 58;   // General Driver for Robots, 65x65
drv_from_top = 41;                    // driver board centre below plate top
batt_w = 28.7; batt_l = 53.7; strap_w = 2.6; strap_l = 14;
ano_hole_x = 30.48; ano_hole_z = 35.56;
ano_zc     = 30;                      // ANO adapter centre above plate bottom

/* [Preview] */
show_ramp = true;

$fn = 120;

// ------------------------------ derived -------------------------------
Ri = tube_id/2;
R  = Ri + wall;
z_a0 = floor_t + shoulder_h - 0.2;        // auger bottom face (bearing sits 0.2 proud)
z_a1 = z_a0 + auger_len;                  // auger top face
shell_len = z_a1 + rim_z;
z_rim = floor_t + win_h;                  // window top = front bottom edge of shell_lower
spout_tilt = spout_drop - lean;           // vs. tube frame

// placement: tube frame -> world (rotate by lean about X, then translate)
Rs  = R + lip_fit + lip_t;                // sump floor radius
T_z = Rs*sin(lean);                       // low edge of the sump floor touches the tile
T_y = edge_s*cos(ramp_ang) + floor_t*sin(lean)
      - (edge_s*sin(ramp_ang) - T_z - floor_t*cos(lean))/tan(lean);
module place_tube() translate([0, T_y, T_z]) rotate([lean,0,0]) children();
// the ramp surface in the tube frame: z = ramp_z(y)
rk     = ramp_ang - lean;
ramp_c = sin(ramp_ang)*T_y - cos(ramp_ang)*T_z;
function ramp_z(y) = (ramp_c + sin(rk)*y)/cos(rk);
function ramp_y(z) = (z*cos(rk) - ramp_c)/sin(rk);
function tube_pt(s) = let(dy = s*cos(ramp_ang) - T_y, dz = s*sin(ramp_ang) - T_z)
                      [dy*cos(lean) + dz*sin(lean), -dy*sin(lean) + dz*cos(lean)];   // ramp point s -> [y, z]
function slope_s(y, z) = (T_y + y*cos(lean) - z*sin(lean))/cos(ramp_ang);           // tube point on the ramp -> s
function world_z(y, z) = T_z + y*sin(lean) + z*cos(lean);

// tray outline (tube frame, right half; left is the mirror)
y_e  = ramp_y(floor_t - edge_t);          // uphill edge of the floor
y_c0 = ramp_y(floor_t - tray_t);          // ramp contact starts here (wedge underside)
y_m  = tube_pt(ramp_zone - mouth_margin)[0];
y_1  = y_m - mouth_len;
J    = [(R + 0.3)*cos(win_a0), (R + 0.3)*sin(win_a0)];   // wing meets the shell at the window jamb
wing_pts = [[(R - 2)*cos(win_a0), (R - 2)*sin(win_a0)], [mouth_x, y_1], [mouth_x, y_m]];
y_split = J[1] + (split_x - J[0])*(y_1 - J[1])/(mouth_x - J[0]);   // wing crosses the split line
tab_ys  = [y_split + 0.3*(y_e - 20 - y_split), y_split + 0.75*(y_e - 20 - y_split)];

// ball port
ball_roof_h = ball_w/2 * tan(ball_roof);
bp_z1 = z_a1 - ball_top_gap;
bp_z0 = bp_z1 - ball_rect_h - ball_roof_h;
// dowel slot (helical, follows the flight)
dow_ang  = 2*asin((dow_w/2)/R);
dow_dz   = dow_ang/2/360*auger_pitch;
dfl_top  = bp_z0 - 0.5 - spout_floor - 1;
dow_zc   = dfl_top - 3 - dow_dz - dow_h/2;
dow_low  = dow_zc - dow_h/2 - dow_dz;
// spout pad
pad_hw = max(ball_w, dow_w)/2 + pad_m;
pad_z0 = dow_low - 0.5 - spout_floor - 3;
pad_z1 = z_a1 - 1;
// pod
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
// pieces
splits = [for (i = [1:n_pieces-1]) round(i*shell_len/n_pieces)];
function pz0(i) = i == 0 ? floor_t : splits[i-1];
function pz1(i) = i == n_pieces - 1 ? shell_len : splits[i];
function exit_h(z) = world_z(-R, z);      // height above the tile of an underside point

echo(str("SHELL: OD ", 2*R, "  length ", shell_len, "  auger ", z_a0, "..", z_a1, "  lean ", lean));
echo(str("HEIGHT above tile: ball sill ", exit_h(bp_z0), " mm (", exit_h(bp_z0)/25.4, " in), dowel low sill ",
         exit_h(dow_low), " mm.  Rim ", world_z(-R, shell_len), " mm (", world_z(-R, shell_len)/25.4, " in).  Level 3 = 400 mm"));
echo(str("PLACE: tube axis (floor centre) ", -T_y, " mm in from the ramp's bottom edge; sump low edge on the tile ",
         -(T_y - Rs*cos(lean)), " mm in"));
echo(str("RAMP CONTACT: tray edge rests on the ramp from s = ", slope_s(y_c0, floor_t - tray_t), " to ", slope_s(y_e, floor_t - edge_t),
         " mm up the slope (4 in = ", ramp_zone, ").  Wings reach s = ", slope_s(y_m, ramp_z(y_m)), " mm, ", float_gap, "+ mm above the ramp"));
echo(str("INTAKE: floor slope ", lean, " deg; window ", win_a1 - win_a0, " deg arc (", 2*Ri*sin((win_a1 - win_a0)/2), " mm chord) x ", win_h, " mm"));
echo(str("TRAY: mouth ", 2*(mouth_x + wing_t), " mm outside, funnel ", y_m - J[1], " mm long; wings ", atan((mouth_x - J[0])/(y_1 - J[1])), " deg to the flow"));
echo(str("Pieces (tall): ", [for (i = [0:n_pieces-1]) pz1(i) - pz0(i) + (i < n_pieces - 1 ? sleeve_h : 0)], "  splits ", splits));
for (i = [0:n_pieces-1]) assert(pz1(i) - pz0(i) + sleeve_h <= 255, "piece too tall");
for (z = splits) assert(collar_z - 11 > z + sleeve_h || collar_z + 11 < z, "collar lands on a joint sleeve");
assert(pad_z0 - pad_t > splits[n_pieces-2] + sleeve_h + 2, "exits must sit on the top piece");
assert(hex_hc < 7.5, "hex holes must stay smaller than a dowel (8 mm)");
assert(win_h < auger_pitch - 8 && win_h > 44, "window must fit a ball and stay under one pitch");
assert(slope_s(y_m, ramp_z(y_m)) < ramp_zone - 5, "wings reach past the 4 in line");
assert(slope_s(y_e, floor_t) < ramp_zone - 10, "ramp contact too close to the 4 in line");
assert(T_y + Rs*cos(lean) < 0, "sump overhangs the ramp's bottom edge");
assert(y_split < y_e - 30, "split line misses the floor");

// ------------------------------ helpers -------------------------------
module helix_band(prof, a0, a1, zc, pitch, n = 40) {
    m = len(prof);
    pts = [for (i = [0:n]) let(a = a0 + (a1 - a0)*i/n, dz = (a - (a0 + a1)/2)/360*pitch)
             for (p = prof) [p[0]*cos(a), p[0]*sin(a), zc + dz + p[1]]];
    sides = [for (i = [0:n-1], k = [0:m-1]) [m*i + k, m*i + (k+1)%m, m*(i+1) + (k+1)%m, m*(i+1) + k]];
    caps  = [[for (k = [m-1:-1:0]) k], [for (k = [0:m-1]) m*n + k]];
    polyhedron(pts, concat(sides, caps), convexity = 4);
}

module tube(r1, r2, z0, z1) translate([0,0,z0]) difference() {
    cylinder(r = r2, h = z1 - z0); translate([0,0,-1]) cylinder(r = r1, h = z1 - z0 + 2);
}

module sector(r, a0, a1, n = 48)
    polygon(concat([[0,0]], [for (i = [0:n]) let(a = a0 + (a1 - a0)*i/n) r*[cos(a), sin(a)]]));

// pointed-roof window cut, projected along -Y
module roof_cut(w, z0, rect_h, roof_ang, depth = 120) {
    rh = w/2*tan(roof_ang);
    rotate([90,0,0]) linear_extrude(height = depth, center = false)
        polygon([[-w/2, z0], [w/2, z0], [w/2, z0 + rect_h], [0, z0 + rect_h + rh], [-w/2, z0 + rect_h]]);
}

// everything below the ramp surface (+ dz), tube frame
module below_ramp(dz = 0) translate([0, 0, ramp_c/cos(rk) + dz]) rotate([rk,0,0]) translate([-600,-600,-1200]) cube([1200,1200,1200]);

module hex_hole(a, z) rotate(a) translate([Ri - 1, 0, z]) rotate([0,90,0])
    cylinder(d = hex_hc, h = wall + 2, $fn = 6);

// ------------------------------ openings ------------------------------
module ball_port_cut(depth = 120) roof_cut(ball_w, bp_z0, ball_rect_h, ball_roof, depth);

module dowel_slot_cut(r_out = R + 1) {
    a0 = 270 - dow_ang/2; a1 = 270 + dow_ang/2;
    helix_band([[Ri - 1, -dow_h/2], [r_out, -dow_h/2], [r_out, dow_h/2],
                [Ri + 1.2, dow_h/2], [Ri - 1, dow_h/2 + dow_chamfer]],
               a0, a1, dow_zc, auger_pitch);
}

module window_cut() translate([0,0,-1]) linear_extrude(z_rim + 1) sector(R + 10, win_a0, win_a1);

// ------------------------------ lightening (v6 hex) -------------------
module lite_cuts(spans, skip_window = false, skip_pad = false) {
    rm  = R - wall/2;
    da  = hex_hp/rm*180/PI;
    n   = floor((lite_a1 - lite_a0)/da);
    bda = (boss_d/2 + hex_rib + hex_af/2)/R*180/PI;
    pda = asin(pad_hw/R) + da/2;
    for (s = spans) if (s[1] - s[0] > hex_hc + 2) {
        nz  = floor((s[1] - s[0] - hex_hc)/hex_vp) + 1;
        z00 = s[0] + (s[1] - s[0] - (nz - 1)*hex_vp)/2;
        for (j = [0:nz-1]) let(z = z00 + j*hex_vp, ph = j % 2, zl = z - hex_hc/2, zh = z + hex_hc/2)
            for (i = [0:n - 1 - ph]) let(a = lite_a0 + (i + 0.5 + ph/2)*da, an = (a + 360) % 360)
                if (!(skip_window && zl < z_rim + lintel && an > win_a0 - da && an < win_a1 + da) &&
                    [for (zb = boss_z, ab = boss_a)
                        if (zh > zb - boss_D - boss_d && zl < zb + boss_d && abs(a - ab) < bda) 1] == [] &&
                    !(skip_pad && zh > pad_z0 - pad_t - 2 && abs(an - 270) < pda))
                    hex_hole(a, z);
    }
}

// ------------------------------ pod bosses ----------------------------
module pod_boss(x, zb) difference() {
    hull() {
        translate([x, 30, zb]) rotate([-90,0,0]) cylinder(d = boss_d, h = pod_y0 - 30, $fn = 32);
        translate([x, 30, zb - boss_D - 1]) rotate([-90,0,0]) cylinder(d = boss_d, h = boss_ys - 30, $fn = 32);
    }
    translate([0,0,zb - boss_D - 10]) cylinder(r = Ri, h = boss_D + 20);
    translate([x, pod_y0 + 1, zb]) rotate([90,0,0]) cylinder(d = pilot_d, h = boss_D + 1, $fn = 20);
}
module pod_bosses() for (x = [-pod_screw_x, pod_screw_x], z = boss_z) pod_boss(x, z);

// ------------------------------ spout pad -----------------------------
module spout_pad() {
    intersection() {
        union() {
            translate([0,0,pad_z0]) cylinder(r = R + pad_t, h = pad_z1 - pad_z0);
            translate([0,0,pad_z0 - pad_t]) cylinder(r1 = R - 0.5, r2 = R + pad_t, h = pad_t + 0.01);
        }
        translate([-pad_hw, -R - pad_t - 5, pad_z0 - pad_t - 1]) cube([2*pad_hw, R, pad_z1 - pad_z0 + pad_t + 2]);
    }
}
function pad_holes() = [[-(pad_hw - 5), bp_z0 + ball_rect_h + 6], [pad_hw - 5, bp_z0 + ball_rect_h + 6],
                        [-(pad_hw - 5), dow_zc], [pad_hw - 5, dow_zc]];
module pad_pilots(d = pilot_d, depth = pad_t + wall - 1) for (h = pad_holes())
    translate([h[0], -sqrt(pow(R + pad_t, 2) - h[0]*h[0]) - 1, h[1]]) rotate([-90,0,0]) cylinder(d = d, h = depth + 1, $fn = 20);

// ------------------------------ shell pieces --------------------------
function cut_band(spans, c0, c1) = [for (sp = spans) each ((c1 <= sp[0] || c0 >= sp[1]) ? [sp] : [[sp[0], c0], [c1, sp[1]]])];
function lite_spans(i) = cut_band([[i == 0 ? floor_t + lip_h + 4 : pz0(i) + sleeve_h + 4, i == n_pieces - 1 ? shell_len - top_solid : pz1(i) - 4]],
                                  collar_z - 11, collar_z + 11);

module shell_piece(i) {
    bot = i == 0; top = i == n_pieces - 1;
    z0 = pz0(i); z1 = pz1(i);
    difference() {
        union() {
            tube(Ri, R, z0, z1);
            if (!top) {   // joint sleeve + 45 deg underside
                tube(R + sleeve_fit, R + sleeve_fit + sleeve_t, z1 - 0.01, z1 + sleeve_h);
                translate([0,0,z1 - (sleeve_fit + sleeve_t)]) difference() {
                    cylinder(r1 = R - 0.01, r2 = R + sleeve_fit + sleeve_t, h = sleeve_fit + sleeve_t);
                    translate([0,0,-1]) cylinder(r = Ri, h = 10);
                }
            }
            if (!bot) translate([-2, R - 0.5, z0 + 0.5]) cube([4, 0.5 + sleeve_fit + 1.2, sleeve_h - 1.5]);   // key
            if (top) { pod_bosses(); spout_pad(); }
        }
        if (!bot) translate([0,0,z0 - 1]) cylinder(r = Ri, h = z1 - z0 + 2);
        if (!top) translate([-2.3, R - 1, z1 + 1]) cube([4.6, sleeve_t + 3, sleeve_h]);     // key slot (+Y)
        if (bot) window_cut();
        if (top) { ball_port_cut(); dowel_slot_cut(R + pad_t + 1); pad_pilots(); }
        if (top && bar_slots) for (sx = [-1,1])
            translate([sx > 0 ? Ri - 3 : -R - 3, -bar_slot_w/2, z_a1 + bar_slot_z]) cube([R - Ri + 6, bar_slot_w, rim_z + 5]);
        if (lite) lite_cuts(lite_spans(i), skip_window = bot, skip_pad = top);
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

// ------------------------------ spouts --------------------------------
module spout(ball = true) {
    pw   = ball ? ball_w : dow_w;
    w    = pw + 4;
    zf   = ball ? bp_z0 - 0.5 : dow_low - 0.5;
    ztop = ball ? pad_z1 - 0.5 : dfl_top;
    wh   = ball ? 26 : 20;
    rin  = R + pad_t + 0.2;
    P0   = [0, -R, zf];
    hz   = ball ? [0, 1] : [2, 3];
    difference() {
        intersection() {
            union() {
                intersection() {
                    tube(rin, rin + flange_t, zf - 60, ztop);
                    translate([-pad_hw, -200, zf - 61]) cube([2*pad_hw, 200 - 20, ztop - zf + 62]);
                }
                translate(P0) rotate([spout_tilt,0,0]) {
                    translate([-w/2 - spout_wall, -spout_len, -spout_floor]) cube([w + 2*spout_wall, spout_len + 40, spout_floor]);
                    for (s = [-1,1]) translate([s > 0 ? w/2 : -w/2 - spout_wall, -spout_len, -0.01])
                        cube([spout_wall, spout_len + 40, wh]);
                }
            }
            translate(P0) rotate([spout_tilt,0,0]) translate([-500,-500,-spout_floor]) cube(1000);
        }
        translate([0,0,zf - 100]) cylinder(r = rin, h = 300);
        if (ball) ball_port_cut(); else dowel_slot_cut(rin + flange_t + 1);
        for (i = hz) let(h = pad_holes()[i])
            translate([h[0], -sqrt(pow(rin, 2) - h[0]*h[0]) + 1, h[1]]) rotate([90,0,0]) cylinder(d = 3.4, h = 20, $fn = 24);
    }
}
module spout_print(ball = true) {
    zf  = ball ? bp_z0 - 0.5 : dow_low - 0.5;
    translate([0,0,spout_floor]) rotate([-spout_tilt,0,0]) translate([0, R, -zf]) spout(ball);
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
module tube_parts(lower_only = false) {
    for (i = [0:(lower_only ? 0 : n_pieces-1)]) color(i % 2 ? "LightSteelBlue" : "SteelBlue", 0.6) shell_piece(i);
    color("Orange") sump();
    color("Gold") { wing_part(1); wing_part(-1); }
    if (!lower_only) {
        color("Orange") { spout(true); spout(false); elec_pod(); }
        dummy_electronics();
    }
}
module shell_assembly() {
    place_tube() tube_parts();
    if (show_ramp) ramp_world();
    color("LightGray", 0.4) translate([-241, -483, -1]) cube([482, 483, 1]);   // 19 x 19 in footprint (east edge on the ramp)
}

if (part == "assembly")    shell_assembly();
if (part == "shell_lower") translate([0,0,pz1(0) + sleeve_h]) rotate([180,0,0]) shell_piece(0);   // UPSIDE DOWN: sleeve on the bed
if (part == "shell_middle") translate([0,0,-pz0(1)]) shell_piece(1);
if (part == "shell_upper")  translate([0,0,-pz0(n_pieces-1)]) shell_piece(n_pieces - 1);
if (part == "sump")        sump();                                        // floor down
if (part == "wing_right")  wing_part(1);
if (part == "wing_left")   wing_part(-1);
if (part == "spout_ball")  spout_print(true);
if (part == "spout_dowel") spout_print(false);
if (part == "pod")         rotate([90,0,0]) pod_plate();

// values for other files that `use` this one
function shell_info() = [z_a0, z_a1, shell_len, R, lean, n_pieces, T_y, T_z];
