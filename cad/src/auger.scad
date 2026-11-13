// Auger / Archimedes screw for Downhill Dispatcher  (v4: support-free V-flight, 627 bottom bearing, top coupling socket)
// Parametric rebuild of Auger_Archimedes_Screw.f3d
// Units: mm. Split into two halves to fit Bambu Lab X2D (260 mm Z).

/* [Main] */
outer_d      = 110;     // flight OD (unchanged from original)
total_len    = 381;     // 15 in (unchanged)
turns        = 6;       // pitch 63.5 mm: room for a steep, support-free V
flight_tilt  = -40;     // >=40 prints without supports. deg: + = umbrella (low at tube wall), - = cup (low at shaft)
tube_id      = 114;     // measure! flight OD should be tube_id - 3..4 mm
shaft_d      = 20;      // was 25 (-5 mm). Can go down to 10.
bore_d       = 0;       // no through-rod (screw spins on bottom bearing, driven from top)
flight_t     = 1.6;     // normal thickness: 4 lines @0.4 nozzle, no infill (original 0.8)

/* [Split joint] */
pieces       = 2;       // 381 mm > 260 mm build height
spigot_d     = 14;      // D-shaped key between halves (needs shaft_d >= 18)
spigot_flat  = 5;       // flat distance from center -> one orientation only
spigot_h     = 12;      // longer: glue the joint (no rod now)
fit_clear    = 0.2;     // radial clearance for printed fit

/* [Bottom bearing: 627 = 7 x 22 x 7, rides on fixed 7 mm pin] */
bearing_od   = 22;
bearing_w    = 7;
bearing_fit  = 0.15;    // pocket = OD + this (original Fusion pocket was 22.15)
hub_d        = 28;      // collar around the pocket (shaft is narrower than the bearing)
ledge_d      = 18;      // outer race seats on this ledge; inner race stays clear
pin_clear_d  = 8;       // relief above bearing for the 7 mm pin tip
pin_clear_h  = 6;

/* [Top: matches original Fusion shaft so the existing motor coupling fits] */
top_od       = 25;
top_socket_d = 19;
top_socket_h = 30;      // depth of coupling socket

/* [Output] */
part         = "assembly"; // [assembly, lower, upper]
seg_per_turn = 120;

pitch   = total_len / turns;
piece_h = total_len / pieces;
turns_per_piece = turns / pieces;   // fractional OK: each piece is phase-shifted
use_key = shaft_d >= spigot_d + 4 && pieces > 1;
assert(!(use_key && top_socket_h > piece_h - spigot_h - 5), "top socket too deep");

echo(str("pitch = ", pitch, " mm, clear gap between flights = ", pitch - flight_t, " mm"));
echo(str("helix angle @ r=35 mm = ", atan(pitch / (2*PI*35)), " deg"));

// ---- helical flight as a single polyhedron (fast, no CGAL sweep) ----
module flight(h, phase_turns = 0) {
    r_in  = shaft_d/2 - 0.6;           // buried slightly in shaft for a clean union
    r_out = outer_d/2;
    rise  = (r_out - r_in) * tan(flight_tilt);   // root sits higher than tip
    tv    = flight_t / cos(flight_tilt);         // vertical thickness
    ext   = (abs(rise) + tv) / pitch + 0.05;          // extra turns past each end, trimmed flat
    t0 = -ext; t1 = h/pitch + ext;
    n  = ceil((t1 - t0) * seg_per_turn);
    pts = [ for (i = [0:n]) let(
                tt = t0 + (t1 - t0) * i / n,
                a  = 360 * (tt + phase_turns),
                z  = tt * pitch,
                c = cos(a), s = sin(a))
            each [ [r_in*c,  r_in*s,  z + rise - tv/2],
                   [r_out*c, r_out*s, z - tv/2],
                   [r_out*c, r_out*s, z + tv/2],
                   [r_in*c,  r_in*s,  z + rise + tv/2] ] ];
    sides = [ for (i = [0:n-1], k = [0:3])
              [4*i + k, 4*(i+1) + k, 4*(i+1) + (k+1)%4, 4*i + (k+1)%4] ];
    caps  = [ [0, 1, 2, 3], [4*n + 3, 4*n + 2, 4*n + 1, 4*n] ];
    intersection() {
        polyhedron(pts, concat(sides, caps), convexity = 10);
        translate([-outer_d, -outer_d, 0]) cube([2*outer_d, 2*outer_d, h]);
    }
}

module d_shape(d, flat) {
    intersection() { circle(d = d, $fn = 64); translate([-d, -d]) square([d + flat, 2*d]); }
}

// idx: 0 = bottom piece ... pieces-1 = top piece
module bearing_pocket() {
    rp = (bearing_od + bearing_fit)/2; dp = bearing_w + 0.2;
    rl = ledge_d/2; rc = pin_clear_d/2;
    zc = dp + (rl - rc);                       // 45 deg cone: prints without support
    rotate_extrude($fn = 96) polygon([
        [0, -1], [rp + 0.8, -1], [rp + 0.8, 0], [rp, 0.8],   // entry chamfer
        [rp, dp], [rl, dp], [rc, zc], [rc, zc + pin_clear_h], [0, zc + pin_clear_h + rc]]);
}
function hub_h() = bearing_w + 0.2 + (ledge_d - pin_clear_d)/2 + 1;

module piece(idx) {
    h = piece_h;
    is_bottom = idx == 0; is_top = idx == pieces - 1;
    top_len = top_socket_h + 4;
    difference() {
        union() {
            cylinder(d = shaft_d, h = h, $fn = 96);
            flight(h, idx * turns_per_piece);   // continuous across joints
            if (is_bottom) {
                cylinder(d = hub_d, h = hub_h(), $fn = 96);
                translate([0, 0, hub_h()]) cylinder(d1 = hub_d, d2 = shaft_d, h = (hub_d - shaft_d)/2, $fn = 96);
            }
            if (is_top) {
                translate([0, 0, h - top_len]) cylinder(d = top_od, h = top_len, $fn = 96);
                translate([0, 0, h - top_len - (top_od - shaft_d)/2])          // 45 deg flare
                    cylinder(d1 = shaft_d, d2 = top_od, h = (top_od - shaft_d)/2 + 0.01, $fn = 96);
            }
            if (use_key && !is_top)                      // male key on top
                translate([0, 0, h - 0.01]) linear_extrude(spigot_h) d_shape(spigot_d, spigot_flat);
        }
        if (bore_d > 0)
            translate([0, 0, -1]) cylinder(d = bore_d, h = h + spigot_h + 2, $fn = 48);
        if (is_bottom) bearing_pocket();
        if (is_top) translate([0, 0, h - top_socket_h]) cylinder(d = top_socket_d, h = top_socket_h + 1, $fn = 96);
        if (use_key && !is_bottom)                       // female socket on bottom
            translate([0, 0, -0.01]) linear_extrude(spigot_h + 0.5)
                offset(delta = fit_clear) d_shape(spigot_d, spigot_flat);
    }
}

if (part == "lower") piece(0);
else if (part == "upper") piece(pieces - 1);
else if (part == "assembly") for (i = [0:pieces-1]) translate([0, 0, i * piece_h]) color(i % 2 ? "SteelBlue" : "Silver") piece(i);
