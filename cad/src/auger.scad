// Auger / Archimedes screw for Downhill Dispatcher  (v5: Level 3 height, umbrella flight, 3 pieces, lighter)
// Parametric rebuild of Auger_Archimedes_Screw.f3d
// Units: mm. Split into two halves to fit Bambu Lab X2D (260 mm Z).

/* [Main] */
outer_d      = 110;     // flight OD (unchanged from original)
total_len    = 635;     // 10 turns: puts the shell exits above the Level 3 rim (15.75 in)
turns        = 10;      // pitch 63.5 mm (same as v4)
flight_tilt  = 40;  // umbrella; print pieces flipped (export does this)     // >=40 prints without supports. deg: + = umbrella (low at tube wall), - = cup (low at shaft)
tube_id      = 114;     // measure! flight OD should be tube_id - 3..4 mm
shaft_d      = 20;      // was 25 (-5 mm). Can go down to 10.
bore_d       = 0;       // no through-rod (screw spins on bottom bearing, driven from top)
flight_t     = 1.2;     // normal thickness: 3 lines @0.4 nozzle (v4 was 1.6)

/* [Flight lightening: radial slots, narrower than a dowel (8 mm)] */
// Radial slots leave continuous ribs running down the flight's slope, so every
// layer sits on the one below (vertical hex holes left tiny floating slivers).
flight_holes = false;   // slots/holes in a sloped flight leave small floating fragments; solid prints clean
slot_w0      = 4.0;     // slot width at the inner end of each ring (widens to <= 5.5)
slot_rib     = 2.0;     // rib width at the inner end of each ring
slot_rings   = [[22, 30], [31.5, 43]];   // [r_in, r_out]; solid bands between (outer 12 mm of flight stays solid)

/* [Split joint] */
pieces       = 3;       // 635 / 3 = 211.7 mm each (X2D 260 mm Z)
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
part         = "assembly"; // [assembly, lower, middle, upper]
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

module flight_slots() {
    for (rg = slot_rings) let(ra = rg[0], rb = rg[1], ang = slot_w0/ra*180/PI,
                               n = floor(2*PI*ra/(slot_w0 + slot_rib)))
        for (k = [0:n-1]) rotate(k*360/n)
            polygon([[ra*cos(-ang/2), ra*sin(-ang/2)], [rb*cos(-ang/2), rb*sin(-ang/2)],
                     [rb*cos(ang/2),  rb*sin(ang/2)],  [ra*cos(ang/2),  ra*sin(ang/2)]]);
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
            if (use_key && !is_bottom)                   // male key on the BOTTOM (sticks up when printed flipped)
                translate([0, 0, -spigot_h + 0.01]) linear_extrude(spigot_h) d_shape(spigot_d, spigot_flat);
        }
        if (flight_holes)
            translate([0, 0, -1]) linear_extrude(h + 2) flight_slots();
        if (bore_d > 0)
            translate([0, 0, -1]) cylinder(d = bore_d, h = h + spigot_h + 2, $fn = 48);
        if (is_bottom) bearing_pocket();
        if (is_top) translate([0, 0, h - top_socket_h]) {                 // coupler socket, 45 deg end
            cylinder(d = top_socket_d, h = top_socket_h + 1, $fn = 96);
            translate([0, 0, -top_socket_d/2 + 0.01]) cylinder(d1 = 0, d2 = top_socket_d, h = top_socket_d/2, $fn = 96);
        }
        if (use_key && !is_top) translate([0, 0, h - spigot_h - 0.5]) {     // female socket on TOP, 45 deg end
            linear_extrude(spigot_h + 1) offset(delta = fit_clear) d_shape(spigot_d, spigot_flat);
            mirror([0, 0, 1]) linear_extrude(spigot_d/2 + fit_clear, scale = 0)
                offset(delta = fit_clear) d_shape(spigot_d, spigot_flat);
        }
    }
}

// Print parts come out UPSIDE DOWN (top end on the bed). With the umbrella flight
// that makes the flight grow out from the shaft; upright, its outer edge would
// print as an unsupported sliver on every layer.
module print_flip() translate([0, 0, piece_h]) rotate([180, 0, 0]) children();
if (part == "lower") print_flip() piece(0);
else if (part == "middle") print_flip() piece(1);
else if (part == "upper") print_flip() piece(pieces - 1);
else if (part == "assembly") for (i = [0:pieces-1]) translate([0, 0, i * piece_h]) color(i % 2 ? "SteelBlue" : "Silver") piece(i);
