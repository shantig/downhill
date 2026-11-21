// =====================================================================
// Downhill Dispatcher — V-band joint (v8): keyed 45 deg flanges + 2-piece clamp
// ---------------------------------------------------------------------
// Replaces the 16 mm dry-fit sleeves. Each shell joint is a butt joint:
//   * both pieces end in a 45 deg flange (radial fl_w, edge fl_e)
//   * a small loose printed key sits in notches in both faces, so every
//     piece clocks the same way every time
//   * a 2-half clamp with a 90 deg internal V wraps both flanges. Two M3
//     screws close it; the V wedges the flanges together and centres them.
//     Clamp half A has M3 heat-set inserts (M3x6x5), half B has clearance
//     holes. M3x12 socket-head screws.
// The bore stays smooth (no step) and nothing slides over the whole tube,
// so pods/bosses anywhere on the shell don't get in the way.
// Everything prints without supports:
//   flange on the bed, or a 45 deg cone; clamp halves print flat.
// Use:  use <downhill_joint.scad>  then flange(...), clamp_half(...),
//       key_tab(...), key_notch(...).   jt() returns the shared numbers.
// CLI:  openscad -D 'part="clamp_a"' -o clamp_a.stl downhill_joint.scad
// =====================================================================

part = "demo"; // [demo, clamp_a, clamp_b, key, section]

/* [Tube] */
j_Ri   = 57;      // shell bore radius (114 / 2)
j_R    = 58.2;    // shell OD radius

/* [Flange] */
fl_w   = 3.2;     // radial width past the tube OD
fl_e   = 1.2;     // straight edge before the 45 deg taper
key_w  = 5;       // key tab (tangential)
key_h  = 1.6;     // key height above the face
key_fit = 0.2;

/* [Clamp] */
cl_c     = 0.15;  // clearance, flank to flange taper (normal)
cl_lip   = 0.4;   // radial gap, clamp lip to tube OD
cl_wall  = 2.4;   // wall behind the V
cl_gap   = 2.0;   // gap at each split when the flanges first touch (take-up)
ear_t    = 6;     // ear thickness (tangential), per half -> M3x12 gets ~4 mm of thread
ear_out  = 9;     // ear length past the clamp body
ins_d    = 4.5;   // M3x6x5 heat-set insert hole (5.0 OD insert)
ins_l    = 6.5;
clr_d    = 3.4;   // M3 clearance
$fn = 160;

function jt() = [j_Ri, j_R, fl_w, fl_e, cl_c, cl_lip, cl_wall];
function fl_h() = fl_e + fl_w;                       // flange height (axial)
function cl_h() = 2*fl_h();                          // clamp height
function cl_rin() = j_R + cl_lip;
function cl_rv() = j_R + fl_w + cl_c*sqrt(2) + 0.3; // groove bottom radius
function cl_rout() = cl_rv() + cl_wall;

// ---- flange on a tube end. face at z = zf; dir = +1 (flange body below the
// face, i.e. on the TOP of the lower piece) or -1 (bottom of the upper piece)
module flange(zf, dir = 1, Ri = j_Ri, R = j_R) {
    pts = [[Ri, 0], [R + fl_w, 0], [R + fl_w, fl_e], [R - 0.01, fl_e + fl_w + 0.01], [Ri, fl_e + fl_w + 0.01]];
    translate([0,0,zf]) mirror([0,0, dir > 0 ? 1 : 0]) rotate_extrude() polygon(pts);
}

// clocking: a notch in BOTH faces + a loose printed key (part = "key").
// Both faces end up on the print bed (shell_lower prints upside down), so
// nothing may stick out of a face. dir = +1 cuts up into the upper piece,
// -1 cuts down into the lower piece.
module key_notch(zf, a = 90, Ri = j_Ri, R = j_R, dir = 1)
    rotate(a) translate([Ri, -key_w/2 - key_fit, zf]) mirror([0,0, dir > 0 ? 0 : 1])
        translate([0, 0, -0.01]) cube([R + fl_w - Ri + 1, key_w + 2*key_fit, key_h + key_fit + 0.3]);
module key_part() cube([j_R + fl_w - j_Ri - 1.2, key_w, 2*key_h]);   // x2 (one per joint)

// ---- clamp profile (r, z), z = 0 at the joint face, symmetric.
// Flank = flange taper offset by cl_c (normal). Groove bottom clears the flange edge by 0.3.
module clamp_profile() {
    h  = fl_h();
    rv = cl_rv();
    k  = cl_c*sqrt(2);
    zL = fl_w + fl_e + k - cl_lip;      // flank meets the lip
    zG = fl_e + (j_R + fl_w + k) - rv;  // flank meets the groove bottom
    polygon([[cl_rin(), -h], [cl_rout(), -h], [cl_rout(), h], [cl_rin(), h],
             [cl_rin(), zL], [rv, zG], [rv, -zG], [cl_rin(), -zL]]);
}

// one clamp half (a = 0: the half on +Y). insert = true -> heat-set inserts in the ears
module clamp_half(insert = true) {
    h = fl_h();
    ro = cl_rout();
    g  = cl_gap/2;
    difference() {
        union() {
            intersection() {
                rotate_extrude() clamp_profile();
                translate([-ro - 20, g, -h - 1]) cube([2*ro + 40, ro + 20, 2*h + 2]);
            }
            for (s = [-1,1]) translate([s > 0 ? ro - 3 : -ro - ear_out + 3, g, -h])
                cube([ear_out, ear_t, 2*h]);
        }
        translate([0,0,-h-1]) cylinder(r = cl_rin(), h = 2*h + 2);
        for (s = [-1,1]) translate([s*(ro + ear_out/2 - 2.5), g - 1, 0]) rotate([-90,0,0])
            if (insert) cylinder(d = ins_d, h = ins_l + 1, $fn = 32);
            else cylinder(d = clr_d, h = ear_t + 2, $fn = 32);
        // soften the outer corners
        for (s = [-1,1]) translate([s*(ro + ear_out - 3), g + ear_t, 0]) rotate([0,0,45]) cube([2.5, 2.5, 2*h + 2], center = true);
    }
}
function clamp_screw_x() = cl_rout() + ear_out/2 - 2.5;

// ---- demo / print
module demo() {
    color("SteelBlue", 0.6) difference() {
        union() { translate([0,0,-40]) cylinder(r = j_R, h = 40); flange(0, 1); }
        translate([0,0,-41]) cylinder(r = j_Ri, h = 50); key_notch(0, dir = -1);
    }
    color("Red") rotate(90) translate([j_Ri + 0.6, -key_w/2, -key_h]) key_part();
    color("LightSteelBlue", 0.6) difference() {
        union() { cylinder(r = j_R, h = 40); flange(0, -1); }
        translate([0,0,-1]) cylinder(r = j_Ri, h = 50); key_notch(0);
    }
    color("Orange") clamp_half(true);
    color("Gold") rotate(180) clamp_half(false);
}

if (part == "demo")    demo();
if (part == "clamp_a") translate([0,0,fl_h()]) clamp_half(true);
if (part == "clamp_b") translate([0,0,fl_h()]) clamp_half(false);
if (part == "key")     key_part();
if (part == "section") difference() { demo(); translate([-200,-400,-100]) cube([400,400,200]); }

echo(str("JOINT: flange ", fl_w, " x ", fl_h(), " mm; clamp ", cl_h(), " tall, OD ", 2*cl_rout(), " (+ ears ", 2*(cl_rout()+ear_out-3), "); M3x12 at x = +-", clamp_screw_x()));
