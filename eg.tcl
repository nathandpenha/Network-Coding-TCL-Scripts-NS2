#variables initialization
set  val(nn)  26   
set  val(x)   500  
set  val(y)   500  
set ns [new Simulator   -broadcast on]
namespace import ::tcl::mathfunc::* ;# for using sin, cos functions
set namsize 30 ; # node size in nam file
set cx [expr $val(x) / 2]     ;# cx, cy the center of circle
set cy [expr $val(y) / 2]
set r [expr $cx -10]          ;# radius of circle
set PI 3.14159265358979323846
set ncars $val(nn)            ;# total number of cars
set lane 2                    ;# number lanes on the highway
set CarsPerLane [expr $ncars / $lane];# number of cars per lane
set CarsInFor [expr $ncars / $lane];# equal to CarsInLane. used in for loop
set i 0                       ;# iterator used in for loop	
# set node initial position, in this loop we distribute all node evenly at all lanes
for {set counter 0} {$counter < $lane} {incr counter} {
    while { $i < $CarsInFor  } {
            set node_($i) [$ns node]
            set angle [ expr ((360.0 / $CarsPerLane) * $i) * ($PI / 180) ]
            set pointx [ expr $cx + ($r * cos ($angle))]
            set pointy [ expr $cy + ($r * sin ($angle))]
            $node_($i) set X_ $pointx
            $node_($i) set Y_ $pointy
            $node_($i) set Z_ 0.0
            #set tcl_precision 3
            puts "Lane $counter N $i X = $pointx, Y = $pointy, Angle = $angle" ; # for logging only
            incr i
            }   
     set r [expr $r - $namsize]
     set CarsInFor [expr $CarsInFor + $CarsPerLane]
}
set theta 0;                                  ;# final angle
set deltatheta 0.1;                           ;# increment value
set numIntegrals [expr $PI * 2 / $deltatheta] ;# total number of integrals
set i 0; set CarsInFor $CarsPerLane                       ;# zeroing iterators
set r [expr $cx -10] ;# reset radius 
for {set counter 0} {$counter < $lane} {incr counter} {
    while { $i < $CarsInFor  } {
        set angle [ expr ((360.0 / $CarsPerLane) * $i) * ($PI / 180) ]
        set theta $angle                      ;# assign initial angle to theta
        for {set t 0} {$t < $numIntegrals} {incr t} {
            set theta [expr ($theta + $deltatheta)]
            set pointx [ expr $cx + ($r * cos ($theta))]
            set pointy [ expr $cy + ($r * sin ($theta))]
            #set tcl_precision 3                  ; # set tcl_precision for printing only
            #puts "L $counter N $i P $t X = $pointx, Y = $pointy, Angle = $theta"
            $ns at 0.0 "$node_($i) setdest $pointx $pointy 30.0" ;# is this correctly?
        }

        incr i
    }   
     set r [expr $r - $namsize]
     set CarsInFor [expr $CarsInFor + $CarsPerLane]
}
