// =====================================================================
// Downhill Dispatcher — auger shell (v1)
// ---------------------------------------------------------------------
// Houses the auger from auger.scad v4 (110 mm flights, 381 mm long) and
// leans back 25 deg on the lean-back frame (downhill_frame.scad).
//
// Parts
//   shell_lower : floor + printed 7 mm pin for the 627 bearing, front
//                 intake window, joint sleeve on top
//   shell_upper : ball port (top) + dowel slot (below) on the UNDERSIDE,
//                 spout pad, pod ribs on the UPPER face, rim for the
//                 top-drive motor cap
//   boot        : wedge foot so the leaning shell sits flat on the floor
//   spout_ball, spout_dowel : chutes that screw onto the spout pad
//   pod         : electronics plate (driver board, LiPo, ANO) that screws
//                 onto the pod ribs, close to the N20 (16 cm cable)
//
// Tube frame: z = shell axis, z = 0 = bottom face of the floor.
//   -Y = UNDERSIDE (the low side when leaning; objects rest here)
//   +Y = UPPER face (pod side)
// CLI: openscad -D 'part="shell_upper"' -o shell_upper.stl downhill_shell.scad
// =====================================================================

part = "assembly"; // [assembly, shell_lower, shell_upper, boot, spout_ball, spout_dowel, pod]

/* [Auger (from auger.scad v4)] */
auger_len   = 381;
auger_od    = 110;
tube_id     = 114;    // shell bore
auger_pitch = 63.5;   // total_len / turns

/* [Shell] */
wall      = 1.6;      // 4 lines @ 0.4 nozzle
lean      = 25;       // deg back from vertical
floor_t   = 3;
floor_hole = 6;      // floor lightening holes (< 8 mm dowel)
rim_z     = 10;       // shell rim above auger top (= rim_z in downhill_top_drive.scad)
split_z   = 180;      // joint between the two pieces (keeps the frame collar on the upper)
sleeve_h  = 12;
sleeve_t  = 2.4;
sleeve_fit = 0.2;     // radial

/* [Bottom pin for the 627 bearing] */
pin_mode    = "printed"; // [printed, steel]
pin_d       = 6.95;   // printed pin, snug in the 7 mm bore
steel_pin_d = 7.1;    // socket for a 7 mm steel pin / drill blank (glue in)
pin_len     = 8;      // above the shoulder
shoulder_d  = 9.5;    // touches the inner race only
shoulder_h  = 3;

/* [Intake window (front / upper face, bottom)] */
in_z0     = 10;
in_w      = 84;       // chord width
in_rect_h = 50;
in_roof   = 55;       // pointed roof angle -> prints without support

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
spout_len   = 50;
spout_tilt  = 10;     // extra droop past the 25 deg lean -> 35 deg below horizontal
spout_wall  = 1.6;
spout_floor = 2.0;
flange_t    = 2.4;

/* [Lightening: 6 mm slots on the upper side] */
lite      = true;
slot_w    = 6;        // < 8 mm dowel, can't snag
slot_rib  = 2.5;
row_max   = 48;
ring_h    = 4;
lite_a0   = -45;      // arc that gets slots (deg, CCW from +X; +Y = 90)
lite_a1   = 225;      // underside 270 +/- 45 stays solid

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

$fn = 120;

// ------------------------------ derived -------------------------------
Ri = tube_id/2;
R  = Ri + wall;
z_a0 = floor_t + shoulder_h - 0.2;        // auger bottom face (bearing sits 0.2 proud)
z_a1 = z_a0 + auger_len;                  // auger top face
shell_len = z_a1 + rim_z;

// ball port
ball_roof_h = ball_w/2 * tan(ball_roof);
bp_z1 = z_a1 - ball_top_gap;
bp_z0 = bp_z1 - ball_rect_h - ball_roof_h;
// dowel slot (helical, follows the flight)
dow_ang  = 2*asin((dow_w/2)/R);
dow_dz   = dow_ang/2/360*auger_pitch;      // rise across half the slot
dfl_top  = bp_z0 - 0.5 - spout_floor - 1;  // dowel flange top, just under the ball spout
dow_zc   = dfl_top - 3 - dow_dz - dow_h/2;
dow_low  = dow_zc - dow_h/2 - dow_dz;      // lowest sill
// spout pad
pad_hw = max(ball_w, dow_w)/2 + pad_m;
pad_z0 = dow_low - 0.5 - spout_floor - 3;
pad_z1 = z_a1 - 1;                          // stop under the motor-cap skirt
// intake
in_top = in_z0 + in_rect_h + in_w/2*tan(in_roof);
// pod
pod_s  = shell_len - pod_top_gap - plate_l;
pod_y0 = R + pod_gap;
boss_ys = sqrt(R*R - pod_screw_x*pod_screw_x);      // shell surface under a boss
boss_D  = pod_y0 - boss_ys;                          // boss length = gusset drop
boss_z  = [pod_s + boss_inset, pod_s + plate_l - boss_inset];
boss_a  = [90 - asin(pod_screw_x/R), 90 + asin(pod_screw_x/R)];
// frame collar (downhill_frame.scad: collar_frac 0.55, collar_h 18)
collar_z = 0.55*shell_len;

