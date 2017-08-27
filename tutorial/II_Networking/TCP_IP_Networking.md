# II. Networking

## DIS Networking

If the real time exchange of state data between distributed simulation hosts is going to be accomplished then some way of sending data between hosts over a network must be used. A form of networking called TCP/IP is the most popular way to do this. 

Many programmers are familiar with TCP/IP, but not in the context of a distributed simulation system such as DIS. Likewise, not all system administrators are aware of what practical TCP/IP DIS networking issues exist. This topic can help DIS users understand some networking issues.

## TCP/IP

Transmission Control Protocol / Internet Protocol (TCP/IP) is a software standard that has been developed for decades and is today installed on nearly every computer.

TCP/IP can be a complex topic, but this tutorial will attempt to be as simple as possible. If you wish to learn more about the subject, two good books are *The TCP/IP Guide: A Comprehensive, Illustrated Internet Protocols Reference*, by Charles M. Kozierok, and *TCP/IP Illustrated, Volume 1: The Protocols (2nd Edition)*, by W. Richard Stevens. Again, that's if want to learn more. Today there are many web sites that explain network communications over TCP/IP as well. This includes implementation libraries that make the programmer's life easier.

## Overview

The illustration below shows the essentials of a four-layer interpretaton of the TCP/IP protocol.

![IMAGE TCP/IP](II_Networking/images/networking.jpg)

The top layer, the Application Layer, is code simulation programmers write. It  includes both code for sending and receiving DIS messages and the simulation program itself. 

The Transport Layer and how we talk to it are the most important aspect. If lucky, we can largely ignore everything below the Transport Layer. The Application Layer is where we implement the DIS protocol and the simulatinon itself.

The Internet layer is responsible for changing large collections of data into smaller packets that can be routed and transmitted across the network. Very often it can be ignored by the DIS programmer.

The bottom layer, Network Access Layer, is related to the type of network transport used. The bottom layer may use 802.11  wireless networking, or may use gigabit Ethernet, or it may use 10 gigabit Ethernet. The interesting thing is the application can use any of these network types without changing code. An application uses the Transport Layer API, and the layers below that can use slow wireless or fast Ethernet. Our simulation application can use either.


## Transport Layer APIs

There are more than one set of features that can be used to exchange messages between hosts. These include TCP and UDP sockets, and within the UDP sockets the additional technologies of broadcast or multicast can be used as well. The API layouts are shown in the graphic below.


### TCP

TCP is technology  to communicate data between hosts, and it has both some advantages and disadvantages.

A TCP protocol networking socket is a stream-oriented connection between two hosts, and  two hosts only. A single TCP socket cannot send a message to a dozen different hosts. Instead there must be a separate TCP socket from our host to each of the dozen other hosts. 

When API to create a socket we can send a contnuous stream of data. The connection is full-duplex; messages can travel both directions between the hosts at the same time. 

TCP sockets are responsible for transmitting reliable streams of data. This can be appealing and limiting.

Imagine sending a stream of hundreds of DIS Protocol Data Units (PDUs) to another host. But what happens if the network has a problem, and drops a PDU? Networks have a difficult problem delivering data reliabley. Imagine sending a copy of the Jane Austen novel *Pride and Prejudice*. Even using ASCII text, this totals over half a megabyte of data. From a practical API standpoint the programmer can send the entire text of the novel with a single command to the Transport Layer API from the Application Layer. But below the Transport Layer TCP/IP has to break up the half-megabyte of data into smaller packets. Very often the packet size used is around 1500 bytes. Each of these packets is routed through the network, and across dozens of steps. When they arrive at the destination the receiver assembles the smaller packets back into the large message sent. 

What happens if a single smaller packet is dropped? If we are using TCP, we don't want to lose a single sentence from a Jane Austen novel. We want a guaranteed delivery of the entire novel, undamaged. This is what TCP sockets provide. TCP will detect the loss of a packet that makes up the entire message. It will cause the sender to resend the packet, and eventually the receiver will have all the packets necessary to receive the novel. If we are sending a series of DIS PDU messages, then each PDU will be delivered.

TCP sockets have other features as well. TCP sockets can automatically lower or increase the speed at which they send depending on how capable the receiver is, for example. If we are sending to a slow mobile device from a fast workstation host TCP will find a usable send rate that does not overly challenge the mobile device. TCP sockets also always ensures that Austen novels are delivered in the same byte order in which they were send, and ensure that there are no dupliated bytes in the message. The end result is that the receiver gets exactly what was sent by the sender.

This seems attractive in many ways, but there are some limitations. First of all, notice the "one recipient per TCP socket" restriction. If we have 10 participants in a NVE, and we want all nine other participats to receive a PDU, we have to send the messsage nine times across nine TCP sockets. If we have 100 simulation participants we'd need to send the same PDU 99 times.

