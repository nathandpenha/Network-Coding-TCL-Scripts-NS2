
set RXThresh 3.81429e-08





set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 100                         ;# max packet in ifq
set val(nn)     101                        ;# number of mobilenodes
set val(rp)     SB                      ;# routing protocol
set val(x)      500                      ;# X dimension of topography
set val(y)      500                      ;# Y dimension of topography
set val(stop)   26



remove-all-packet-headers
add-packet-header Mac LL IP ARP LL SB

set ns [new Simulator   -broadcast on]

#Setup topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)


#Open the NS trace file
set tracefile [open out.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open out.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)
set chan [new $val(chan)];#Create wireless channel

Mac/802_11 set dataRate 512Kbps
Phy/WirelessPhy set RXThresh_ $RXThresh

$ns node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -channel       $chan \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      ON \
                -movementTrace OFF \


set xval 1
set yval 2
set incrval 0


set node(0) [$ns node]
$node(0) random-motion 0
set udp(0) [new Agent/SB]
$ns attach-agent $node(0) $udp(0)
$udp(0) set packetSize_ 1000
$ns at 0.0 "[$node(0) set ragent_] base-station"
$node(0) set X_ 250.0
$node(0) set Y_ 250.0
$node(0) set Z_ 0


for {set i 1} {$i<$val(nn)} {incr i} {
	 if {[expr {$incrval==10}]} {
		set yval [expr $yval + 50]
		set incrval 0
		set xval 0		
	}
	 
	set node($i) [$ns node]
	$node($i) random-motion 0
	set udp($i) [new Agent/SB]
	$ns attach-agent $node($i) $udp($i)
	$udp($i) set packetSize_ 1000
	$node($i) set X_ $xval
	$node($i) set Y_ $yval
	$node($i) set Z_ 0

	puts $xval
	puts $yval
	 set xval [expr $xval +50 ]
	
	
	set incrval [expr $incrval+1]
}

$node(0) set X_ 50.0
$node(0) set Y_ 50.0
$node(0) set Z_ 0


for {set i 0} {$i < $val(nn)} {incr i} {
 $ns initial_node_pos $node($i) 10



}





set sink [new Agent/Null]
$ns attach-agent $node(2) $sink
$ns connect $udp(0) $sink
set ftp [new Application/FTP]
$ftp attach-agent $udp(0)
$ns at 10.0 "$ftp start" 




set udp0 [new Agent/UDP]
        $ns attach-agent $node(0) $udp(0)

set cbr0 [new Application/Traffic/CBR]
        $cbr0 attach-agent $udp(0)
        $udp(0) set packetSize_ 536	# set MSS to 536 bytes;

        set null0 [new Agent/Null]
        $ns attach-agent $node(1) $null0
        $ns connect $udp(0) $null0
        $ns at 1.0 "$cbr0 start"

set x 0
set y 0
set min 0
set max 500
set posx(1) 1


for {set i 1} {$i<$val(nn)} {incr i 1} {
 set posx($i) [expr {int(rand() * 100) % ($max + 1 - $min) + $min}] 
}

set posy(1) 1
for {set i 1} {$i<$val(nn)} {incr i 1} {
 set posy($i) [expr {int(rand() * 100) % ($max + 1 - $min) + $min}] 
}
set j 50
for {set i 1} {$i<100} {incr i} {
	

	set my_x [expr {int(rand() * 100000) % ($max + 1 - $min) + $min}]
	set my_y [expr {int(rand() * 1000) % ($max + 1 - $min) + $min}]
	
	$ns at { format %.12f [expr $i/4] } "$node($i) setdest $my_x $my_y 200"
	
	

	#set my_x [expr {int(rand() * 100000) % ($max + 1 - $min) + $min}]
	#set my_y [expr {int(rand() * 1000) % ($max + 1 - $min) + $min}]
		
	#$ns at { format %.8f [expr $i/4] } "$node($i) setdest $my_x $my_y 200"	
	
	#$ns at $i/5 "$node($i) setdest $my_x $my_y 200"
	
	#$ns at  [expr $i/5]  "$node([expr $i]) setdest $posx($i) $posy($i) 10"

	#$ns at  [expr $i/7]  "$node([expr $i]) setdest $posx($i) $posy($i) 10"
	#$ns at  [expr $i/6]  "$node([expr $i]) setdest $posx($i) $posy($i) 16.6"

	#$ns at  [expr $i/8]  "$node([expr $i/2]) setdest $posx($i) $posy($i) 16.6"
	#$ns at  [expr $i/4]  "$node([expr $i]) setdest $posx($i) $posy($i) 16.6"

	#$ns at  [expr $i/10]  "$node([expr $i/2]) setdest $posx($i) $posy($i) 16.6"
	
	
	}

#$ns at 4.0 "$node(17) setdest 250 150 16.6"
#$ns at 4.0 "$node(16) setdest 300 170 16.6"


#$ns at 10.0 "$node(12) setdest 150 150 16.6"
#$ns at 10.0 "$node(9) setdest 200 200 16.6"
#$ns at 1.0 "$node(8) setdest 150 200 16.6"
#$ns at 1.0 "$node(13) setdest 200 150 16.6"


#$ns at 3.0 "$node(3) setdest 200 250 16.6"
#$ns at 3.0 "$node(7) setdest 100 250 16.6"
#$ns at 3.0 "$node(11) setdest 150 250 16.6"

#$ns at 7.0 "$node(6) setdest 200 100 16.6"
#$ns at 7.0 "$node(10) setdest 100 100 16.6"
#$ns at 7.0 "$node(14) setdest 150 100 16.6"

#$ns at 5.0 "$node(13) setdest 150 200 16.6"
#$ns at 5.0 "$node(8) setdest 200 150 16.6"

proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam out.nam &
    exit 0
}

for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node($i) reset"
}



$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
puts "before sim run"
$ns run





