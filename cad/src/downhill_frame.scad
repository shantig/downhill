// =====================================================================
// Downhill Dispatcher — lean-back support frame (motor stays at TOP)
// ---------------------------------------------------------------------
// Parts
//   collar_front / collar_back : split clamp around the shell (M3x16 x2)
//   foot_left / foot_right     : ramp feet with rod sockets
//   pod                        : electronics plate (driver board, LiPo,
//                                ANO encoder) zip-tied to the shell
//   Legs = 2 rods (1/4" hardwood dowel or 6 mm carbon tube), length is
//   echoed in the console ("ROD CUT LENGTH").
//
// Coordinate system (assembly): ground ≈ z=0, tube base centre at origin,
// tube leans BACK toward -Y by `lean` degrees from vertical.
//
// Select a part with `part`, then F6 + Export STL. Or from the CLI:
//   openscad -D 'part="collar_back"' -o collar_back.stl downhill_frame.scad
// =====================================================================

part = "assembly"; // [assembly, collar_front, collar_back, foot_left, foot_right]
// NOTE: the electronics pod now lives in downhill_shell.scad (upper face, near the motor).
show_old_pod = false;

/* [Shell — from downhill_shell.scad v2] */
shell_od  = 116.4; // shell OD (114 bore + 2 x 1.2 wall)
shell_len = 650.8; // shell length along its axis (base contact -> top)
lean      = 25;    // degrees from vertical, leaning back

/* [Legs] */
rod_d        = 6.35; // 1/4" dowel. Use 6.0 for 6 mm carbon tube
rod_clear    = 0.35; // diametral clearance in sockets (glue or friction)
collar_frac  = 0.55; // collar position as fraction of shell_len
foot_spread  = 150;  // each foot this far left/right of centreline
foot_behind  = 40;   // feet land this far behind the top's ground shadow
ground_dz    = 0;    // feet ground height vs. tube base contact (+ = higher)

/* [Collar] */
collar_h  = 18;
wall      = 3;
fit       = 0.2;   // radial clearance to shell
split_gap = 0.8;   // total gap between halves so the bolts can clamp
bolt_d    = 3.4;   // M3 clearance
nut_af    = 5.8;   // M3 nut across flats (+clearance)
nut_t     = 2.6;
ear_t     = 7;     // ear thickness per half (bolt = 2*ear_t + split_gap ≈ 15 -> M3x16)

/* [Electronics pod] */
pod_s      = 70;   // pod bottom edge position along shell axis
pod_gap    = 4;    // plate standoff from shell surface
plate_t    = 3;
plate_w    = 68;
plate_l    = 122;
saddle_t   = 6;
saddle_a   = 50;   // half-angle of shell contact per saddle
tie_w      = 3.4;  // zip tie tunnel width (along shell axis)
tie_h      = 1.8;  // zip tie tunnel height (radial)
standoff_hole = 2.9; // M2.5 screw clearance (uses the 16 mm M2.5 standoffs)
// General Driver for Robots: 65x65 board, M3 holes 49 x 58
drv_hole_x = 49;
drv_hole_z = 58;
drv_zc     = 40.5;
// LiPo 53.7 x 28.7 x 13.8 sits flat on the plate under the driver board
batt_w     = 28.7;
batt_l     = 53.7;
strap_w    = 2.6;  // slot width for a ~10–12 mm battery strap
strap_l    = 14;
// Adafruit ANO -> I2C adapter (#5740/#6310): M2.5 holes 30.48 x 35.56
ano_hole_x = 30.48;
ano_hole_z = 35.56;
ano_zc     = 96.3;

/* [Feet] */
foot_h     = 9;    // rod end height above ground
sole_r     = 13;
sole_t     = 3;
pad_recess = 0.8;  // shallow recess for a rubber/TPU pad (0 = none)

/* [Sockets] */
sock_wall  = 2.4;
sock_base  = 3;    // solid material behind rod end
sock_depth = 22;

$fn = 72;

// ------------------------------ maths ---------------------------------
R   = shell_od/2;
Ri  = R + fit;
Ro  = Ri + wall;
rod_rc = (rod_d + rod_clear)/2;
sock_r = rod_rc + sock_wall;

function rx(v,a) = [v[0], v[1]*cos(a)-v[2]*sin(a), v[1]*sin(a)+v[2]*cos(a)];
function unit(v) = v/norm(v);

Cw         = rx([0,0,collar_frac*shell_len], lean);   // collar centre (world)
ground_z   = -R*sin(lean) + ground_dz;
top_proj_y = rx([0,0,shell_len], lean)[1];

