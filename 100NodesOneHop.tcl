
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
		set yval [expr $yval + 70]
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
	 set xval [expr $xval +70 ]
	
	
	set incrval [expr $incrval+1]
}

$node(0) set X_ 350.0
$node(0) set Y_ 352.0
$node(0) set Z_ 0



set xval 0
set yval 0

for {set i 0} {$i < $val(nn)} {incr i} {
 $ns initial_node_pos $node($i) 10

set xval  [expr $xval + 50 ]


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



set posx(1) 280
set posy(1) 212
set posx(2) 350
set posy(2) 212
set posx(3) 420
set posy(3) 212
set posx(4) 490
set posy(4) 212
set posx(5) 490
set posy(5) 282
set posx(6) 490
set posy(6) 352
set posx(7) 490
set posy(7) 422
set posx(8) 490
set posy(8) 492
set posx(9) 420
set posy(9) 492

set posx(10) 350
set posy(10) 492
set posx(11) 280
set posy(11) 492
set posx(12) 210
set posy(12) 492
set posx(13) 210
set posy(13) 422
set posx(14) 210
set posy(14) 352
set posx(15) 210
set posy(15) 282
set posx(16) 210
set posy(16) 212

set n(1) 35

set n(2) 36

set n(3) 37

set n(4) 38

set n(5) 48 

set n(6) 58

set n(7) 68

set n(8) 78

set n(9) 77

set n(10) 76

set n(11) 75

set n(12) 74

set n(13) 64

set n(14) 54

set n(15) 44

set n(16) 34



	for {set i 0} {$i < 26} {incr i 1} {


	for {set j 1} {$j < 17} {incr j} {

	if {$j==1} {
	set onex $posx(1)	
	set oney $posy(1)			
			}


	if {$j<16} {
	set posx($j) $posx([expr $j+1])	
	set posy($j) $posy([expr $j+1])			
	
} else {
	set posx(16)  $onex	
	set posy(16) $oney			

	}

$ns at $i "$node($n($j)) setdest $posx($j) $posy($j) 150"
}


}


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





