##UDP Sockets

DIS doesn't hide TCP/IP socket level programming from users. It's up to the programmer to handle these tasks. This is not all that difficult to do, but there are some historical issues that may confuse programmers, in particular on modern hosts with several network interfaces. 

###Broadcast
Many DIS simulation implementations use broadcast UDP sockets. This allows one datagram to be sent, and N other participating simulations on the same network to receive that single message. This avoids having the sender transmit N-1 datagrams addressed to each individual participant. If designed today DIS would have instead used multicast, but multicast didn't exist when DIS was designed. As a result there's a installed base of DIS applications that use UDP broadcast on port 3000. There's nothing that prevents multicast from being used--it's a perfectly valid choice, and in fact preferred. But the reality of the installed base draws people to broadcast. 

Broadcast can create some issues. I'll describe a couple scenarios. The first one is likely to work out of the box, but it's possible that network switch configuration or multiple host network interfaces will cause problems. If that's the case, you can fall back to a slightly more complex option.

####The Default Broadcast Solution

In the old days Unix workstations typically had two IPv4 network interfaces:  the loopback interface, lo0 or the like, that had an IP address of 127.0.0.1 associated with it, and an ethernet interface, often en0, that had a public IP address associated with it, such as 172.20.81.4. When you created a UDP socket it "bound" to both IPs via "INADDRANY" or the special IP address 0.0.0.0, meaning the socket was associated with both the 127.0.0.1 and 172.20.81.4 IP addresses. The socket could *listen* for incoming messages on both IPs. When you *sent* a datagram to the special, reserved address "255.255.255.255" it would be sent on all IPs on which the host is bound. 

There's been inconsistent behavior on TCP/IP implementations, though. Often in practice the message would go out over only one interface, as determined by the routing table of the host machine. This was the default IP address, very often the last interface brought up, usually en0. Because there was only one interface, it almost always worked. This is in fact probably the approach you should start out with: create a socket on INADDR_ANY, which binds it to all IPs; send to the broadcast address 255.255.255.255, which should send it out on the default IP address. This sometimes fails, though; some smart network switch ports will disallow it for security reasons. It's better to explictly state the broadcast address to use.

An example of creating and sending data on a UDP broadcast socket using the default approach is below:

~~~~
import java.net.*;
import edu.nps.moves.dis.*;

....
MulticastSocket socket = null;
String BROADCAST_ADDRESS = "255.255.255.255";
EntityStatePdu pdu = new EntityStatePdu();

try
{           
    socket = new MulticastSocket(DIS_DESTINATION_PORT);
    byte data[] = pdu.marshalWithDisAbsoluteTimestamp()
    DatagramPacket packet = new DatagramPacket(data, data.length, InetAddress.getByName(BROADCAST_ADDRESS), 3000);
    socket.send(packet);
}
catch(Exception e)
{
    System.out.println("Unable to initialize networking. Exiting.");
    System.out.println(e);
    System.exit(-1);
}

~~~~

This creates a datagram socket (in Java, multicast sockets are subclasses of datagram sockets), then creates an entity state PDU with default field values, marshals it to DIS format. The resulting data is placed into a datagram with a destination address of 255.255.255.255 and a destination port of 3000, then sent.  The hosts' routing tables will pick the network interface the message goes out on; it will be the default route, typically the IP associated with en0. Network programming geeks will frown at the use of 255.255.255.255, and the network switch port the host is plugged into may disallow the packet in some instances, but odds are it will work. The advantage is that you don't have to customize or configure this code to work at a specific site's network configuration settings.

####Pick a Broadcast Address

On modern hosts there are often many interfaces: loopback, a wired interface, a wireless interface, several interfaces associated with VMs running on your host, etc. Each network interface can have several IPs associated with it, and each IP has a different broadcast address. So the question of which IP the message goes out on is tricker, as is the broadcast address to use. Here's a listing of the interfaces on my MacOS laptop with one VMWare VM running:

