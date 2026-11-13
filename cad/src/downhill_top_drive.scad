// =====================================================================
// Downhill Dispatcher — top drive: N20 shaft coupler + motor mount cap
// ---------------------------------------------------------------------
// coupler     : plugs into the upper auger's top socket (19 mm x 30 deep,
//               25 mm OD collar — from auger.scad v4), flange sits on the
//               collar, D-bore takes the N20 3 mm D-shaft (+ M2 set screw).
//               Crush ribs + CA glue lock it in the round socket.
// motor_mount : cap over the shell top rim (skirt outside the shell OD, so
//               nothing enters the bore where the 110 mm flights spin).
//               3 spokes hold an N20 collet hub coaxial with the auger.
//               Radial M3 pilots in the skirt pin it to the shell.
//
// z = 0 is the TOP FACE of the upper auger piece.
// CLI: openscad -D 'part="coupler"' -o coupler.stl downhill_top_drive.scad
// =====================================================================

part = "assembly"; // [assembly, coupler, motor_mount]

/* [Auger top (from auger.scad v4)] */
top_socket_d = 19;
top_socket_h = 30;
top_od       = 25;
auger_od     = 110;  // flight OD — flights run right up to z = 0

/* [Shell — from downhill_shell.scad v1] */
tube_id      = 114;  // from auger.scad (measure!)
shell_od     = 117.2; // shell OD at the top rim
rim_z        = 10;   // shell rim height above the auger top face (shell rim_z)

/* [N20 — verify with calipers] */
motor_w    = 12.0;
motor_d    = 10.0;
body_len   = 24.0;   // gearbox face -> back of can
shaft_d    = 3.0;
shaft_flat = 2.5;    // across the D flat
shaft_len  = 10.0;   // from gearbox face
face_screw_spacing = 9.0;

/* [Coupler] */
plug_len   = 14;     // into the 30 mm socket
plug_fit   = 0.2;    // diametral under-size of plug core (ribs make the grip)
rib_n      = 6;
rib_h      = 0.25;   // rib height above nominal 19 mm (crushes on insert)
cf_t       = 2.0;    // flange on the 25 mm collar
boss_d     = 10;
boss_h     = 8;
shaft_eng  = 8.5;    // shaft engagement in the D-bore
d_clear    = 0.1;    // D-bore clearance (0 = tight press)
set_pilot  = 1.6;    // M2 set screw pilot (onto the D flat)

/* [Motor mount] */
pocket_clr = 0.2;
hub_wall   = 2.2;
floor_t    = 3.0;
boss_hole  = 5.0;
face_screw_d = 1.9;
face_head_d  = 3.4;
face_head_h  = 1.4;
wall_frac  = 0.85;
slit_w     = 1.0;
slit_from  = 7.0;
tie_w      = 3.4;
groove_d   = 0.8;
spokes     = 3;
spoke_w    = 4.0;
spoke_min_h = 6.0;
flange_t   = 2.4;
skirt_h    = 10;
skirt_t    = 2.0;
skirt_fit  = 0.25;   // radial clearance over the shell OD
set_d      = 2.5;    // M3 self-tap pilot (drill shell 3.2)
set_n      = 2;
flight_clear = 2.0;  // min gap above the auger top face

$fn = 96;

// ------------------------------ derived -------------------------------
boss_top = cf_t + boss_h;
face_z   = boss_top + (shaft_len - shaft_eng);   // gearbox face height
floor_z0 = face_z - floor_t;
pw = motor_w + 2*pocket_clr;  pd = motor_d + 2*pocket_clr;
hw = pw + 2*hub_wall;         hd = pd + 2*hub_wall;
wall_h = body_len*wall_frac;
sk_ri  = shell_od/2 + skirt_fit;
sk_ro  = sk_ri + skirt_t;
rib_z0 = max(flight_clear, min(floor_z0, rim_z + flange_t - spoke_min_h));
rib_z1 = max(face_z, rim_z + flange_t);

assert(floor_z0 >= flight_clear, "hub floor would hit the auger top");
echo(str("Gearbox face above auger top: ", face_z, " mm;  motor back at ", face_z + body_len,
         " mm (", face_z + body_len - rim_z, " mm above shell rim)"));
echo(str("Gap coupler boss -> gearbox face: ", face_z - boss_top, " mm"));

module hexagon(af, h) cylinder(d=af/cos(30), h=h, $fn=6);
module d_profile(d, flat) intersection() { circle(d=d, $fn=48); translate([-d, -d]) square([flat + d/2, 2*d]); }
// d_profile: circle of dia d with a flat at x = flat - d/2 (i.e. 'flat' measured across)

