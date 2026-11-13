// Downhill Dispatcher — full assembly preview (shell + auger + top drive + frame)
// Preview only. Print parts come from each source file.
use <downhill_shell.scad>
use <downhill_frame.scad>
use <downhill_top_drive.scad>
use <auger.scad>

show_auger = true;
si   = shell_info();           // [z_a0, z_a1, shell_len, R, lean]
z_a0 = si[0]; z_a1 = si[1]; L = si[2]; R = si[3]; lean = si[4];
auger_piece_h = 381/2;

module tube_frame() rotate([lean,0,0]) children();   // tube base centre at origin

tube_frame() {
    color("SteelBlue", 0.75)      render() shell_lower();
    color("LightSteelBlue", 0.75) render() shell_upper();
    color("Orange") render() boot();
    color("Orange") { render() spout(true); render() spout(false); }
    color("Orange") elec_pod();
    dummy_electronics();
    if (show_auger) for (i = [0:1]) translate([0,0,z_a0 + i*auger_piece_h]) color(i ? "Silver" : "Gainsboro") piece(i);
    translate([0,0,z_a1]) { color("Gold") motor_mount(); color("Orange") coupler();
        color("DimGray") translate([-6,-5,11.5]) cube([12,10,24]); }
}
// frame: collar + legs + feet
world_from_tube(0.55*L) { color("Orange") collar_half(true); color("Gold") collar_half(false); }
for (s = [-1,1]) { color("BurlyWood") seg(SbW(s), Fb(s), 6.35/2); color("Orange") translate(G(s)) foot(s); }
color("LightGray", 0.5) translate([-240, -460, -R*sin(lean) - 1]) cube([480, 560, 1]);