~~~~
mcgredo:> ifconfig
lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> mtu 16384
	options=3<RXCSUM,TXCSUM>
	inet6 ::1 prefixlen 128 
	inet 127.0.0.1 netmask 0xff000000 
	inet6 fe80::1%lo0 prefixlen 64 scopeid 0x1 
	nd6 options=1<PERFORMNUD>
gif0: flags=8010<POINTOPOINT,MULTICAST> mtu 1280
stf0: flags=0<> mtu 1280
en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	ether c8:e0:eb:18:e0:bb 
	inet 172.20.144.41 netmask 0xfffff000 broadcast 172.20.159.255
	media: autoselect
	status: active
en1: flags=963<UP,BROADCAST,SMART,RUNNING,PROMISC,SIMPLEX> mtu 1500
	options=60<TSO4,TSO6>
	ether 32:00:1b:af:22:c0 
	media: autoselect <full-duplex>
	status: inactive
en2: flags=963<UP,BROADCAST,SMART,RUNNING,PROMISC,SIMPLEX> mtu 1500
	options=60<TSO4,TSO6>
	ether 32:00:1b:af:22:c1 
	media: autoselect <full-duplex>
	status: inactive
p2p0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 2304
	ether 0a:e0:eb:18:e0:bb 
	media: autoselect
	status: inactive
awdl0: flags=8943<UP,BROADCAST,RUNNING,PROMISC,SIMPLEX,MULTICAST> mtu 1484
	ether 8a:7e:8b:1f:f9:12 
	inet6 fe80::887e:8bff:fe1f:f912%awdl0 prefixlen 64 scopeid 0x8 
	nd6 options=1<PERFORMNUD>
	media: autoselect
	status: active
bridge0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	options=63<RXCSUM,TXCSUM,TSO4,TSO6>
	ether ca:e0:eb:81:b5:00 
	Configuration:
		id 0:0:0:0:0:0 priority 0 hellotime 0 fwddelay 0
		maxage 0 holdcnt 0 proto stp maxaddr 100 timeout 1200
		root id 0:0:0:0:0:0 priority 0 ifcost 0 port 0
		ipfilter disabled flags 0x2
	member: en1 flags=3<LEARNING,DISCOVER>
	        ifmaxaddr 0 port 5 priority 0 path cost 0
	member: en2 flags=3<LEARNING,DISCOVER>
	        ifmaxaddr 0 port 6 priority 0 path cost 0
	nd6 options=1<PERFORMNUD>
	media: <unknown type>
	status: inactive
utun0: flags=8051<UP,POINTOPOINT,RUNNING,MULTICAST> mtu 1500
	inet6 fe80::6cd0:cfdd:802e:b598%utun0 prefixlen 64 scopeid 0xa 
	nd6 options=1<PERFORMNUD>
vmnet1: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	ether 00:50:56:c0:00:01 
	inet 192.168.214.1 netmask 0xffffff00 broadcast 192.168.214.255
vmnet8: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	ether 00:50:56:c0:00:08 
	inet 192.168.60.1 netmask 0xffffff00 broadcast 192.168.60.255
~~~~

There's the familiar loopback interface, lo0, plus the wireless interface en0, which has an IP of 172.20.144.41 associated with it. There's also an Apple interface for bluetooth at awdl0 which has no IPv4 IP assigned to it, an unused ethernet interface at en1, and some vmware interface at vmnet1 with IP 192.168.214.1, plus some other interfaces, some up and some down. The question is, if we send a broadcast datagram, on which interface will it be sent? 

The most direct way to solve this problem is to send to the broadcast address on the interface you want to use. For example, if I want to send to the wireless network, 172.20.144.41, I should use the broadcast address 172.20.159.255 that ifconfig shows for that IP. If I send to the destination address "255.255.255.255", odds are it will go to the "default" IP address, but there's a possiblity there will be problems. On the other hand now you're faced with the problem of finding the correct broadcast address to use, either via configuration or via discovery at runtime.