echo(str("SHELL: OD ", 2*R, "  length ", shell_len, "  auger ", z_a0, "..", z_a1));
echo(str("Ball port z ", bp_z0, "..", bp_z1, "   dowel slot centre z ", dow_zc));
echo(str("Pod z ", pod_s, "..", pod_s + plate_l, "   collar z ", collar_z));
echo(str("Pieces: lower ", split_z + sleeve_h, " mm, upper ", shell_len - split_z, " mm (X2D: 260)"));
assert(shell_len - split_z <= 255 && split_z + sleeve_h <= 255, "piece too tall");
assert(collar_z - 9 > split_z + sleeve_h + 2, "collar lands on the joint sleeve");

// ------------------------------ helpers -------------------------------
function frange(a, b, n) = [for (i = [0:n-1]) a + (b - a)*(i + 0.5)/n];

// rows of slots between solid bands: returns [[z0,z1],...]
function rows_in(a, b) = let(n = max(1, ceil((b - a + ring_h)/(row_max + ring_h))),
                             h = (b - a - (n - 1)*ring_h)/n)
    (b - a < 15) ? [] : [for (i = [0:n-1]) [a + i*(h + ring_h), a + i*(h + ring_h) + h]];

// helical band through the wall. prof = [[r,z],...] (z relative to centre line)
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

// pointed-roof window cut, projected along -Y (or +Y with s = 1)
module roof_cut(w, z0, rect_h, roof_ang, s, depth = 120) {
    rh = w/2*tan(roof_ang);
    rotate([90,0,0]) linear_extrude(height = depth, center = false)
        polygon([[-w/2, z0], [w/2, z0], [w/2, z0 + rect_h], [0, z0 + rect_h + rh], [-w/2, z0 + rect_h]]);
}

// ------------------------------ openings ------------------------------
module ball_port_cut(depth = 120) roof_cut(ball_w, bp_z0, ball_rect_h, ball_roof, -1, depth);  // toward -Y

module dowel_slot_cut(r_out = R + 1) {
    a0 = 270 - dow_ang/2; a1 = 270 + dow_ang/2;
    helix_band([[Ri - 1, -dow_h/2], [r_out, -dow_h/2], [r_out, dow_h/2],
                [Ri + 1.2, dow_h/2], [Ri - 1, dow_h/2 + dow_chamfer]],
               a0, a1, dow_zc, auger_pitch);
}

module intake_cut() rotate([0,0,180]) roof_cut(in_w, in_z0, in_rect_h, in_roof, 1);  // toward +Y

// ------------------------------ lightening ----------------------------
module lite_row(z0, z1, phase, skip_intake = false) {
    near_boss = [for (zb = boss_z) if (z1 > zb - boss_D - boss_d && z0 < zb + boss_d) 1] != [];
    bda = (boss_d/2 + slot_rib + slot_w/2)/R*180/PI;
    rm = R - wall/2;
    da = (slot_w + slot_rib)/rm*180/PI;
    n  = floor((lite_a1 - lite_a0)/da);
    translate([0,0,z0]) linear_extrude(z1 - z0)
        for (i = [0:n - 1 - phase]) let(a = lite_a0 + (i + 0.5 + phase/2)*da)
            if (!(skip_intake && z0 < in_top + 4 && abs(a - 90) < asin((in_w/2)/R) + da) &&
                !(near_boss && min([for (b = boss_a) abs(a - b)]) < bda))
                rotate(a) translate([Ri - 1, -slot_w/2]) square([wall + 2, slot_w]);
}