We also have to worry about *latency*, the averate time necessary to deliver a PDU from one host to another. What happens if the network somehow has a problem delivering a PDU when the network drops a packet? The TCP socket has to discover the loss of the packet after waiting long enough, and then resend it to make up for its loss. Remember TCP sockets also promise in-order delivery and reliable delivery. This means PDUs sent after the one that was lost cannot be delivered, either. The delivery of PDUs will simply stop until the lost PDU problem is fixed.

Do we always need a delivery of all PDUs? Not necessarily. Imagine a PDU that describes the locaton of a vehicle. A  PDU that determines the location of the vehicle is sent every 1/30th of a second, about the frame rate of a 3D display. What if one of these position updates is dropped? We'd have to wait long enough to discover its loss, then ask the sender to resend it. It would also stop the delivery of the rest of the position updates. That could make the movement of the vehicle worse. 

TCP sockets are used in NVEs for several reasons. They can be used to send DIS PDUs, though designers should note the liminations inherent in the TCP sockets. TCP can be used for other reasons as well. A TCP socket can be used to download or transmit large files, such as terrain data or graphical data when the simulation starts. For these reasons and others knowing something about TCP can be useful.

Rememeber, sometimes libraries that hide Transport Layer API are used, and they make the programmer's life easier. But the fundamental limitations of using a TCP socket are not changed, and the simulation application designer has to realize this.


### User Datagram Protocol (UDP)

UDP is another API available to applications at the Ttransport Layer, just as TCP sockets are, but they deliver features that address the problems of TCP sockets addressed above. Just as the API can create TCP sockets, we also have an API that can create UDP sockets.

UDP sockets back off on TCP socket features. TCP sockets offer continuous streams of data. The sender and receiver remain stream connected. UDP instead sends distinct, stand-alone messages. A UDP socket will accept a message of any content and then send that message to a destination. The UDP socket does not ensure that the message is actually delivered. If the network causes its loss somewhere, there is no attempt to resend it. For an application sending a continuous stream of messages, such as the vehicle position PDUs discussed above for TCP sockets, this is good. A dropped packet will no  longer halt the delivery of later PDUs. 

UDP sockets also do not insist on delivering messages in the order they were sent. It's possible that a PDU sent early will be delivered later. For our vehicle position reports this might seem to be a problem, but in fact it turns out to be an easy one to avoid. We can in the message contents simply include a sequence number, and drop any PDUs that are too old or out of ordor. This out of order detection is done by the Application Layer application (i.e, us) rather than the TCP socket, but it's pretty easy to do.

UDP sockets back off on TCP sockets in streaming, reliable delivery, and in-order delivery. They instead deliver messages in indepenent messages, that can (but usually are not) be delivered out of order, or dropped entirely. Networks are usually reliable enough for UDP to work well. 


#### Broadcast UDP

UDP is useful, but as with TCP sockets the initial solution is to send one message to one host. If we have 100 participants in a simulation and we want to send a message to each, we have to send 99 messages, one to each address. This takes bandwidth, bandwith use that can increase with the square of the number of participants. What we'd like to do is instead send a single message that is received by all the simulation particpants. Using broadcast addressing is one way to do this. Broadcast addresses are a special IP from early in the development of the TCP/IP protocol. Though old, it's still used in many places. It's less capable than the multicast protocol discussed later, but it is used by some.

Using broadcast uses conventional UDP sockets, but with a special approach to picking the message destination. Every host has an Internet Protocol number assigned to it. The below shows the values for a host:

![IMAGE TCP/IP](II_Networking/images/IPDisplay.jpg)

As you can see, the host has an IP number of 10.0.0.158. There are no other hosts on the network with that IP. When we create a message to send to that host, we set a destination address of 10.0.0.158 in the message. If we want to send to another host, we'd have to send a new message with a different IP, such as 10.0.0.42. (Yes, you can also use a name if you are willing to convert a name to an IP, wich is usually easy to do.) If you wanted to send to 99 hosts you'd have to do this 99 times. But what if you wanted to send only one message, and have that received by everyone on that network that was interested? We can use something called broadcast addressing to do that.

An IP such as 10.0.0.158 actually has two parts: a network portion, and a unique host ID within that network. You'll notice an item called the "subnet mask" that has a value of 255.255.255.0. An IP address is four bytes long, and each of the four period-sepearated numbers in the address is a separate 8-bit long byte. What is happening is that the subnet mask is defining the separating line between the "network portion of the IP" and "host withing a network" portion of the IP. In this case, because the subnet mask is using 255, it means the first three bytes are part of the network, while the last byte is used to list individual hosts. The host IP we see is 158 within our local network--there should be no other host with that IP on our network. 

