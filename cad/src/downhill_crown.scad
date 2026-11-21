// =====================================================================
// Downhill Dispatcher — motor ARM v1 (replaces the end cap / motor bar)
// ---------------------------------------------------------------------
// Testing feedback: the N20 wobbled in the zip-tie cradle and the cap
// closed the top. v8 exits objects through the open top of the shell, so
// the motor now hangs off ONE stiff arm bolted to the shell backbone:
//
//   box beam  : 16 x 29 mm closed box (2 mm walls), backbone -> centre
//   end block : bears on the backbone's inside face; 2x M3x6x5 heat-set
//               inserts take 2x M3x8 screws through the backbone pad from
//               OUTSIDE (easy to reach)
//   T-head    : vertical plate at the shaft; the Waveshare N20 bracket
//               clamps the gearbox flat against it. 2x M2x4x3.2 heat-set
//               inserts, M2x6 screws (factory screws are smaller than M2)
//   shelf     : 3 mm floor under the gearbox face (motor can't slide down),
//               optional M1.6 face screws into the gearbox
//   Gearbox face stays at z = 10 above the auger top, so every coupler
//   (v4, mid, v5) still lines up: shaft tip at z = 0.
//
//   strap     : printed copy of the factory bracket, in case its hole
//               spacing doesn't match brk_cc. Same screws.
//
// Frame: z = 0 is the TOP FACE of the upper auger piece. The arm points
// along +X in its own frame; the assembly rotates it to arm_a (shell v8).
// Prints UPRIGHT as exported: every bottom face sits on z = arm_zb, so the
// shelf, beam, T-head and block all start on the bed. No supports (the
// box top is a 12 mm bridge).
// CLI: openscad -D 'part="arm"' -o motor_arm.stl downhill_crown.scad
// =====================================================================

part = "arm"; // [arm, strap, assembly, section]

/* [Shell v8 (downhill_shell.scad)] */
Ri      = 57;          // bore radius
arm_zb  = 7;           // arm underside above the auger top
arm_h   = 29;          // -> backbone top at 36
screw_dz = [7, 22];    // M3 screws above the underside (match shell arm_screw_dz)

/* [Waveshare N20 (DCGM-N20-12V-EN-200RPM)] */
motor_w   = 12.0;      // across the round ends
motor_d   = 10.0;      // across the flats
gear_len  = 9.0;
can_len   = 15.0;
enc_len   = 10.0;      // encoder board + connector (verify)
shaft_len = 10.0;
shaft_d   = 3.0;
face_screw_spacing = 9.0;

/* [Bracket (factory: 25.0 over the ears, 11.6 tall, 11.7 inside)] */
brk_cc    = 18.0;      // hole centre-to-centre. VERIFY: outer-edge-to-outer-edge minus one hole dia
brk_len   = 9.5;       // bracket length along the motor axis (verify)
brk_z     = 4.5;       // bracket centre above the gearbox face (middle of the gearbox)
m2_ins_d  = 3.0;       // M2x4x3.2 insert hole
m2_ins_l  = 4.6;
m2_clear  = 2.4;

/* [Arm] */
face_z    = 10;        // gearbox face above the auger top (fixed: couplers)
th_t      = 6.0;       // T-head plate
th_w      = 28;        // T-head width
box_w     = 16;        // box beam width
box_t     = 2.0;       // box walls
blk_d     = 10;        // end block depth (radial)
blk_w     = 18;        // end block width (fits the 20 mm pad)
shelf_t   = 3;
m3_ins_d  = 4.5;       // M3x6x5 insert hole
m3_ins_l  = 6.5;
face_screws = true;
face_screw_d = 1.9;    // M1.6 clearance
face_head_d  = 3.4;
face_head_h  = 1.4;
boss_hole = 5.0;       // gearbox bushing clearance

$fn = 64;

// ------------------------------ derived -------------------------------
x_th  = motor_d/2;                     // T-head face (motor flat sits on it)
x_th1 = x_th + th_t;
x_blk1 = Ri - 0.3;                     // block outer face (concave on Ri)
x_blk0 = x_blk1 - blk_d;
z0 = arm_zb;  z1 = arm_zb + arm_h;
zb = face_z + brk_z;                   // bracket / insert height

echo(str("ARM: underside z ", z0, " (coupler boss top 6), top z ", z1, ", gearbox face z ", face_z,
         ", motor back ~z ", face_z + gear_len + can_len + enc_len));
echo(str("Bracket inserts M2 at y = +-", brk_cc/2, ", z = ", zb, ".  Box beam ", x_th1, "..", x_blk0, " mm"));
assert(face_z - shelf_t == arm_zb, "shelf underside must be the print bed (= arm underside)");
assert(brk_cc/2 + m2_ins_d/2 + 1.5 < th_w/2, "T-head too narrow for the bracket");
assert(zb + 1.6 + 1 < z1, "insert above the arm top");