function G(s)    = [s*foot_spread, top_proj_y - foot_behind, ground_z]; // foot ground point
function Fb(s)   = G(s) + [0,0,foot_h];                                 // rod end at foot
function Fl(s)   = rx(Fb(s)-Cw, -lean);                                 // ... in collar frame
function az(s)   = atan2(abs(Fl(s)[0]), -Fl(s)[1]);                     // azimuth from -Y
function S(s)    = [s*sin(az(s)), -cos(az(s)), 0]*(Ro + sock_r - 1.5);  // socket root (collar frame)
function dirL(s) = unit(Fl(s)-S(s));
function SbL(s)  = S(s) + dirL(s)*sock_base;                            // rod end at collar
function SbW(s)  = Cw + rx(SbL(s), lean);
function dirW(s) = unit(Fb(s)-SbW(s));
function leg_len(s) = norm(Fb(s)-SbW(s));

echo(str("ROD CUT LENGTH (each, mm): ", round((leg_len(1)-1)*10)/10));
echo(str("Collar centre along shell (mm): ", collar_frac*shell_len));
echo(str("Leg angle from vertical (deg): ", round(acos(-dirW(1)[2])*10)/10));
echo(str("Footprint: base(0,0)  feet(±", foot_spread, ", ", round(G(1)[1]), ")  top shadow y=", round(top_proj_y)));

// ------------------------------ helpers -------------------------------
module seg(p1, p2, r) {
    d = p2 - p1; L = norm(d);
    translate(p1) rotate([0, acos(d[2]/L), atan2(d[1], d[0])]) cylinder(h=L, r=r);
}
module hexagon(af, h) cylinder(d=af/cos(30), h=h, $fn=6);

// ------------------------------ collar --------------------------------
bolt_x = Ri + 1.0 + bolt_d/2 + wall*0 + 1.2;
ear_w  = bolt_x + bolt_d/2 + 2.6 - (Ri + 0.5);
ear_x0 = Ri + 0.5;

module collar_half(back) {
    sg = back ? -1 : 1;
    difference() {
        union() {
            intersection() {
                cylinder(r=Ro, h=collar_h, center=true);
                translate([-100, back ? -200 - split_gap/2 : split_gap/2, -50]) cube([200,200,100]);
            }
            for (sx=[-1,1])
                translate([sx>0 ? ear_x0 : -ear_x0-ear_w, back ? -split_gap/2-ear_t : split_gap/2, -collar_h/2])
                    cube([ear_w, ear_t, collar_h]);
            if (back) for (s=[-1,1]) socket_solid(s);
        }
        cylinder(r=Ri, h=600, center=true);
        for (sx=[-1,1]) translate([sx*bolt_x, 0, 0]) {
            rotate([90,0,0]) cylinder(d=bolt_d, h=60, center=true);
            if (!back) translate([0, split_gap/2+ear_t-nut_t, 0])
                rotate([-90,0,0]) rotate([0,0,30]) hexagon(nut_af, nut_t+1);
        }
        if (back) for (s=[-1,1]) seg(SbL(s), SbL(s)+dirL(s)*(sock_depth+5), rod_rc);
        // keep each half on its own side of the split
        translate([-100, back ? -split_gap/2 : -200+split_gap/2, -100]) cube([200,200,200]);
    }
}

module socket_solid(s) {
    p = S(s); d = dirL(s);
    seg(p, p + d*(sock_base+sock_depth), sock_r);
    hull() {
        seg(p + d*0.05, p + d*7, sock_r*0.999);
        rotate([0,0, s*az(s)]) translate([0, -(Ri+wall/2), 0]) cube([2*sock_r, wall, collar_h], center=true);
    }
}

// ------------------------------ foot ----------------------------------
// Built with the ground contact point at the origin, sole on z=0.
module foot(s) {
    fb = [0,0,foot_h]; u = dirW(s);   // u points down the leg into the foot
    difference() {
        union() {
            cylinder(r=sole_r, h=sole_t);
            hull() {
                cylinder(r=sole_r*0.75, h=sole_t);
                seg(fb + u*(sock_base-0.05), fb - u*7, sock_r*0.999);
            }
            seg(fb + u*sock_base, fb - u*sock_depth, sock_r);
        }
        seg(fb, fb - u*(sock_depth+5), rod_rc);
        translate([-50,-50,-50]) cube([100,100,50]);
        if (pad_recess > 0) translate([0,0,-1]) cylinder(r=sole_r-2.5, h=1+pad_recess);
    }
}

// ------------------------------ pod -----------------------------------
// Pod frame: shell axis = +Z, plate behind the shell (-Y), z=0 at pod bottom.
plate_y0 = -(R + pod_gap);            // inner face of plate
plate_y1 = plate_y0 - plate_t;        // outer face (components side)

function drv_holes() = [for (i=[-1,1], j=[-1,1]) [i*drv_hole_x/2, drv_zc + j*drv_hole_z/2]];
function ano_holes() = [for (i=[-1,1], j=[-1,1]) [i*ano_hole_x/2, ano_zc + j*ano_hole_z/2]];
strap_x = batt_w/2 + 1.2 + strap_w/2;

