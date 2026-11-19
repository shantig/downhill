// =====================================================================
// Downhill Dispatcher — top drive v3: drop-in motor BAR + short coupler
// ---------------------------------------------------------------------
// Replaces motor_mount (ring + 3 spokes + skirt + set screws, needs
// supports) with one straight bar that drops into two slots cut in the
// shell rim. Slots stop rotation; tenon shoulders bear on the inner wall
// so the motor is centred on the auger axis. Gravity (or a zip tie)
// holds it down.
//
//   bar     : prints FLAT, as exported (bar + hub floor on the bed), no
//             supports.
//   coupler : plug into the auger's 19 mm top socket (auger.scad v5),
//             flange on the 25 mm collar, short boss with the N20 D-bore
//             and an M2 set screw. Prints plug down.
//             SUPERSEDED by downhill_coupler_v4.scad (zip-tie collet).
//   slot_cutter : the two rim slots, for cutting into shell_upper
//             (boolean in a slicer/CAD, or saw/file a printed shell).
//             Built into downhill_shell.scad v4 (bar_slots = true).
//
// Frame: z = 0 is the TOP FACE of the upper auger piece; the shell rim
// is at z = rim_z. Slots are on ±X (clear of the pod at +Y and the
// spout pad at -Y).
// CLI: openscad -D 'part="bar"' -o motor_bar.stl downhill_top_bar.scad
// =====================================================================

part = "assembly"; // [assembly, bar, coupler, slot_cutter]

/* [Shell (downhill_shell.scad)] */
tube_id  = 114;
shell_od = 116.4;
rim_z    = 10;      // rim above the auger top face

/* [Auger top (auger.scad v5)] */
top_socket_d = 19;
top_od       = 25;

/* [N20 — verify with calipers] */
motor_w    = 12.0;
motor_d    = 10.0;
body_len   = 24.0;
shaft_len  = 10.0;  // from gearbox face
shaft_d    = 3.0;
shaft_flat = 2.5;   // across the D flat
face_screw_spacing = 9.0;

/* [Bar] */
bar_z0     = 7;     // bar underside = hub floor underside (flat on the bed)
bar_h      = 6;     // bar depth (top sits 3 mm above the rim)
bar_w      = 7;     // inside the bore
tenon_w    = 5;     // through the rim slots
end_clr    = 0.2;   // shoulder -> inner wall, each end
tenon_out  = 1.5;   // tenon sticks out past the shell OD
slot_clr   = 0.2;   // per side, slot vs tenon
floor_t    = 3;
pocket_clr = 0.2;
hub_wall   = 2.2;
wall_frac  = 0.85;  // collet height as a fraction of body_len
boss_hole  = 5.0;   // gearbox bushing clearance
face_screw_d = 1.9;
face_head_d  = 3.4;
face_head_h  = 1.4;
slit_w     = 1.0;
slit_from  = 7.0;
tie_w      = 3.4;
groove_d   = 0.8;

/* [Coupler] */
plug_len  = 14;
plug_fit  = 0.2;    // diametral under-size of the core (ribs grip)
rib_n     = 6;
rib_h     = 0.25;
cf_t      = 2.0;    // flange on the 25 mm collar
boss_d    = 10;
boss_gap  = 1.0;    // coupler boss top -> hub floor underside
d_clear   = 0.3;    // D-bore clearance, diametral (v3.1: 0.1 was too tight)
set_pilot = 1.6;    // M2 set screw pilot, onto the flat

$fn = 96;

// ------------------------------ derived -------------------------------
Ri = tube_id/2;  R = shell_od/2;
face_z   = bar_z0 + floor_t;                // gearbox face
boss_top = bar_z0 - boss_gap;
shaft_tip = face_z - shaft_len;
shaft_eng = boss_top - shaft_tip;
pw = motor_w + 2*pocket_clr;  pd = motor_d + 2*pocket_clr;
hw = pw + 2*hub_wall;         hd = pd + 2*hub_wall;
wall_h = body_len*wall_frac;
body_half  = Ri - end_clr;
tenon_half = R + tenon_out;
slot_w = tenon_w + 2*slot_clr;
slot_bot = bar_z0 - 0.2;                    // tenon rests on the slot floor...
                                            // ...0.2 below the bar so the shoulders carry the centring

echo(str("BAR: underside ", bar_z0, " mm above auger top (flight clearance), top ", bar_z0 + bar_h,
         " (", bar_z0 + bar_h - rim_z, " above rim). Slots ", slot_w, " wide x ", rim_z - slot_bot, " deep on ±X"));
echo(str("COUPLER: boss ", cf_t, "..", boss_top, " mm, shaft engagement ", shaft_eng, " mm, gap to floor ", boss_gap));
echo(str("Motor back at ", face_z + body_len, " mm (", face_z + body_len - rim_z, " above rim)"));
assert(shaft_eng >= 5, "too little shaft in the coupler");
assert(boss_top - cf_t >= 3, "coupler boss too short for the set screw");
assert(slot_bot < rim_z - 1, "slot too shallow");