// ------------------------------ arm -----------------------------------
module arm() {
    difference() {
        union() {
            // T-head
            translate([x_th, -th_w/2, z0]) cube([th_t, th_w, arm_h]);
            // shelf under the gearbox
            translate([-motor_d/2 - 2, -th_w/2 + 4, z0]) cube([x_th1 + motor_d/2 + 2, th_w - 8, shelf_t]);
            // box beam (outer)
            translate([x_th1 - 0.01, -box_w/2, z0]) cube([x_blk0 - x_th1 + 0.02, box_w, arm_h]);
            // 45 deg flares where the beam meets the T-head and the block (stiff roots)
            for (s = [-1,1]) {
                hull() {
                    translate([x_th1 - 0.01, s > 0 ? box_w/2 - 0.01 : -th_w/2 + 2, z0]) cube([0.01, th_w/2 - box_w/2 - 2 + 0.01, arm_h]);
                    translate([x_th1 + th_w/2 - box_w/2 - 2, s > 0 ? box_w/2 - 0.01 : -box_w/2, z0]) cube([0.01, 0.01, arm_h]);
                }
                hull() {
                    translate([x_blk0, s > 0 ? box_w/2 - 0.01 : -blk_w/2, z0]) cube([0.01, blk_w/2 - box_w/2 + 0.01, arm_h]);
                    translate([x_blk0 - (blk_w/2 - box_w/2), s > 0 ? box_w/2 - 0.01 : -box_w/2, z0]) cube([0.01, 0.01, arm_h]);
                }
            }
            // end block, outer face concave on the bore
            intersection() {
                translate([x_blk0, -blk_w/2, z0]) cube([blk_d, blk_w, arm_h]);
                translate([0,0,z0 - 1]) cylinder(r = x_blk1, h = arm_h + 2, $fn = 240);
            }
        }
        // box hollow (open bottom would print fine too, but closed is stiffer)
        translate([x_th1 + 3, -box_w/2 + box_t, z0 + box_t]) cube([x_blk0 - x_th1 - 6, box_w - 2*box_t, arm_h - 2*box_t]);
        // motor clearance: keep the space in front of the T-head clear above the shelf
        translate([-motor_d/2 - 0.2, -motor_w/2 - 0.3, face_z]) cube([motor_d + 0.2 - 0.01, motor_w + 0.6, 50]);
        // gearbox bushing + face screws through the shelf
        translate([0,0,z0 - 1]) cylinder(d = boss_hole, h = shelf_t + 2, $fn = 40);
        if (face_screws) for (s = [-1,1]) translate([0, s*face_screw_spacing/2, z0 - 1]) {
            cylinder(d = face_screw_d, h = shelf_t + 2, $fn = 20);
            cylinder(d = face_head_d, h = 1 + face_head_h, $fn = 24);
        }
        // bracket inserts (M2) in the T-head, from the motor side
        for (s = [-1,1]) translate([x_th - 0.01, s*brk_cc/2, zb]) rotate([0,90,0]) cylinder(d = m2_ins_d, h = m2_ins_l, $fn = 24);
        // backbone screws: M3 inserts in the end block, from the outer face
        for (dz = screw_dz) translate([x_blk1 + 1, 0, z0 + dz]) rotate([0,-90,0]) cylinder(d = m3_ins_d, h = m3_ins_l + 1, $fn = 32);
    }
}

// ------------------------------ printed strap --------------------------
// copy of the factory bracket: U over the gearbox, two ears with M2 clearance
module strap() {
    u_w = motor_w + 0.3; u_d = motor_d - 0.3;   // slight squeeze across the flats
    t = 1.8; ear = 6.5; et = 2.0;
    difference() {
        union() {
            translate([-u_w/2 - t, -brk_len/2, 0]) cube([u_w + 2*t, brk_len, u_d + t]);
            hull() for (s = [-1,1]) translate([s*brk_cc/2, 0, 0]) cylinder(d = ear, h = et, $fn = 40);
            hull() for (s = [-1,1]) translate([s*brk_cc/2, 0, 0]) translate([-ear/2, -brk_len/2, 0]) cube([ear, brk_len, et]);
        }
        translate([-u_w/2, -brk_len/2 - 1, -1]) cube([u_w, brk_len + 2, u_d + 1]);
        for (s = [-1,1]) translate([s*brk_cc/2, 0, -1]) cylinder(d = m2_clear, h = 10, $fn = 24);
    }
}

// ------------------------------ assembly ------------------------------
module dummy_motor() {
    color("Gainsboro") translate([-motor_d/2, -motor_w/2, face_z]) cube([motor_d, motor_w, gear_len]);
    color("Silver") translate([0,0,face_z + gear_len]) linear_extrude(can_len) intersection() { circle(d = motor_w); square([motor_d, motor_w], center = true); }
    color("Black") translate([-motor_d/2 - 3, -9, face_z + gear_len + can_len]) cube([motor_d + 3, 18, 1.6]);
    color("White") translate([-motor_d/2 - 3, -6, face_z + gear_len + can_len + 1.6]) cube([6, 12, 6]);
    color("Silver") translate([0,0,face_z - shaft_len]) cylinder(d = shaft_d, h = shaft_len, $fn = 24);
}
// strap frame: x = along the ears, y = motor axis, z = out of the ear plane
module bracket_in_place() color("White")
    translate([x_th, 0, zb]) multmatrix([[0,0,-1,0],[1,0,0,0],[0,1,0,0],[0,0,0,1]]) strap();
module assembly() {
    color("Gold") arm();
    dummy_motor();
    bracket_in_place();
    color("SteelBlue", 0.25) difference() { translate([0,0,-40]) cylinder(r = Ri + 2, h = 40 + z1); translate([0,0,-41]) cylinder(r = Ri, h = 100); }
}

if (part == "arm")      translate([0,0,-z0]) arm();                // upright, underside on the bed
if (part == "strap")    strap();                                     // ears down
if (part == "assembly") assembly();
if (part == "section")  difference() { assembly(); translate([-100,0,-50]) cube(200); }
