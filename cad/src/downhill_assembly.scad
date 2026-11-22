// Downhill Dispatcher — full assembly preview (v8.1: exit opens north, team's rail box on the box mount)
// World frame: ramp's bottom edge on y = 0, tile floor z = 0, ramp rises toward +y (east), +x = south.
// Preview only. Print parts come from each source file.
use <downhill_shell.scad>
use <downhill_frame.scad>
use <downhill_crown.scad>
use <downhill_coupler_v5.scad>
use <downhill_box_mount.scad>
use <auger.scad>

show_auger  = true;
show_box    = true;
si   = shell_info();   // [z_a0, z_a1, shell_len, R, lean, n_pieces, T_y, T_z, z_w0, bb_a0, bb_a1, arm_a, arm_z, ...]
z_a0 = si[0]; z_a1 = si[1]; L = si[2]; T_y = si[6]; T_z = si[7]; arm_a = si[11];
auger_len = 635; auger_pieces = 3;
auger_piece_h = auger_len/auger_pieces;

place_tube() {
    tube_parts();
    if (show_auger) for (i = [0:auger_pieces-1]) translate([0,0,z_a0 + i*auger_piece_h]) color(i % 2 ? "Silver" : "Gainsboro") piece(i);
    translate([0,0,z_a1]) {
        rotate(arm_a) { color("Gold") arm(); dummy_motor(); bracket_in_place(); }
        color("Orange") coupler();
    }
}
// frame (its own origin is the tube base centre)
translate([0, T_y, T_z]) {
    world_from_tube(0.55*L) { color("Orange") collar_half(true); color("Gold") collar_half(false); }
    for (s = [-1,1]) { color("BurlyWood") seg(SbW(s), Fb(s), 6.35/2); color("Orange") translate(G(s)) foot(s); }
}
if (show_box) to_world() { color("Orange") mount_north(); color("Gold") mount_south(); box_ghost(); }
ramp_world();
color("LightGray", 0.5) translate([-241, -483, -1]) cube([482, 483, 1]);   // 19 x 19 in footprint, east edge at the ramp
