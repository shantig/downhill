// =====================================================================
// Downhill Dispatcher — coupler v5: tapered plug + M3 cross-screw + M2 set screw
// ---------------------------------------------------------------------
// Feedback: wanted a stronger, reusable auger-motor connection that
// survives repeated assembly. The auger is NOT being reprinted yet, so the
// plug still fits the existing 19 mm round top socket (auger.scad v5).
//
//   plug  : same hand-sanded taper as v4 (17.9 -> 18.85, snug by hand)
//           + an M3x4x5 heat-set insert, radial, 7 mm below the top face.
//           An M3x6 screw through a 3.4 mm hole drilled ONCE in the auger's
//           25 mm collar locks it: no slip, no pull-out, unscrew to remove.
//   boss  : solid 12 mm boss with a loose D-bore (motor shaft drops in)
//           + an M2x4x3.2 heat-set insert aimed at the D-flat. An M2x5/x6
//           screw (or M2 grub) clamps the flat. Replaces the zip tie.
//   jig   : drill guide. Slip it over the collar (lip on the top face) and
//           drill 2.5 mm, then 3.4 mm, through the hole. Do it BEFORE the
//           coupler goes in.
//
// Assembly
//   1) drill the collar with the jig (once)
//   2) heat-set both inserts into the coupler
//   3) press the coupler into the auger, turn it until the insert shows
//      through the hole (notch on the flange marks it), M3x6 in
//   4) drop the motor shaft in (flat toward the M2 insert), M2 screw snug
//   Remove: M2 out, lift the arm; M3 out, pull the coupler.
//
// Frame: z = 0 is the TOP FACE of the upper auger piece; N20 shaft tip at
// z = 0, gearbox face at z = 10 (motor arm shelf underside at z = 7).
// Prints plug down (as exported), no supports. 100% infill.
// CLI: openscad -D 'part="coupler"' -o coupler_v5.stl downhill_coupler_v5.scad
// =====================================================================

part = "coupler"; // [coupler, jig, section]

/* [Auger top (auger.scad v5)] */
top_socket_d = 19;     // nominal; measured 18.75
top_od       = 25;

/* [N20 shaft] */
shaft_d    = 3.0;
shaft_flat = 2.5;      // across the D flat
shaft_tip  = 0;

/* [Plug — taper from the sanded v3 part] */
plug_len   = 14;
plug_d_tip = 17.9;
plug_d_top = 18.85;    // too tight: sand, or -0.05
cf_t       = 2.0;      // flange on the 25 mm collar

/* [Cross screw (M3)] */
x_z        = -7;       // below the top face
m3_ins_d   = 4.5;      // M3x4x5 insert hole
m3_ins_l   = 5.0;
m3_hole_l  = 6.5;      // keeps going past the insert so an M3x8 also fits

/* [Boss + set screw (M2)] */
boss_d     = 12;
boss_top   = 6;        // 1 mm below the arm shelf (z = 7)
d_clear    = 0.3;      // D-bore clearance, diametral
m2_ins_d   = 3.0;      // M2x4x3.2 insert hole
m2_ins_l   = 4.2;
m2_clear   = 2.2;
set_z      = 3.6;

/* [Jig] */
jig_wall   = 4;
jig_lip    = 2;
jig_clear  = 0.25;     // radial on the 25 mm collar
pilot_d    = 3.4;

$fn = 96;

flat_x = shaft_flat - shaft_d/2;            // D-flat distance from the axis (+X)
echo(str("Shaft engagement ", boss_top - shaft_tip, " mm; set screw at z ", set_z, " on the flat (x = ", flat_x, ")"));
echo(str("Cross screw z ", x_z, ": drill the collar ", -x_z, " mm below its top face"));
assert(boss_d/2 - m2_ins_l > flat_x + d_clear/2 + 0.4, "M2 insert runs into the D-bore");
assert(set_z - m2_ins_d/2 > 0.8 && set_z + m2_ins_d/2 < boss_top - 0.6, "M2 insert off the boss");
assert(plug_d_tip/2 - m3_hole_l > 1.0, "M3 hole breaks into the centre");

module d_profile(d, flat) intersection() { circle(d = d, $fn = 48); translate([-d, -d]) square([flat + d/2, 2*d]); }

module coupler() {
    difference() {
        union() {
            translate([0,0,-plug_len]) cylinder(d1 = plug_d_tip, d2 = plug_d_top, h = plug_len + 0.01);
            cylinder(d = top_od, h = cf_t);
            cylinder(d = boss_d, h = boss_top);
        }
        // tip chamfer
        translate([0,0,-plug_len - 0.01]) difference() {
            cylinder(d = top_socket_d + 2, h = 1.0);
            cylinder(d1 = plug_d_tip - 1.6, d2 = plug_d_tip + 0.4, h = 1.0);
        }
        // D-bore (flat on +X)
        translate([0,0,shaft_tip - 1]) linear_extrude(boss_top - shaft_tip + 2)
            offset(delta = d_clear/2) d_profile(shaft_d, shaft_flat);
        // M2 insert -> D-flat (+X)
        translate([boss_d/2 + 0.01, 0, set_z]) rotate([0,-90,0]) {
            cylinder(d = m2_ins_d, h = m2_ins_l, $fn = 24);
            cylinder(d = m2_clear, h = boss_d/2, $fn = 20);
        }
        // M3 cross insert (-Y, away from the set screw)
        translate([0, -plug_d_tip/2 - 2, x_z]) rotate([-90,0,0]) {
            cylinder(d = m3_ins_d + 0.3, h = 2.01, $fn = 32);                   // lead-in through the taper
            translate([0,0,2]) cylinder(d = m3_ins_d, h = m3_hole_l - 0.6, $fn = 32);
        }
        // notch on the flange edge marking the M3 insert
        translate([0, -top_od/2, cf_t]) rotate([0,45,0]) cube([1.6, 3, 1.6], center = true);
        // lighten the plug core below the cross insert, 45 deg top
        translate([0,0,-plug_len - 1]) cylinder(d = 8, h = plug_len + x_z - 4);
        translate([0,0,x_z - 5 - 0.01]) cylinder(d1 = 8, d2 = 0, h = 4);
    }
}

module jig() {
    h = -x_z + 6;
    ri = top_od/2 + jig_clear;
    difference() {
        translate([0,0,-h]) cylinder(r = ri + jig_wall, h = h + jig_lip);
        translate([0,0,-h - 1]) cylinder(r = ri, h = h + 1);                    // collar
        cylinder(d = top_socket_d - 1, h = 10);                                  // see the socket
        translate([0, 0, x_z]) rotate([90,0,0]) cylinder(d = pilot_d, h = 40, $fn = 32);   // guide (-Y)
        translate([-0.6, -ri - jig_wall - 1, 0]) cube([1.2, jig_wall + 2, jig_lip + 1]); // sight line for the notch
    }
}

if (part == "coupler") translate([0,0,plug_len]) coupler();             // plug down
if (part == "jig")     translate([0,0,jig_lip]) rotate([180,0,0]) jig();  // lip on the bed
if (part == "section") difference() { coupler(); translate([-30,0,-30]) cube([60,30,60]); }
