/*

creates stands/legs for a shelf to sit on top of another flat surface
creative commons attribution licence. 2023 Adam Mead.
https://www.printables.com/model/481341-honeycomb-shelf-stands-parametric-openscad

uses homecomb lib by Gael Lafond.
https://www.printables.com/model/263718-honeycomb-library-openscad
*/


runlevel = 1;
$fn = 32;
//which side
side = "left"; //[left, right, center]
//do you want a back on it
back = false;
//distance from base to underside of shelf
leg_z = 100;
//front edge thickness of leg
leg_x = 10;
//side thickness of leg (depth)
leg_y = 40;

//this is how thick your shelf is
shelf_z = 10;
//size of the honeycomb hexes
honeysize = 10;
//printer nozzle size - this effects the wallsize
nozzle_size = 0.4;
//how many walls @nozzle_size - this effects the wallsize
walls = 4;
wallsize = nozzle_size * walls;

//will it be screwed to the shelf (no screw and double sided tape is probably nicer)
screw_support = "behind"; // [none, behind, beside]
//how far away from the leg the screw hole will be, for ease of screwing
screw_support_offset = 10;
//hole for your screw to go through
screw_dia = 3.2;
//do you want it countersunk
countersunk = true;
//diameter of the screw head
cs_dia = 6.0;
//depth of the screw head
cs_depth = 1.0;

module create_honey() {
    include <honeycomb.scad>
    rotate([90,0,90]) {
        difference() {
        translate([wallsize, wallsize, 0])  
            cube([leg_y-wallsize*2, leg_z-wallsize*2, leg_x]);
        translate([wallsize, wallsize, 0])  
            linear_extrude(height = leg_x) { 
                honeycomb(leg_y-(wallsize*2), leg_z-(wallsize*2), honeysize, wallsize);
            }
        }
            
            
    }
}

module top_back() {
    //this was entirely an afterthought, so it's a bit of a hack
    if (back == true) {
        translate([0,leg_y-wallsize,leg_z]) 
            cube([leg_x, wallsize, shelf_z]);
    }
}

module shelf_edgy() {
    difference() {
        translate([0,0,leg_z])
            cube([leg_x, leg_y, shelf_z]); 
        if (side == "left") {
        translate([wallsize, wallsize, leg_z])
            cube([leg_x, leg_y, shelf_z]);
        } else if (side == "right") {
        translate([0, wallsize, leg_z])
            cube([leg_x-wallsize, leg_y-wallsize, shelf_z]);
        } else if (side == "center") {
         translate([0, wallsize, leg_z])
            cube([leg_x, leg_y-wallsize, shelf_z]);           
        }

    }
    top_back();
}


module screw_supp() {
    difference() {
        cube([screw_support_offset+screw_dia+wallsize, screw_dia+(wallsize*2), wallsize]);
        translate([screw_support_offset, wallsize+(screw_dia/2), 0])
            cylinder(h = wallsize, d = screw_dia);
        if (countersunk == true) {
            translate([screw_support_offset, wallsize+(screw_dia/2), 0])
                cylinder(h = cs_depth, d1 = cs_dia, d2 = screw_dia);

        }
    } 
}

module s_left() {
    translate([screw_support_offset,leg_y/2-(screw_dia/2+wallsize), leg_z-wallsize])
            screw_supp();
}
module s_right() {
            translate([0,leg_y/2+(screw_dia/2+wallsize), leg_z-wallsize])
                rotate([0,0,180])
                    screw_supp();
}


module join_screw() {
    if (screw_support == "behind") {
        translate([(screw_dia/2)+(wallsize)+leg_x/2,leg_y, leg_z-wallsize])
            rotate([0,0,90])
                screw_supp();
    } else if (screw_support == "beside") {
        if (side == "left") {
            s_left();        }
        if (side == "right") {
            s_right();
        }
        if (side == "center") {
            s_right();
            s_left();
        }
    }

}

module create_leg() {
    difference() {
        cube([leg_x, leg_y, leg_z]);
        create_honey();
    }
}

if (runlevel == 1) {
    render(){
        union() {
            create_leg();
            shelf_edgy();
            join_screw();
        }
    }
    echo("***********************");
    echo("PLEASE READ THIS");
    echo("if you have a back on the leg, the shelf size will be smaller than the leg size");
    echo("consider this when designing your shelf supports");
    echo("WALLSIZE = ", wallsize, "because nozzle size is ", nozzle_size, "and walls is ", walls);
    echo();
    echo("meaning if you have a front and back, the shelf will be ", leg_y-(wallsize*2), "mm in depth from front to back, becase there are two walls");
    echo("***********************");

}
if (runlevel == 2) {
    render() {
        screw_supp();
    }
}