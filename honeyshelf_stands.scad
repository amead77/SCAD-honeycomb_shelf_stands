/*
Creates leg supports for small shelves.  

Supports are designed to be optionally screwed into underside of leg and into below.
Designed for 3d printing.

creative commons attribution licence. 2023 Adam Mead.

uses homecomb lib by Gael Lafond.
https://www.printables.com/model/263718-honeycomb-library-openscad

big changes since last version:
  - added support for screwing to the base
  - added support for cube embossing or solid

*/

runlevel = 99; //0..98 = debug, 99 = normal, 100 = production

//detail for rendering
$fn = 32;
//leg support x
leg_x = 20.0;
//leg support y, this will be how deep the shelf is that sits on it, or more if having a lip
leg_y = 120.0;
//leg support z
leg_z = 200.0;
//leg emboss pattern
pattern = "honeycomb"; //["cubes", "none", "honeycomb"]
//pattern size
pattern_size = 10.0;
//pattern offset to centralise, do not use... yet. adjust pattern_size instead
pattern_offset_y = 0.0;
pattern_offset_z = 0.0;
//printer nozzle size - this effects the wallsize
nozzle_size = 0.4;
//how many walls @nozzle_size - this effects the wallsize
walls = 4;
wallsize = nozzle_size * walls;

//screw support top
screw_top_x = 10.0;
screw_top_y = 10.0;
screw_dia = 3.0;
screw_head_dia = 6.0;
screw_countersunk = true; //true, false
cs_depth = 2.0;
screw_top_direction = "beside"; //["behind", "none", "beside", "behind_up"]

//screw support base
screw_base_x = 10.0;
screw_base_y = 10.0;
screw_base_direction = "beside"; //["behind", "none", "beside", "behind_down"]

//screw offset, this is how far the screw is from the edge of the leg
screw_offset = 15.0;


//this is how high the support will extend above the support
shelf_z = 20.0;
shelf_supp_side = "right"; //["left", "right", "none"]
//remember that adding a front will reduce the depth of the shelf by wallsize
shelf_supp_front = true; //true, false
//remember that adding a rear will reduce the depth of the shelf by wallsize
shelf_supp_rear = false; //true, false

t = (screw_offset+(screw_head_dia/2)+wallsize);
/**
 * Honeycomb library
 * License: Creative Commons - Attribution
 * Copyright: Gael Lafond 2017
 * URL: https://www.thingiverse.com/thing:2484395
 *
 * Inspired from:
 *   https://www.thingiverse.com/thing:1763704
 */
////// begin honeycomb lib

// a single filled hexagon
module hexagon(l)  {
	circle(d=l, $fn=6);
}

// parametric honeycomb  
module honeycomb(x, y, dia, wall)  {
	// Diagram
	//          ______     ___
	//         /     /\     |
	//        / dia /  \    | smallDia
	//       /     /    \  _|_
	//       \          /   ____ 
	//        \        /   / 
	//     ___ \______/   / 
	// wall |            /
	//     _|_  ______   \
	//         /      \   \
	//        /        \   \
	//                 |---|
	//                   projWall
	//
	smallDia = dia * cos(30);
	projWall = wall * cos(30);

	yStep = smallDia + wall;
	xStep = dia*3/2 + projWall*2;

	difference()  {
		square([x, y]);

		// Note, number of step+1 to ensure the whole surface is covered
		for (yOffset = [0:yStep:y+yStep], xOffset = [0:xStep:x+xStep]) {
			translate([xOffset, yOffset]) {
				hexagon(dia);
			}
			translate([xOffset + dia*3/4 + projWall, yOffset + (smallDia+wall)/2]) {
				hexagon(dia);
			}
		}
	}
}
/////end honeycomb lib

//return the integer part of a float. this is just because my brain is in normal language mode
function int(float) = floor(float);

module Create_shelf_support() {
    //create shelf support
    if (shelf_supp_side == "left") {
        translate([0, 0, leg_z]) {
            cube([wallsize, leg_y, shelf_z], center = false);
        }
    } else if (shelf_supp_side == "right") {
        translate([leg_x-wallsize, 0, leg_z]) {
            cube([wallsize, leg_y, shelf_z], center = false);
        }
    }
    if (shelf_supp_front == true) {
        translate([0, 0, leg_z]) {
            cube([leg_x, wallsize, shelf_z], center = false);
        }
    }
    if (shelf_supp_rear == true) {
        translate([0, leg_y-wallsize, leg_z]) {
            cube([leg_x, wallsize, shelf_z], center = false);
        }
    }
}


module Screw_tab(direction = "UP") {
    difference() {
        //t = (screw_offset+(screw_head_dia/2)+wallsize);
        cube([t, t, wallsize]);
        translate([t/2, t/2, 0])
            cylinder(h = wallsize, d = screw_dia);
        if (screw_countersunk == true) {
            translate([t/2, t/2, 0]) {
                if (direction == "UP")
                    cylinder(h = cs_depth, d1 = screw_head_dia, d2 = screw_dia);
                else if (direction == "DOWN")
                    cylinder(h = cs_depth, d1 = screw_dia, d2 = screw_head_dia);
                //cylinder(h = cs_depth, d1 = screw_head_dia, d2 = screw_dia);
            }
        }
    }
}