module lite_cuts(spans, skip_intake = false) {
    rows = [for (s = spans) each rows_in(s[0], s[1])];
    for (i = [0:len(rows)-1]) lite_row(rows[i][0], rows[i][1], i % 2, skip_intake);
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
module shell_lower() {
    difference() {
        union() {
            tube(Ri, R, 0, split_z);
            cylinder(r = R, h = floor_t);
            // joint sleeve + 45 deg underside
            tube(R + sleeve_fit, R + sleeve_fit + sleeve_t, split_z - 0.01, split_z + sleeve_h);
            translate([0,0,split_z - (sleeve_fit + sleeve_t)]) difference() {
                cylinder(r1 = R - 0.01, r2 = R + sleeve_fit + sleeve_t, h = sleeve_fit + sleeve_t);
                translate([0,0,-1]) cylinder(r = Ri, h = 10);
            }
            // bearing pin
            translate([0,0,floor_t - 0.01]) cylinder(d = shoulder_d, h = shoulder_h + 0.01, $fn = 48);
            if (pin_mode == "printed")
                translate([0,0,floor_t + shoulder_h - 0.01]) {
                    cylinder(d = pin_d, h = pin_len - 0.6, $fn = 48);
                    translate([0,0,pin_len - 0.61]) cylinder(d1 = pin_d, d2 = pin_d - 1.2, h = 0.6, $fn = 48);
                }
        }
        if (pin_mode == "steel") translate([0,0,1]) cylinder(d = steel_pin_d, h = floor_t + shoulder_h, $fn = 48);
        intake_cut();
        // floor lightening
        translate([0,0,-1]) linear_extrude(floor_t + 2) intersection() {
            difference() { circle(r = Ri - 3); circle(r = 14); }
            for (i = [-8:8], j = [-8:8]) translate([i*(floor_hole + 2.6) + (j%2)*(floor_hole + 2.6)/2, j*(floor_hole + 2.6)*sin(60)]) circle(d = floor_hole, $fn = 6);
        }
        // key slot in the sleeve (+Y)
        translate([-2.3, R - 1, split_z + 1]) cube([4.6, sleeve_t + 3, sleeve_h]);
        if (lite) lite_cuts([[14, split_z - 4]], skip_intake = true);
    }
}

module shell_upper() {
    difference() {
        union() {
            tube(Ri, R, split_z, shell_len);
            translate([-2, R - 0.5, split_z + 0.5]) cube([4, 0.5 + sleeve_fit + 1.2, sleeve_h - 1.5]);   // key
            pod_bosses();
            spout_pad();
        }
        translate([0,0,split_z - 1]) cylinder(r = Ri, h = shell_len + 2);
        ball_port_cut();
        dowel_slot_cut(R + pad_t + 1);
        pad_pilots();
        if (lite) lite_cuts([
            [split_z + sleeve_h + 4, collar_z - 9 - 2],
            [collar_z + 9 + 2, shell_len - 14]]);
    }
}

// ------------------------------ boot ----------------------------------
boot_fit = 0.25; boot_t = 1.6; boot_h = 8; sole_t = 2.4; sole_w = 6;
module above_ground(dz = 0) rotate([-lean,0,0]) translate([-500,-500,-R*sin(lean) + dz]) cube(1000);
module boot() {
    rb = R + boot_fit; ro = rb + boot_t;
    intersection() {
        difference() {
            union() {
                translate([0,0,-90]) cylinder(r = ro, h = 90 + boot_h);
                intersection() {
                    translate([0,0,-120]) cylinder(r = ro + sole_w, h = 120);
                    difference() { above_ground(); above_ground(sole_t); }
                }
                translate([0,0,-2]) cylinder(r = rb + 0.01, h = 2);          // lip the shell sits on
            }
            translate([0,0,-130]) cylinder(r = rb, h = 130 - 2);
            translate([0,0,-0.01]) cylinder(r = rb, h = boot_h + 1);
            translate([0,0,-5]) cylinder(r = R - 3.5, h = 10);
        }
        above_ground();
    }
}

// ------------------------------ spouts --------------------------------
module spout(ball = true) {
    pw   = ball ? ball_w : dow_w;
    w    = pw + 4;
    zf   = ball ? bp_z0 - 0.5 : dow_low - 0.5;         // floor top at the shell
    ztop = ball ? pad_z1 - 0.5 : dfl_top;
    wh   = ball ? 26 : 20;
    rin  = R + pad_t + 0.2;
    P0   = [0, -R, zf];
    hz   = ball ? [0, 1] : [2, 3];
    difference() {
        intersection() {
            union() {
                // curved flange on the pad
                intersection() {
                    tube(rin, rin + flange_t, zf - 60, ztop);
                    translate([-pad_hw, -200, zf - 61]) cube([2*pad_hw, 200 - 20, ztop - zf + 62]);
                }
                // trough
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
// Tube frame, plate on +Y. Components face outward (+Y). Driver board sits
// near the TOP so the N20 lead (16 cm) reaches it.
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
module pod_plate() {   // local: plate inner face at y = 0, bottom at z = 0
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
module shell_assembly() {
    color("SteelBlue", 0.55) shell_lower();
    color("LightSteelBlue", 0.55) shell_upper();
    color("Orange") boot();
    color("Orange") { spout(true); spout(false); }
    color("Orange") elec_pod();
    dummy_electronics();
}

if (part == "assembly")    shell_assembly();
if (part == "shell_lower") shell_lower();
if (part == "shell_upper") translate([0,0,-split_z]) shell_upper();
if (part == "boot")        translate([0,0,R*sin(lean)]) rotate([lean,0,0]) boot();
if (part == "spout_ball")  spout_print(true);
if (part == "spout_dowel") spout_print(false);
if (part == "pod")         rotate([90,0,0]) pod_plate();

// values for other files that `use` this one
function shell_info() = [z_a0, z_a1, shell_len, R, lean];