module d_profile(d, flat) intersection() { circle(d=d, $fn=48); translate([-d, -d]) square([flat + d/2, 2*d]); }

// ------------------------------ bar -----------------------------------
module bar() {
    difference() {
        union() {
            translate([-body_half, -bar_w/2, bar_z0]) cube([2*body_half, bar_w, bar_h]);
            translate([-tenon_half, -tenon_w/2, bar_z0]) cube([2*tenon_half, tenon_w, bar_h]);
            translate([-hw/2, -hd/2, bar_z0]) cube([hw, hd, floor_t + wall_h]);
        }
        // motor pocket, shaft bushing, face screws (heads flush underneath)
        translate([-pw/2, -pd/2, face_z]) cube([pw, pd, wall_h + 1]);
        translate([0,0,bar_z0-1]) cylinder(d=boss_hole, h=floor_t+2, $fn=40);
        for (sx=[-1,1]) translate([sx*face_screw_spacing/2, 0, bar_z0-1]) {
            cylinder(d=face_screw_d, h=floor_t+2, $fn=24);
            cylinder(d=face_head_d, h=1+face_head_h, $fn=32);
        }
        // collet slits + zip-tie groove
        for (sx=[-1,1], sy=[-1,1]) translate([sx*pw/2, sy*pd/2, face_z + slit_from])
            rotate([0,0, atan2(sy*pd, sx*pw)]) translate([-slit_w/2 + hub_wall, -slit_w/2, 0])
                cube([hub_wall*3, slit_w, wall_h]);
        translate([0,0, face_z + wall_h - tie_w - 1.5]) difference() {
            translate([-hw/2-1, -hd/2-1, 0]) cube([hw+2, hd+2, tie_w]);
            translate([-(hw/2-groove_d), -(hd/2-groove_d), -1]) cube([hw-2*groove_d, hd-2*groove_d, tie_w+2]);
        }
        // small chamfer on the tenon tips for easy drop-in
        for (s=[-1,1]) translate([s*tenon_half, 0, bar_z0 + bar_h]) rotate([0,45,0]) cube([1.4, tenon_w + 2, 1.4], center=true);
    }
}

// ------------------------------ rim slots ------------------------------
module slot_cutter() {
    for (s=[-1,1]) translate([s > 0 ? Ri - 3 : -R - 3, -slot_w/2, slot_bot])
        cube([R - Ri + 6, slot_w, rim_z - slot_bot + 5]);
}

// ------------------------------ coupler -------------------------------
module coupler() {
    core_d = top_socket_d - plug_fit;
    difference() {
        union() {
            translate([0,0,-plug_len]) cylinder(d=core_d, h=plug_len + 0.01);
            for (i=[0:rib_n-1]) rotate([0,0,i*360/rib_n + 30])
                translate([core_d/2 - 0.4, 0, -plug_len + 1.5])
                    cylinder(r=0.4 + rib_h + plug_fit/2, h=plug_len - 1.5, $fn=16);
            cylinder(d=top_od, h=cf_t);
            cylinder(d=boss_d, h=boss_top);
        }
        translate([0,0,-plug_len-0.01]) difference() {                      // tip chamfer
            cylinder(d=top_socket_d + 2, h=1.2);
            cylinder(d1=core_d - 1.2, d2=core_d + 1.2, h=1.2);
        }
        translate([0,0,shaft_tip - 0.5]) linear_extrude(boss_top - shaft_tip + 1)   // D-bore
            offset(delta=d_clear/2) d_profile(shaft_d, shaft_flat);
        translate([0,0,(cf_t + boss_top)/2]) rotate([0,90,0]) cylinder(d=set_pilot, h=boss_d, $fn=20);
        translate([0,0,-plug_len-1]) cylinder(d=9, h=plug_len - 2 + shaft_tip);  // lighten, 2.5 mm below the bore
    }
}

// ------------------------------ assembly ------------------------------
module assembly() {
    color("Silver") difference() {
        union() { translate([0,0,-40]) cylinder(d=top_od, h=40); translate([0,0,-3]) cylinder(d=110, h=1.6); }
        translate([0,0,-30]) cylinder(d=top_socket_d, h=31);
    }
    color("SteelBlue", 0.3) difference() {
        translate([0,0,-60]) difference() { cylinder(r=R, h=60 + rim_z); translate([0,0,-1]) cylinder(r=Ri, h=62 + rim_z); }
        slot_cutter();
    }
    color("Orange") coupler();
    color("Gold") bar();
    color("DimGray") translate([-motor_w/2, -motor_d/2, face_z]) cube([motor_w, motor_d, body_len]);
    color("Silver")  translate([0,0,shaft_tip]) cylinder(d=shaft_d, h=shaft_len, $fn=24);
}

if (part == "assembly")    assembly();
if (part == "bar")         translate([0,0,-bar_z0]) bar();                 // flat on the bed
if (part == "coupler")     translate([0,0,plug_len]) coupler();            // plug down
if (part == "slot_cutter") slot_cutter();                                  // shell_upper frame: see below
