include <libs/BOSL2/std.scad>
include <libs/BOSL2/screws.scad>

// Original OpenSCAD model
// https://www.printables.com/model/163200-openscad-parameterized-honeycomb-storage-wall
//
// OpenSCAD Parameterized Honeycomb Storage Wall
// Inspired by: https://www.printables.com/model/152592-honeycomb-storage-wall
// v1.0 - Initial version
// v1.1 - Updates
//        + Added tiny chamfer that was in the STEP file but not the diagram
//        + Added solid section modifier
//        + Added cutout modifier
//        + Added mirror modifier
//        + Added V-slot modifier
//        + Added mounting screws


/* [Size of the wall] */

// Number of hexagons to make in the X axis
numx=10;

// Number of hexagons to make in the Y axis
numy=10;

// Mirror along the X axis which can help odd-numbered segments fit together
odd = false;

/* [Wall Modifiers: Solid section]  */

// Solid section for extra modifiers
solid_section = false;

solid_start=7;
solid_end=9;

/* [Wall Modifiers: cutout]  */

// Cutout so you can route larger cables through the wall or make room for a power outlet
cutout = false;

cutout_wall = 3;
cutout_x = 46;
cutout_y = 75;
cutout_x_offset = 53;
cutout_y_offset = 0;

/* [Wall Modifiers: vslot]  */

// Vslot modifier so you can use nuts intended for 2020 extrusion in the front (only really useful with a solid section)
vslot = false;

vslot_length = 260;
vslot_x = 0;

/* [Wall Modifiers: mounting screw holes]  */

// Mounting screw hole modifier - Screws that will go through the front of the panel so you can bolt into a wall (only really useful with a solid section)
mounting_screw = false;

// Mounting screw hole size
mounting_screw_spec = "M4"; // [M3, M4, #6, #8]

// Mounting screw head shape
mounting_screw_head = "flat"; // [none, flat, socket, button, pan]

mounting_screw_spacing = 50;

mounting_screw_distance = 180;

mounting_screw_x = 0;

/* [Shape of the hexes - you probably don't want to mess with these]  */
// thickness of the thinner wall
wall=1.8; //[:0.01]

// Height of the hexagon
height=20;

// Calculates the long diagonal (the diameter of a circle inscribed on the hexagon) from the short diagonal (the height of the hexagon)
function ld_from_sd(short_diameter) =
    (2/sqrt(3)*short_diameter);
    
// Calculates the edge length (length of one side) from the short diagonal (the height of the hexagon)
function a_from_sd(short_diameter) =
    (short_diameter/sqrt(3));

module cell(height, wall) {
    union() {
        tube(od=ld_from_sd(height+wall*2), id1=ld_from_sd(height)+0.5, id2=ld_from_sd(height), h=0.5, $fn=6, anchor=BOTTOM);
        up(0.5) tube(od=ld_from_sd(height+wall*2), id=2/sqrt(3)*height, h=4.5, $fn=6, anchor=BOTTOM);
        up(5) tube(od=ld_from_sd(height+wall*2), id1=ld_from_sd(height),id2=ld_from_sd(height+wall), h=1, $fn=6, anchor=BOTTOM);
        up(6) tube(od=ld_from_sd(height+wall*2), id=ld_from_sd(height+wall), h=2, $fn=6, anchor=BOTTOM);
    }
}

module section(numx, numy) {
    grid_copies(n=[numx,numy], spacing=sqrt(3)/2 * (height+wall*4), stagger=true) {
        if (solid_section && $col > solid_start && $col <= solid_end) {
            zrot(30) cyl(d=2/sqrt(3)*(height+wall*2),h=8, anchor=BOTTOM,$fn=6);
        } else {
            zrot(30) cell(height, wall);
        }
    }
}

module section_unioned_with_cutout(numx,numy) {
    if (cutout) {
        union() {
            difference() {
                section(numx,numy);
                translate([cutout_x_offset,cutout_y_offset,0]) cuboid([cutout_x,cutout_y,30]);
            }
            translate([cutout_x_offset,cutout_y_offset,0]) rect_tube(size=[cutout_x,cutout_y], h=8, wall=cutout_wall);
        }
    } else {
        section(numx,numy);
    }
}

difference() {
    if (odd) {
        section_unioned_with_cutout(numx*2,numy);
    } else {
        mirror([1,0,0]) section_unioned_with_cutout(numx*2,numy);
    }
    if (vslot) {
        xrot(-90) right(vslot_x) fwd(9.9) down(vslot_length/2) linear_extrude(vslot_length) polygon([[-3,10],[-3,8.5],[-6,8.5],[-6,7],[-2.5,3.4],[2.5,3.4],[6,7],[6,8.5],[3,8.5],[3,10]]);
    }
    if (mounting_screw) {
        right(mounting_screw_x) ycopies(spacing=mounting_screw_spacing, l=mounting_screw_distance) screw_hole(mounting_screw_spec,head=mounting_screw_head,anchor=TOP,l=20,orient=BOTTOM);
    }
}