module through_y(x, z, d) translate([x, plate_y0+1, z]) rotate([90,0,0]) cylinder(d=d, h=plate_t+2);

module saddle(z0) {
    sx = R*sin(saddle_a) + 2;
    difference() {
        translate([-sx, plate_y0 - 0.01, z0]) cube([2*sx, R + pod_gap - R*cos(saddle_a) + 0.01, saddle_t]);
        translate([0,0,z0-1]) cylinder(r=Ri, h=saddle_t+2);
        // zip tie tunnel following the shell curvature
        translate([0,0,z0 + (saddle_t-tie_w)/2]) difference() {
            cylinder(r=Ri + 1.0 + tie_h, h=tie_w);
            translate([0,0,-1]) cylinder(r=Ri + 1.0, h=tie_w+2);
        }
    }
}

module hex_grid(af=9, rib=2.2) {
    p = af + rib;
    for (i=[-6:6], j=[-1:14])
        translate([i*p*cos(30)*1.0 + 0, 0, j*p + (abs(i)%2)*p/2])
            rotate([90,0,0]) rotate([0,0,0]) cylinder(d=af/cos(30), h=40, center=true, $fn=6);
}

module pod_keepouts() {
    for (h=concat(drv_holes(), ano_holes())) translate([h[0], 0, h[1]]) rotate([90,0,0]) cylinder(r=5.5, h=80, center=true);
    for (sx=[-1,1]) translate([sx*strap_x - strap_w/2 - 2.5, -40, drv_zc - strap_l/2 - 2.5]) cube([strap_w+5, 80, strap_l+5]);
    translate([-50,-40,-1]) cube([100,80,saddle_t+3]);
    translate([-50,-40,plate_l-saddle_t-2]) cube([100,80,saddle_t+3]);
}

module pod() {
    difference() {
        union() {
            translate([-plate_w/2, plate_y1, 0]) cube([plate_w, plate_t, plate_l]);
            saddle(0);
            saddle(plate_l - saddle_t);
        }
        for (h=concat(drv_holes(), ano_holes())) through_y(h[0], h[1], standoff_hole);
        for (sx=[-1,1]) translate([sx*strap_x - strap_w/2, plate_y1-1, drv_zc - strap_l/2]) cube([strap_w, plate_t+2, strap_l]);
        // lightening
        intersection() {
            translate([0, (plate_y0+plate_y1)/2, 0]) hex_grid();
            difference() {
                translate([-plate_w/2+3.5, -200, 3]) cube([plate_w-7, 400, plate_l-6]);
                pod_keepouts();
            }
        }
    }
}

// ------------------------------ assembly ------------------------------
module world_from_tube(s) translate(rx([0,0,s], lean)) rotate([lean,0,0]) children();

module assembly() {
    // shell (dummy)
    world_from_tube(0) color("SteelBlue", 0.35) difference() {
        cylinder(r=R, h=shell_len); translate([0,0,-1]) cylinder(r=R-2.5, h=shell_len+2);
    }
    // collar
    world_from_tube(collar_frac*shell_len) {
        color("Orange") collar_half(true);
        color("Gold")   collar_half(false);
    }
    // legs + feet
    for (s=[-1,1]) {
        color("BurlyWood") seg(SbW(s), Fb(s), rod_d/2);
        color("Orange") translate(G(s)) foot(s);
    }
    // old pod (superseded by downhill_shell.scad)
    if (show_old_pod) world_from_tube(pod_s) {
        color("Orange") pod();
        color("DimGray", 0.9) translate([-batt_w/2, plate_y1-13.8, drv_zc-batt_l/2]) cube([batt_w, 13.8, batt_l]);
        color("SeaGreen", 0.9) translate([-32.5, plate_y1-16-1.6, drv_zc-32.5]) cube([65, 1.6, 65]);
        color("Black", 0.9) translate([-17.78, plate_y1-16-1.6, ano_zc-20.32]) cube([35.56, 1.6, 40.64]);
        color("Black", 0.9) translate([0, plate_y1-16-1.6, ano_zc]) rotate([90,0,0]) cylinder(d=31.4, h=6);
    }
    // ground
    color("LightGray", 0.4) translate([-200, -450, ground_z-1]) cube([400, 550, 1]);
}

// ------------------------------ output --------------------------------
if (part == "assembly")     assembly();
if (part == "collar_back")  translate([0,0,-split_gap/2]) rotate([-90,0,0]) collar_half(true);
if (part == "collar_front") translate([0,0,-split_gap/2]) rotate([90,0,0]) collar_half(false);
if (part == "foot_left")    foot(-1);
if (part == "foot_right")   foot(1);
if (part == "pod")          translate([0,0,-plate_y1]) rotate([90,0,0]) pod();
