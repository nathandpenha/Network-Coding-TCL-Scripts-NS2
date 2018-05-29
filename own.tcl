
set RXThresh 3.81429e-08





set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                         ;# max packet in ifq
set val(nn)     9                         ;# number of mobilenodes
set val(rp)     SB                      ;# routing protocol
set val(x)      100                      ;# X dimension of topography
set val(y)      100                      ;# Y dimension of topography
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

for {set i 0} {$i<$val(nn)} {incr i} {
set node($i) [$ns node]
$node($i) random-motion 0
set udp($i) [new Agent/SB]
$ns attach-agent $node($i) $udp($i)
$udp($i) set packetSize_ 1000
}

$ns at 0.0 "[$node(0) set ragent_] base-station"
$node(0) set X_ 0.0
$node(0) set Y_ 0.0
$node(0) set Z_ 0

$node(1) set X_ 50.0
$node(1) set Y_ 0.0
$node(1) set Z_ 0

$node(2) set X_ 100.0
$node(2) set Y_ 0.0
$node(2) set Z_ 0

$node(3) set X_ 0.0
$node(3) set Y_ 50.0
$node(3) set Z_ 0

$node(4) set X_ 0.0
$node(4) set Y_ 100.0
$node(4) set Z_ 0

$node(5) set X_ 50.0
$node(5) set Y_ 50.0
$node(5) set Z_ 0

$node(6) set X_ 50.0
$node(6) set Y_ 100.0
$node(6) set Z_ 0

$node(7) set X_ 100.0
$node(7) set Y_ 50.0
$node(7) set Z_ 0

$node(8) set X_ 100.0
$node(8) set Y_ 100.0
$node(8) set Z_ 0



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





