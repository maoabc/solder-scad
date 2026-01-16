// T12-K Soldering Iron Tip Model (Revised for smoother transition and correct blade)
// Dimensions based on provided T12-K specifications

// Parameters (in mm)
total_length = 155;      // Total length of the tip
body_diameter = 5.5;     // Diameter of the cylindrical body
tip_diameter = 4.7;      // Diameter of the knife body
tip_thickness = 2.0;     // Thickness of the tip after flattening
tip_length = 15;         // Length of the tip section
tip_angle = 45;          // Angle of the knife edge (degrees)
blade_length = 7;        // Length of the blade section (from the start of the knife body)
blade_tip_thickness = 0.2; // Thickness at the very tip of the blade
body_length = total_length - tip_length; // Length of the cylindrical body

// Main body (cylindrical part)
module body() {
    cylinder(h = body_length, d = body_diameter, $fn = 100);
}

// Knife-shaped tip with blade
module tip() {
    translate([0, 0, body_length]) // Move to the end of the body
    union() {
        // Smooth transition from body (5.5 mm) to knife body (4.7 mm diameter, flattened to 2 mm)
        hull() {
            // Start at the body diameter
            cylinder(h = 0.1, d = body_diameter, $fn = 100);
            // Transition to the knife body (before flattening)
            translate([0, 0, (tip_length - blade_length) / 2])
            cylinder(h = 0.1, d = (body_diameter + tip_diameter) / 2, $fn = 100);
            // End at the knife body (before blade starts)
            translate([0, 0, tip_length - blade_length])
            difference() {
                cylinder(h = 0.1, d = tip_diameter, $fn = 100);
                // Flatten the sides to 2 mm thickness
                translate([-tip_diameter/2 - 1, tip_thickness/2, -0.1])
                cube([tip_diameter + 2, tip_diameter, 0.3]);
                translate([-tip_diameter/2 - 1, -tip_diameter - tip_thickness/2, -0.1])
                cube([tip_diameter + 2, tip_diameter, 0.3]);
            }
        }
        
        // Knife body (flattened to 2 mm thickness) and blade (cut at 45 degrees)
        translate([0, 0, tip_length - blade_length])
        difference() {
            // Base cylinder for the knife body (before flattening)
            cylinder(h = blade_length, d = tip_diameter, $fn = 100);
            // Flatten the sides to 2 mm thickness
            translate([-tip_diameter/2 - 1, tip_thickness/2, -0.1])
            cube([tip_diameter + 2, tip_diameter, blade_length + 0.2]);
            translate([-tip_diameter/2 - 1, -tip_diameter - tip_thickness/2, -0.1])
            cube([tip_diameter + 2, tip_diameter, blade_length + 0.2]);
            // Cut the blade at 45 degrees
            //translate([0, 0, blade_length])
            //rotate([0, -tip_angle, 0])
            //translate([-tip_diameter/2 - 1, -tip_thickness/2 - 1, 0])
            //cube([tip_diameter + 2, tip_thickness + 2, blade_length * 2]);
        }
        
        // Add the sharp blade tip
        //translate([0, 0, tip_length - blade_length])
        //hull() {
        //    translate([0, 0, 0])
        //    difference() {
        //        cylinder(h = 0.1, d = tip_diameter, $fn = 100);
        //        translate([-tip_diameter/2 - 1, tip_thickness/2, -0.1])
        //        cube([tip_diameter + 2, tip_diameter, 0.3]);
        //        translate([-tip_diameter/2 - 1, -tip_diameter - tip_thickness/2, -0.1])
        //        cube([tip_diameter + 2, tip_diameter, 0.3]);
        //    }
        //    translate([0, 0, blade_length])
        //    rotate([0, -tip_angle, 0])
        //    translate([-tip_diameter/2, -blade_tip_thickness/2, 0])
        //    cube([tip_diameter, blade_tip_thickness, 0.1]);
        //}
    }
}

// Combine body and tip
module t12_k_tip() {
    body();
    tip();
}

// Render the model
//t12_k_tip();
  for(i=[0:36]) {
    for(j=[0:36]) {
      color( [0.5+sin(10*i)/2, 0.5+sin(10*j)/2, 0.5+sin(10*(i+j))/2] )
      translate( [i, j, 0] )
      cube( size = [1, 1, 11+10*cos(10*i)*sin(10*j)] );
    }
  }
