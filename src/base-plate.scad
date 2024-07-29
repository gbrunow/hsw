include <../libs/BOSL2/std.scad>
// include <../libs/BOSL2/screws.scad>

// Original OpenSCAD model
// https://www.printables.com/model/163200-openscad-parameterized-honeycomb-storage-wall

/* [Plate] */

Rows = 4;
Columns = 4;
// This can help odd-numbered segments fit together.
Mirror = false;

/* [Optional Rectangular Cutout] */

// Optional rectangular cutout to route larger cables through the wall or make room for a power outlet
Include_Cutout = false;

// Height of the cuttount in millimeter
Cutout_Height = 120;
// Width of the cuttount in millimeter
Cutout_Width = 70.5;
// Thickness of the frame in millimeters
Frame_Thickness = 3;
// Vertical offset, based on the center of the cutout, in millimeters.
Cutout_Vertical_Offset = 0;
// Horizontal offset, based on the center of the cutout, in millimeters.
Cutout_Horizontal_Offset = 0;

/* [Hidden] */
wall = 1.8;
height = 20;

// Calculates diameter of hexagon (long dialogal/width) based on the short diagonal (height)
function calc_hex_long_diagonal(short_diagonal) = (2 / sqrt(3) * short_diagonal);

// Calculates the edge length (length of one side) from the short diagonal (the height of the hexagon)
function calc_hex_edge_length(short_diagonal) = (short_diagonal / sqrt(3));

module cell(height, wall) {
  union() {
    tube(od = calc_hex_long_diagonal(height + wall * 2), id1 = calc_hex_long_diagonal(height) + 0.5, id2 = calc_hex_long_diagonal(height), h = 0.5, $fn = 6, anchor = BOTTOM);
    up(0.5)
      tube(od = calc_hex_long_diagonal(height + wall * 2), id = 2 / sqrt(3) * height, h = 4.5, $fn = 6, anchor = BOTTOM);
    up(5)
      tube(od = calc_hex_long_diagonal(height + wall * 2), id1 = calc_hex_long_diagonal(height), id2 = calc_hex_long_diagonal(height + wall), h = 1, $fn = 6, anchor = BOTTOM);
    up(6)
      tube(od = calc_hex_long_diagonal(height + wall * 2), id = calc_hex_long_diagonal(height + wall), h = 2, $fn = 6, anchor = BOTTOM);
  }
}

module section(Rows, Columns) {
  grid_copies(n = [Rows, Columns], spacing = sqrt(3) / 2 * (height + wall * 4), stagger = true) {
    zrot(30)
      cell(height, wall);
  }
}

module section_unioned_with_cutout(Rows, Columns) {
  if (Include_Cutout) {
    union() {
      difference() {
        section(Rows, Columns);
        translate([Cutout_Vertical_Offset, Cutout_Horizontal_Offset, 0])
          cuboid([Cutout_Height, Cutout_Width, 30]);
      }
      translate([Cutout_Vertical_Offset, Cutout_Horizontal_Offset, 0])
        rect_tube(size = [Cutout_Height, Cutout_Width], h = 8, wall = Frame_Thickness);
    }
  } else {
    section(Rows, Columns);
  }
}

module main() {
  if (Mirror) {
    section_unioned_with_cutout(Rows * 2, Columns);
  } else {
    mirror([1, 0, 0])
      section_unioned_with_cutout(Rows * 2, Columns);
  }
}

main();
