// =====================================================================
// Downhill Dispatcher — coupler v4: tapered plug + zip-tie collet
// ---------------------------------------------------------------------
// Replaces the coupler in downhill_top_bar.scad (v3). Same frame:
// z = 0 is the TOP FACE of the upper auger piece; the motor bar sits
// at z = 7, the N20 shaft tip reaches z = 0.
//
//   plug   : smooth taper copied from the hand-sanded v3 plug that
//            stays snug (17.86 tip / 18.85 top in an 18.75 socket).
//            Push it into the auger BY HAND, before the motor goes in.
//   collet : 3 fingers with a loose D-bore. The motor shaft drops in
//            with no force; one zip tie in the groove clamps it. The
//            D-flat drives, the tie keeps it tight. The fingers are
//            cut free of the plug, so the socket squeeze doesn't close
//            them.
//
// Assembly: 1) push coupler into auger  2) loop a zip tie loosely in
// the groove, head in the seat  3) turn auger so the flat lines up,
// drop the motor bar in  4) pull the tie tight with pliers, trim.
// Remove: cut the tie.
//
// Prints plug down (as exported), no supports.
// CLI: openscad -o coupler_v4.stl downhill_coupler_v4.scad
// =====================================================================

/* [Auger top (auger.scad v5)] */
top_socket_d = 19;     // nominal; measured 18.75
top_od       = 25;

/* [N20 shaft] */
shaft_d    = 3.0;
shaft_flat = 2.5;      // across the D flat
shaft_tip  = 0;        // z of shaft tip (gearbox face 10, shaft 10 long)

/* [Plug — taper from the sanded v3 part] */
plug_len   = 14;
plug_d_tip = 17.9;     // bottom
plug_d_top = 18.85;    // at the flange (snug). Too tight: sand, or -0.05
cf_t       = 2.0;      // flange on the 25 mm collar

/* [Collet] */
boss_d     = 10;
boss_top   = 6;        // 1 mm below the bar's hub floor (z = 7)
d_clear    = 0.5;      // D-bore clearance, diametral: drop-in loose
finger_root = -7;      // fingers are free from here up
relief_w   = 1.0;      // radial gap between fingers and plug wall
slit_n     = 3;
slit_w     = 1.0;
tie_w      = 2.8;      // groove width (fits 2.5 mm ties)
groove_d   = 0.6;
groove_z   = 2.6;      // groove bottom edge (above the flange)
head_w     = 5.0;      // zip-tie head seat (flat pocket), width x depth
head_cut   = 0.8;

$fn = 96;

relief_r0 = boss_d/2;  relief_r1 = boss_d/2 + relief_w;
echo(str("Shaft engagement ", boss_top - shaft_tip, " mm; clamp band z ", groove_z, "..", groove_z + tie_w,
         "; finger free length ", boss_top - finger_root, " mm"));
assert(groove_z > cf_t + 0.4, "groove runs into the flange");
assert(groove_z + tie_w < boss_top - 0.4, "groove runs off the top");
assert(relief_r1 < plug_d_tip/2 - 2, "plug wall too thin");

module d_profile(d, flat) intersection() { circle(d=d, $fn=48); translate([-d, -d]) square([flat + d/2, 2*d]); }

module coupler() {
    difference() {
        union() {
            translate([0,0,-plug_len]) cylinder(d1=plug_d_tip, d2=plug_d_top, h=plug_len + 0.01);
            cylinder(d=top_od, h=cf_t);
            cylinder(d=boss_d, h=boss_top);
        }
        // tip chamfer
        translate([0,0,-plug_len-0.01]) difference() {
            cylinder(d=top_socket_d + 2, h=1.0);
            cylinder(d1=plug_d_tip - 1.6, d2=plug_d_tip + 0.4, h=1.0);
        }
        // relief ring: frees the fingers from the plug wall + flange
        translate([0,0,finger_root]) difference() {
            cylinder(r=relief_r1, h=boss_top - finger_root + 1);
            translate([0,0,-1]) cylinder(r=relief_r0, h=boss_top - finger_root + 3);
        }
        // D-bore (flat on +X, centred on a finger)
        translate([0,0,shaft_tip - 1]) linear_extrude(boss_top - shaft_tip + 2)
            offset(delta=d_clear/2) d_profile(shaft_d, shaft_flat);
        // slits between fingers (at 60/180/300 deg, clear of the flat)
        for (i=[0:slit_n-1]) rotate([0,0,60 + i*360/slit_n])
            translate([0, -slit_w/2, finger_root + 1]) cube([relief_r0 + 0.5, slit_w, boss_top - finger_root]);
        // zip-tie groove
        translate([0,0,groove_z]) difference() {
            cylinder(d=boss_d + 2, h=tie_w);
            translate([0,0,-1]) cylinder(d=boss_d - 2*groove_d, h=tie_w + 2);
        }
        // head seat: flat pocket centred on a finger, beside the groove
        rotate([0,0,120]) translate([boss_d/2 - groove_d - head_cut, -head_w/2, groove_z - 0.4])
            cube([5, head_w, boss_top]);
        // lighten the plug core, 45 deg top (no bridge)
        translate([0,0,-plug_len - 1]) cylinder(d=9, h=plug_len + finger_root - 5);
        translate([0,0,finger_root - 6 - 0.01]) cylinder(d1=9, d2=0, h=4.5);
    }
}

part = "coupler"; // [coupler, section]
if (part == "coupler") translate([0,0,plug_len]) coupler();               // plug down
if (part == "section") difference() { coupler(); translate([-30,0,-30]) cube([60,30,60]); }
