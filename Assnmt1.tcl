#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red

#Open the NAM trace file
set nf [open out.nam w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} \
{
        global ns nf
        $ns flush-trace
        #Close the NAM trace file
        close $nf
        #Execute NAM on the trace file
        exec nam out.nam &
        exit 0
}

#Create four nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]

#Create links between the nodes
$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n0 $n3 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n3 $n2 2Mb 10ms DropTail
$ns duplex-link $n0 $n3 2Mb 10ms DropTail

set lan [$ns newLan "$n2 $n4 $n9" 0.5Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel]

$ns duplex-link $n4 $n5 2Mb 10ms DropTail
$ns duplex-link $n5 $n6 2Mb 10ms DropTail
$ns duplex-link $n4 $n6 2Mb 10ms DropTail
$ns duplex-link $n6 $n7 2Mb 10ms DropTail
$ns duplex-link $n6 $n8 2Mb 10ms DropTail
$ns duplex-link $n9 $n10 2Mb 10ms DropTail


#Set Queue Size of link (n2-n3) to 10
$ns queue-limit $n2 $n3 10

#Give node position (for NAM)

$ns duplex-link-op $n0 $n3 orient right
$ns duplex-link-op $n0 $n1 orient down
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n2 $n3 orient up

$ns duplex-link-op $n4 $n5 orient right	
$ns duplex-link-op $n5 $n6 orient down
$ns duplex-link-op $n4 $n6 orient right-down
$ns duplex-link-op $n6 $n7 orient left-down
$ns duplex-link-op $n6 $n8 orient right-down
$ns duplex-link-op $n9 $n10 orient right


#Monitor the queue for link (n2-n3). (for NAM)
$ns duplex-link-op $n2 $n3 queuePos 0.5


#Setup a TCP connection
set tcp [new Agent/TCP]
$tcp set class_ 2
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink
$tcp set fid_ 1

#Setup a FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP


#Setup a UDP connection
set udp1 [new Agent/UDP]
$ns attach-agent $n1 $udp1
set null [new Agent/Null]
$ns attach-agent $n10 $null
$ns connect $udp1 $null
$udp1 set fid_ 2

#Setup a CBR over UDP connection
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$cbr1 set packet_size_ 1000
$cbr1 set rate_ 1mb
$cbr1 set random_ false

#Setup a UDP connection
set udp2 [new Agent/UDP]
$ns attach-agent $n8 $udp2
set null [new Agent/Null]
$ns attach-agent $n0 $null
$ns connect $udp2 $null
$udp2 set fid_ 2

#Setup a CBR over UDP connection
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set type_ CBR
$cbr2 set packet_size_ 1000
$cbr2 set rate_ 1mb
$cbr2 set random_ false

#Schedule events for the CBR and FTP agents
$ns at 0.1 "$cbr1 start"
$ns at 0.5 "$cbr2 start"
$ns at 1.0 "$ftp start"
$ns at 3.5 "$ftp stop"
$ns at 4.0 "$cbr1 stop"
$ns at 4.5 "$cbr2 stop"

#Detach tcp and sink agents (not really necessary)
#$ns at 4.5 "$ns detach-agent $n0 $tcp ; $ns detach-agent $n3 $sink"

#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"

#Print CBR packet size and interval
puts "CBR packet size = [$cbr1 set packet_size_]"
puts "CBR interval = [$cbr1 set interval_]"

puts "CBR packet size = [$cbr2 set packet_size_]"
puts "CBR interval = [$cbr2 set interval_]"

#Run the simulation
$ns run
