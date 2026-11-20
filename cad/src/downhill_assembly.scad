// Downhill Dispatcher — full assembly preview (v7: tower at the foot of the ramp)
// World frame: ramp's bottom edge on y = 0, tile floor z = 0, ramp rises toward +y.
// Preview only. Print parts come from each source file.
use <downhill_shell.scad>
use <downhill_frame.scad>
use <downhill_top_bar.scad>
use <auger.scad>

show_auger = true;
si   = shell_info();           // [z_a0, z_a1, shell_len, R, lean, n_pieces, T_y, T_z]
z_a0 = si[0]; z_a1 = si[1]; L = si[2]; R = si[3]; lean = si[4]; T_y = si[6]; T_z = si[7];
auger_len = 635; auger_pieces = 3;
auger_piece_h = auger_len/auger_pieces;

place_tube() {
    tube_parts();
    if (show_auger) for (i = [0:auger_pieces-1]) translate([0,0,z_a0 + i*auger_piece_h]) color(i % 2 ? "Silver" : "Gainsboro") piece(i);
}
// frame (its own origin is the tube base centre, ground at -R*sin(lean))
translate([0, T_y, T_z]) {
    world_from_tube(0.55*L) { color("Orange") collar_half(true); color("Gold") collar_half(false); }
    for (s = [-1,1]) { color("BurlyWood") seg(SbW(s), Fb(s), 6.35/2); color("Orange") translate(G(s)) foot(s); }
}
ramp_world();
color("LightGray", 0.5) translate([-241, -483, -1]) cube([482, 483, 1]);   // 19 x 19 in footprint, east edge at the ramp