// ------------------------------ coupler -------------------------------
module coupler() {
    core_d = top_socket_d - plug_fit;
    difference() {
        union() {
            // plug + crush ribs
            translate([0,0,-plug_len]) cylinder(d=core_d, h=plug_len + 0.01);
            for (i=[0:rib_n-1]) rotate([0,0,i*360/rib_n + 30])
                translate([core_d/2 - 0.4, 0, -plug_len + 1.5])
                    cylinder(r=0.4 + rib_h + plug_fit/2, h=plug_len - 1.5, $fn=16);
            // lead-in chamfer at the plug tip
            // flange + boss
            cylinder(d=top_od, h=cf_t);
            cylinder(d=boss_d, h=boss_top);
        }
        // tip chamfer for easy insertion
        translate([0,0,-plug_len-0.01]) difference() {
            cylinder(d=top_socket_d + 2, h=1.2);
            cylinder(d1=core_d - 1.2, d2=core_d + 1.2, h=1.2);
        }
        // D-bore
        translate([0,0,boss_top - shaft_eng]) linear_extrude(shaft_eng + 1)
            offset(delta=d_clear/2) d_profile(shaft_d, shaft_flat);
        // set screw onto the flat (flat faces +x)
        translate([0,0,cf_t + boss_h/2]) rotate([0,90,0]) cylinder(d=set_pilot, h=boss_d, $fn=20);
        // lighten the plug
        translate([0,0,-plug_len-1]) cylinder(d=9, h=plug_len - 1);
    }
}

// ------------------------------ motor mount ---------------------------
module motor_mount() {
    difference() {
        union() {
            // cap: flange on the rim + skirt over the shell OD
            translate([0,0,rim_z]) difference() {
                union() {
                    cylinder(r=sk_ro, h=flange_t);
                    translate([0,0,-skirt_h]) cylinder(r=sk_ro, h=skirt_h + 0.01);
                }
                translate([0,0,-skirt_h-1]) cylinder(r=sk_ri, h=skirt_h + 1);        // skirt bore
                translate([0,0,-1]) cylinder(r=tube_id/2, h=flange_t + 2);         // open centre
            }
            // spokes: tall inside the bore, never below the rim outside it
            for (i=[0:spokes-1]) rotate([0,0,90 + i*360/spokes]) {
                translate([0, -spoke_w/2, rib_z0]) cube([tube_id/2 - 0.3, spoke_w, rib_z1 - rib_z0]);
                translate([0, -spoke_w/2, rim_z]) cube([tube_id/2 + 1, spoke_w, max(flange_t, rib_z1 - rim_z)]);
            }
            // hub
            translate([-hw/2, -hd/2, floor_z0]) cube([hw, hd, floor_t + wall_h]);
        }
        // motor pocket, shaft/boss, face screws (heads flush underneath)
        translate([-pw/2, -pd/2, face_z]) cube([pw, pd, wall_h + 1]);
        translate([0,0,floor_z0-1]) cylinder(d=boss_hole, h=floor_t+2);
        for (sx=[-1,1]) translate([sx*face_screw_spacing/2, 0, floor_z0-1]) {
            cylinder(d=face_screw_d, h=floor_t+2, $fn=24);
            cylinder(d=face_head_d, h=1+face_head_h, $fn=32);
        }
        // collet slits + zip tie groove
        for (sx=[-1,1], sy=[-1,1]) translate([sx*pw/2, sy*pd/2, face_z + slit_from])
            rotate([0,0, atan2(sy*pd, sx*pw)]) translate([-slit_w/2 + hub_wall, -slit_w/2, 0])
                cube([hub_wall*3, slit_w, wall_h]);
        translate([0,0, face_z + wall_h - tie_w - 1.5]) difference() {
            translate([-hw/2-1, -hd/2-1, 0]) cube([hw+2, hd+2, tie_w]);
            translate([-(hw/2-groove_d), -(hd/2-groove_d), -1]) cube([hw-2*groove_d, hd-2*groove_d, tie_w+2]);
        }
        // spoke tops must not cover the pocket
        translate([-pw/2, -pd/2, face_z]) cube([pw, pd, 50]);
        // anti-rotation pilots through the skirt, between spokes
        for (i=[0:set_n-1]) rotate([0,0,90 + 180/spokes + i*360/set_n])
            translate([sk_ri - 1, 0, rim_z - skirt_h/2]) rotate([0,90,0]) cylinder(d=set_d, h=skirt_t + 2, $fn=24);
    }
}

// ------------------------------ assembly ------------------------------
module assembly() {
    // auger top (dummy) + shell (dummy)
    color("Silver") difference() {
        union() { translate([0,0,-40]) cylinder(d=top_od, h=40); translate([0,0,-3]) cylinder(d=auger_od, h=1.6); }
        translate([0,0,-top_socket_h]) cylinder(d=top_socket_d, h=top_socket_h + 1);
    }
    color("SteelBlue", 0.3) translate([0,0,-60]) difference() {
        cylinder(d=shell_od, h=60 + rim_z); translate([0,0,-1]) cylinder(d=tube_id, h=60 + rim_z + 2);
    }
    color("Orange") coupler();
    color("Gold") motor_mount();
    // N20 dummy
    color("DimGray") translate([-motor_w/2, -motor_d/2, face_z]) cube([motor_w, motor_d, body_len]);
    color("Silver")  translate([0,0,face_z - shaft_len]) cylinder(d=shaft_d, h=shaft_len, $fn=24);
    color("SeaGreen") translate([-8, -8, face_z + body_len]) cube([16, 16, 1.6]);
}

if (part == "assembly")    assembly();
if (part == "coupler")     translate([0,0,plug_len]) coupler();            // plug down
if (part == "motor_mount") translate([0,0,skirt_h - rim_z]) motor_mount(); // skirt down
