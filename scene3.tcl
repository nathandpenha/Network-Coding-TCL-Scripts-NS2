set RXThresh 3.81429e-08

#===================================
#     Simulation parameters setup
#===================================
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                         ;# max packet in ifq
set val(nn)     6                         ;# number of mobilenodes
set val(rp)     SB                      ;# routing protocol
set val(x)      100                      ;# X dimension of topography
set val(y)      100                      ;# Y dimension of topography
set val(stop)   26

#


#===================================
#  Attaching selected headers    
#===================================

remove-all-packet-headers
add-packet-header Mac LL IP ARP LL SB

#===================================
#        Initialization        
#===================================
#Create a ns simulator
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

#===================================
#     Node parameter setup
#===================================
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

#===================================
#        Nodes Definition        
#===================================

for {set i 0} {$i<$val(nn)} {incr i} {
set node_($i) [$ns node]

}

for {set i 0} {$i<$val(nn)} {incr i} {
$node_($i) random-motion 0
 set udp($i) [new Agent/SB]
 $ns attach-agent $node_($i) $udp($i)
 $udp($i) set packetSize_ 1000

}


$ns at 0.0 "[$node_(0) set ragent_] base-station"
$node_(0) set X_ 0.0
$node_(0) set Y_ 20.0
$node_(0) set Z_ 0

$node_(1) set X_ 30.0
$node_(1) set Y_ 10.0
$node_(1) set Z_ 0

$node_(2) set X_ 70.0
$node_(2) set Y_ 30.0
$node_(2) set Z_ 0

$node_(3) set X_ 0.0
$node_(3) set Y_ 50.0
$node_(3) set Z_ 0

$node_(4) set X_ 80.0
$node_(4) set Y_ 65.0
$node_(4) set Z_ 0

$node_(5) set X_ 40.0
$node_(5) set Y_ 70.0
$node_(5) set Z_ 0

#$node_(6) set X_ 80.0
#$node_(6) set Y_ 90.0
#$node_(6) set Z_ 0

#$node_(7) set X_ 100.0
#$node_(7) set Y_ 50.0
#$node_(7) set Z_ 0

#$node_(8) set X_ 100.0
#$node_(8) set Y_ 70.0
#$node_(8) set Z_ 0




for {set i 0} {$i < $val(nn)} {incr i} {
 $ns initial_node_pos $node_($i) 10 
}



proc finish {} {
    global ns tracefile namfile 
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam out.nam &
    exit 0
}

#===================================
#  Reset the nodes   
#===================================

for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset"

}
#===================================
#  Simulation start up  
#===================================

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
puts "before sim run"
$ns run