Some example code that creates a broadcast UDP socket and sends a message:

~~~~
import java.net.*;
import edu.nps.moves.dis.*;

....
MulticastSocket socket = null;
String BROADCAST_ADDRESS = "172.20.159.255";
EntityStatePdu pdu = new EntityStatePdu();

try
{           
    socket = new MulticastSocket(DIS_DESTINATION_PORT);
    byte data[] = pdu.marshalWithDisAbsoluteTimestamp()
    DatagramPacket packet = new DatagramPacket(data, data.length, InetAddress.getByName(BROADCAST_ADDRESS), 3000);
    socket.send(packet);
}
catch(Exception e)
{
    System.out.println("Unable to initialize networking. Exiting.");
    System.out.println(e);
    System.exit(-1);
}
~~~~

This works; the host routing table will cause the packet to be sent out on the specified interface. It does create a configuration problem, in that you need to specify the broadcast address, and that will vary from network to network. If you can get away with it, using "255.255.255.255" as the broadcast address should send it out on the default interface, which is probably what you want, but the security nazis may stop this from happening.

You can get fancier here, and in Java walk the network interfaces, collecting the broadcast addresses at runtime:

~~~~
Set<InetAddress> bcastAddresses = new HashSet();

// Walk all the interfaces
Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();

while(interfaces.hasMoreElements()
{
  NetworkInterface anInterface = interfaces.nextElement();
  
  if(anInterface.isLoopback())
    continue;
  
  // Each interface may have several IPv4 addresses. Walk each of those, 
  // determining the bcast address for each
  for(InterfaceAddress interfaceAddress : networkInterface.getInterfaceAddresses() )
  {
     InetAddress bcast = interfaceAddress.getBroadcast();
     if( bcast == null)
        continue;
     
     // Found one. Add it to our list of all bcast addresses.
     bcastAddresses.add(bcast);
  }  
}

// We come out of this with a Set that contains all the bcast addresses
~~~~

Once you have the set of valid broadcast addresses you can pick which one to use, or send out a message on all of them.

###Multicast

It's more modern to use multicast, which has near-universal support in operating systems these days. The only exceptions might be in some very constrained embedded operating systems. Multicast is the preferred solution if you don't need backward compatibility with existing broadcast DIS applications.

Example code:

~~~~
import java.net.*;
import edu.nps.moves.dis.*;

....
MulticastSocket socket = null;
String BROADCAST_ADDRESS = "172.20.159.255";
EntityStatePdu pdu = new EntityStatePdu();

try
{           
    socket = new MulticastSocket(DIS_DESTINATION_PORT);
    InetAddress multicastAddress = InetAddress.getByName("239.1.2.3");
    socket.join(multicastAddress);
    
    byte data[] = pdu.marshalWithDisAbsoluteTimestamp()
    DatagramPacket packet = new DatagramPacket(data, data.length, multicastAddress, 3000);
    socket.send(packet);
}
catch(Exception e)
{
    System.out.println("Unable to initialize networking. Exiting.");
    System.out.println(e);
    System.exit(-1);
}

~~~~

This uses the "scoped multicast range", which should keep traffic site-local. We create a multicast socket, then join the multicast group "239.1.2.3". Then send a single datagram to that destination address.

###Further Reading

On using 255.255.255.255: <a href="http://serverfault.com/questions/219764/255-255-255-255-vs-192-168-1-255">http://serverfault.com/questions/219764/255-255-255-255-vs-192-168-1-255</a>

IEEE-1278.2, "IEEE Standard for Distributed Interactive Simulation—Communication Services and Profiles" is a companion standard to DIS, and discusses networking standard practices for DIS. 

There are plenty of examples of writing UDP sockets on the web. One tutorial is here: <a href="http://www.binarytides.com/udp-socket-programming-in-java/">http://www.binarytides.com/udp-socket-programming-in-java/</a>