module Create_screw_supprts() {
    //create screw supports
    if (screw_top_direction == "behind") {
        translate([leg_x/2-(t/2), leg_y, leg_z-wallsize])
            Screw_tab();
    } else if (screw_top_direction == "behind_up") {
        translate([leg_x/2-(t/2), leg_y, leg_z])
            //rotate tab up
            rotate([90, 0, 0])
                Screw_tab();
    } else if (screw_top_direction == "beside") {
        if ((shelf_supp_side == "left") || (shelf_supp_side == "none")) {
            translate([leg_x, (leg_y/2)-(screw_offset/2), leg_z-wallsize])
                Screw_tab();
        } 
        if ((shelf_supp_side == "right") || (shelf_supp_side == "none")) {
            translate([-t, (leg_y/2)-(screw_offset/2), leg_z-wallsize])
                    Screw_tab();
        }
        //translate([leg_x, leg_y/2, leg_z-wallsize])
        //        Screw_tab();
    } else if (screw_top_direction == "none") {
        //do nothing
    }
    if (screw_base_direction == "behind") {
        translate([leg_x/2-(t/2), leg_y, 0])
                Screw_tab(direction = "DOWN");
    } else if (screw_base_direction == "behind_down") {
        translate([leg_x/2-(t/2), leg_y-wallsize, 0])
            //rotate tab down
            rotate([-90, 0, 0])
                Screw_tab(direction = "DOWN");
    } else if (screw_base_direction == "beside") {
        if ((shelf_supp_side == "left") || (shelf_supp_side == "none")) {
            translate([leg_x, (leg_y/2)-(screw_offset/2), 0])
                    Screw_tab(direction = "DOWN");
        }
        if ((shelf_supp_side == "right") || (shelf_supp_side == "none")) {
            translate([-t, (leg_y/2)-(screw_offset/2), 0])
                    Screw_tab(direction = "DOWN");
        }
        //translate([leg_x, leg_y/2, wallsize])
        //    rotate([180, 0, 0])
        //        Screw_tab();
    } else if (screw_base_direction == "none") {
        //do nothing
    }
}


module Create_leg() {
    //create leg
    difference() {
        cube([leg_x, leg_y, leg_z], center = false);
        if (pattern == "cubes") {
            translate([0, wallsize+pattern_offset_y, wallsize+pattern_offset_z]) {
                    cube([leg_x, (leg_y-(wallsize*2))-pattern_offset_y, (leg_z-(wallsize*2))-pattern_offset_z], center = false);
            }
        } else if (pattern == "honeycomb") {
            translate([0, wallsize, wallsize]) {
                    cube([leg_x, (leg_y-(wallsize*2)), (leg_z-(wallsize*2))], center = false);
            }
        }
    }
}

module create_honey() {
    //create honeycomb
    rotate([0, 270, 0])
        linear_extrude(height = leg_x) { 
            honeycomb(leg_z-(wallsize*2), leg_y-(wallsize*2), pattern_size, wallsize);
        }

}

module Create_emboss() {
    //create emboss
    color("blue", 1.0)
        if (pattern == "cubes") {
            //create cubes
            ty = int(leg_y / (pattern_size+wallsize));
            echo("ty:", ty);
            tz = int(leg_z / (pattern_size+wallsize));
            echo("tz:", tz);
            difference() {
                cube([leg_x, leg_y-(pattern_offset_y+wallsize), leg_z-(pattern_offset_z+wallsize)], center = false);

                for (y = [0:1:ty]) {
                    for (z = [0:1:tz]) {
                        translate([0, (pattern_offset_y+y*(pattern_size+wallsize)), (pattern_offset_z+z*(pattern_size+wallsize))]) {
                            cube([leg_x, pattern_size, pattern_size], center = false);
                        }
                    }
                }
            }

        
        } else if (pattern == "honeycomb") {
            //create honeycomb
            if (pattern == "cubes") {
            translate([leg_x, pattern_offset_y+wallsize, pattern_offset_z+wallsize]) {
                    create_honey();
            }
            } else if (pattern == "honeycomb") {
                translate([leg_x, wallsize, wallsize]) {
                    create_honey();
                }
            }
        }
}

if (runlevel == 0) {
    //debug
    Create_leg();
} else if (runlevel == 1) {
    //debug
    Create_leg();
    translate([0, wallsize, wallsize])
        Create_emboss();
} else if (runlevel == 2) {
    //debug
    //difference() {
        //translate([0,0,0]) 
        //    Create_leg();
        translate([0, wallsize, wallsize])
            Create_emboss();
    //}
} else if (runlevel == 3) {
    //debug
    Create_screw_supprts();
} else if (runlevel == 99) {
    //normal mode
    render() {
            Create_leg();
            //translate([0, wallsize, wallsize])
            Create_emboss();
            Create_shelf_support();
            Create_screw_supprts();
    }
}