What the early designers of TCP/IP did was pick a special IP to describe "This message is for any host on the network, not just one specific host." In the case of DIS, sending to a broadcast address would allow us to send one PDU message instead of the 99 repeated messages. That's a valuable reduction in broadcast use.
lt
So what's the special IP address? It's the host region of the address with all bits switched on. In our case, the first three bytes (10.0.0) is the network portion. OUr host portion is set to the value 158. The broadcast address is 10.0.0.255. That's what all bit values turned on in the host portion look like for an integer byte. 

So long as all the simulation participants are present on same network, using broadcast can dramatically reduce the bandwidth used.

#### UDP Multicast

Broadcast was used from early on, but in the mid-90's a technology called multicast started to be used. Multicast is more powerful and flexible than using broadcast addressing.

Multicast uses UDP sockets that have been specially configured, and that use a special set of IP numbers. Any IP number in the range 224.0.0.0 to 239.255.255.255 is a "multicast address," or group number. 

Lets pick the multicast number 239.1.2.3, which is within the range mentioned above. We can (with a properly configured UDP socket) have a group of hosts subscribe to this address, while the rest of the hosts do not. With broadcast, *every* host on the network would be subscribed to messages sent to that address. In a network with 100 hosts, we might make only 20 subscribe to the address 239.1.2.3 for messages.

In our simulation application we may want to send out updates for the position of ships to other ships, and tanks to other tanks. We can set up ship applications to be subscribed to the multicast ship addres, 239.1.2.3. Any message sent to that address will be handled by hosts that have chosen to be subscribed. Likewide the tank appliations at the multicast address 239.1.2.4 will receive messages sent for tanks. The administrative application which wants to receive both tank and ship messages can subscribe to both 239.1.2.3 and 239.1.2.4.

Multicast is even more powerful because it is not limited to the local network. Broadcast required all the hosts to be on a single, local network. Multicat can, if configured correctly, include more than one network. For simulations, multicast networking can be used in a network that ranges across continents. 

Multicast is the preferred solution over broadcast. Both broadcast and multicast are usually the preferred solutions over using single host addresses.

#### Web-Based technology

This term seems a little strange, and it is. In the last few years state updates have started to be sent across web technologies. The state updates are sent across web servers. How does this happen?

In practice, the web servers are using TCP and UDP sockets, and the DoD applications are accessing the sockets via a higher level API. In effect this is an example of using a higher level API to access the same lower level TCP and UDP APIs. You can think of it as a supporting library, but with the added benefit of also being an officially approved international standard.

#### Supporting Libraries

There are in practice of lot of other APIs for accessing TCP and UDP sockets--socket creation, message transmission, message receipt, and more. There are dozens of C++ libraries. The same is true for many other languages, such as Java and Javascrpt. In practice they may hide the direct APIs presented by the operating system or TCP/IP. The libraries may occur at multiple levels of complexity, and hide the sockets discussed above at multiple levels. They may occur at someone low levels. Others may be at much higher levels, such as game engines. 

Still, the issue is often recognizing the inherent issues among TCP. UDP, Broadcast, and Multicast sockets, not the specific programming API. Understanding the advantages and limitations of each type of underlying socket is important.

#### Language-Specific implementations

Some example code that demonstates actual use of sockets is provided here. This is inherently programming language-specific--C++ code is not the same as Java code, which is not the same as Javascript code. The problem is that each language will have it's own project code, and its own source code control site or download site. The DIS Tutorial you are reading is also maintained as a git repository, and it's impractical to keep all the discussed data as well as all the example code in one repository--the download size alone would be impractical. In addition it wold be difficult to let multiple users add content to multiple sections. 

Instead the tutorial maintains links to supporting source project repositories. For example, there may be dozens of example repositories for Java source code examples in projects that show use of sockets, DIS updates, or dead reckoning. There can be matching implementations in C++ or C# in different repositories.

That's how the code that shows examples of how networking is used are presented here. Sections that have links to example implementations for specific languages are below.

##### Java Code Examples
 [Java Networking Source Code Examples](II_Networking/Java_Networking_Source_Code.md)


##### C++ Code Examples

##### Javascript Code Examples

## Summary

This section has described some of the capabilities and problems inherent in TCP and UDP sockets, and the nature of Broadcast and Multicast approaches. Broadcast and Multicast are very useful in the DIS world. But at the same time no code of actual implementations was presented. The basic problem is that the code is language-specific. C++ code does not appear the same way that Java or Python or Javascript does. While this section can describe the general behavior, it does not provide specific code. 

But that sort of provision is useful, and seeing actual networking programs can save a lot of time. It can also take up unreasonable amounts of disk space for users that are not immediately interested in source code, even if they eventually are. This gets even worse when you think of example projects for several languages that are inherent to an overall tutorial that is not limited to a single language.

Instead, the section provides a section of links to additional source code control sites. For example, a Java project using Multicast, or a Javascript project that uses web technology, or a C++ example. The repositories linked to are not directly part of this project, but can be downloaded. Read on to find links to networking implementations. 
