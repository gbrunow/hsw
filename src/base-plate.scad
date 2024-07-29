// Original file:
// https://www.printables.com/model/380870-customizable-honeycomb-storage-wall-openscad

/* [ Plate Size ] */
// Select size calculation mode
Mode = "Row/Column Count";// [Row/Column Count, Max Dimensions]
Rows = 10;
Columns = 10;
// Max plate width in millimeters. Only used when in "Max Dimensions" mode.
Max_Plate_Width = 100;
// Max plate height in millimeters. Only used when in "Max Dimensions" mode.
Max_Plate_Height = 100;


/* [ Flat edges ] */
Left = false;
Top = false;
Right = false;
Bottom = false;

/* [Hidden] */

// Depth of the grid
depth = 8;
// Height of the hexagon's hole (flat side to flat side)
inner_short_diagonal = 20;
// Thickness of the wall forming each hexagon
wall_thickness = 1.8;

// Edges
edge_left = Left;
edge_top = Top;
edge_right = Right;
edge_bottom = Bottom;

// Calculated global variables

outer_short_diagonal = inner_short_diagonal + wall_thickness * 2;
outer_radius = outer_short_diagonal / sqrt(3);
outer_diameter = 2 * outer_radius;
half_outer_apothem = outer_radius / 2;

// Grid dimensions
max_grid_hexagons_x = Mode == "Row/Column Count" ? Columns : floor(Max_Plate_Height / outer_short_diagonal + (edge_top ? 0.5 : 0) + (edge_bottom ? 0.5 : 0));
max_grid_hexagons_y = Mode == "Row/Column Count" ? Rows : floor(Max_Plate_Width / (outer_diameter - half_outer_apothem) + (edge_left ? 0.5 : 0) + (edge_right ? 0.5 : 0));
total_width = max_grid_hexagons_x * (outer_diameter - half_outer_apothem) + half_outer_apothem;
total_height = outer_short_diagonal * max_grid_hexagons_y;

module wall(height, wall_thickness, length) {
  wall_height = height;
  back_fillet_start = wall_height - 5.1;
  back_fillet_end = 2;
  wall_bottom_thickness = wall_thickness;
  wall_top_thickness = wall_thickness - 1;
  front_fillet_size = 0.5;

  rotate([90, 0, 0])
    linear_extrude(length)
      polygon([
        [0, 0], 
        [0, wall_height], 
        [wall_bottom_thickness - front_fillet_size, wall_height], 
        [wall_bottom_thickness, wall_height - front_fillet_size], 
        [wall_bottom_thickness, back_fillet_start], 
        [wall_top_thickness, back_fillet_end], 
        [wall_top_thickness, 0]
      ]);
}

module hex(height, radius, wall_thickness, inner_short_diagonal) {
  for(i = [0:5]) {
    rotate([0, 0, i * 60 + 30])
      translate([-inner_short_diagonal / 2 - wall_thickness, radius / 2, 0])
        wall(height, wall_thickness, radius);
  }
}

module cell(height, radius, wall_thickness, inner_short_diagonal, left, top, right, bottom) {
  difference() {
    union() {
      hex(height, radius, wall_thickness, inner_short_diagonal);
      if (left)
        translate([0, outer_short_diagonal / 2, 0])
          wall(depth, wall_thickness, outer_short_diagonal);
      if (top)
        translate([outer_diameter / 2, 0, 0])
          rotate([0, 0, -90])
            wall(depth, wall_thickness, outer_diameter);
      if (right)
        translate([0, -outer_short_diagonal / 2, 0])
          rotate([0, 0, 180])
            wall(depth, wall_thickness, outer_short_diagonal);
      if (bottom)
        translate([-outer_diameter / 2, 0, 0])
          rotate([0, 0, 90])
            wall(depth, wall_thickness, outer_diameter);
    }
    if (left)
      translate([-outer_diameter / 2, -outer_short_diagonal, 0])
        cube([outer_diameter / 2, 2 * outer_short_diagonal, depth]);
    if (top)
      translate([-outer_diameter / 2, 0, 0])
        cube([outer_diameter, outer_short_diagonal, depth]);
    if (right)
      translate([0, -outer_short_diagonal, 0])
        cube([outer_diameter / 2, 2 * outer_short_diagonal, depth]);
    if (bottom)
      translate([-outer_diameter / 2, -outer_short_diagonal, 0])
        cube([outer_diameter, outer_short_diagonal, depth]);
  }
}


module plate(height, inner_short_diagonal, wall_width) {
  for(col = [0:(max_grid_hexagons_x - 1)]) {
    for(row = [0:(max_grid_hexagons_y - 1)]) {
      x = (outer_diameter - half_outer_apothem) * col;
      y = -(outer_short_diagonal) * (row + (col % 2) / 2);

      left = edge_left && col == 0;
      top = edge_top && row == 0 && col % 2 == (flip_staggering ? 1 : 0);
      right = edge_right && col == max_grid_hexagons_x - 1;
      bottom = edge_bottom && row + 1 == max_grid_hexagons_y && -y + outer_short_diagonal > total_height + 0.001 && -y + outer_short_diagonal / 2 <= total_height;

      translate([x, y, 0])
        cell(height, outer_radius, wall_width, inner_short_diagonal, left, top, right, bottom);
    }
  }
}

translate([edge_left ? 0 : outer_radius, edge_top ? 0 : -outer_short_diagonal / 2, 0])
  plate(depth, inner_short_diagonal, wall_thickness);
