set min 1
set max 500
set my_x [expr {int(rand() * 100000)% ($max + 1 - $min) + $min }]
set my_y [expr {int(rand() * 1000) % ($max + 1 - $min) + $min}]
puts $my_x
puts $my_y
