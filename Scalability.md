##Scalablity

How many participants can we have in a DIS simulation? Two or three entities is useful for teaching applications. As soon as we can get a small NVE to work we immediately start to think about just how large of a virtual world we can handle. 

Scalability can be important for some military applications, though not all. If we're trying to train for indirect fire procedures then being able to handle only a few participants at the same time may be fine. Often virtual simulations such as flight simulators or vehicle trainers don't need large numbers of participants because the usefulness of the virtual aspect is limited to those entities that can be directly viewed by a person. We don't necessarily need the virtual simulation to simultaneously display 10,000 entities in a user's field of view. Even if the entire virtual world is large, a single user might have to interact with a few dozen entities at any given moment.

A US Army combat brigade may have thousands of vehicles, and we can usefully display their positions on a map. Scaling to such a massive size can be accomplished through the use of unit aggregation techniques. Instead of having 14 tanks in a tank company each sending state updates, we have a single, aggregated tank company represented in the simulation that sends updates for the unit as a whole. The lack of entity-level information can create other problems. Suppose a virtual UAV flies over a battlefield. What does the camera display show? Individual tanks or a symbol that represents a tank company?

Entity-based corps or theater level simulations can have tens or hundreds of thousands of entities. What is the practical limit for the size of an entity-based, distributed simulation?

###Massively Multiplayer Games

There are some analogs to large military simulations in the entertainment industry, namely Massively Multiplayer Online Games (MMOGs) such as World of Warcraft, EVE Online, or No Man's Sky. MMOGs and games in general use many of the same technolgies as distributed military simulations. In fact, the line between games and training simulations is blurred in the category called "serious games." The main aspect that distinguishes games from simualation is the intent of the application; the technolgies used, including distributed virtual environments, use almost exactly the same underlying technologies. 

MMOGs are an interesting topic but out of scope for this discussion. DoD is effectively restricted to using established military standards, and strives to _not_ use clever but non-standard commercial approaches. The commercial world is notorious for game engines and software frameworks that lose their support after a few years as developers move on to the newer, shinier bauble. Interoperability and stability of the code base over a period of decades is usually more important to DoD than sheer scalability. The good news is that the entertainment industry has shown NVEs can scale to large size; the bad news is that the longevity and amenability to standards agreements is questionable. We simply can't have simulations that are one-offs in  which the technology becomes obsolete in five years.

Still, MMOG's are clearly the technology leader in the market segment, and game companies spend more than a large military simulation program does to develop a class A title. Rolling out a new and large MMOG game like World of Warcraft may cost hundreds of millions of dollars in game artwork, programming, and servers, and they are quite good at it. 

See the "Further Reading" section for some details on the technologies the entertainment companies are using. 

####Networking

One of the central problems to solve in a large NVE is keeping state updates down to a reasonable level. If too many state updates are sent we can flood the network or overwhelm the ability of a host to receive, parse, and process state updates.

####Unicast

Unicast socket state updates--in which a message containing a state update is sent to a single host--is the least scalable way to distribute state across hosts. 

Start with a NVE that has three participating hosts, each controlling a single entity. A state update for the entity each host owns needs to be sent twice. Each of the other hosts needs to do the same thing, so total traffic on the network is M(3-1) * 3, where M is the message size. As we increase the number of hosts the traffic goes up accordingly, generalized for the network as a whole as M(N-1) * N. You'll notice that if you simplify this there's an N^2 term, meaning the bandwidth use goes up with the square of the number of participants. That's a bad outcome. As N starts getting bigger the product of our equation starts getting bigger very fast. 

####Broadcast

Broadcast is way to avoid the N^2 term that crops up in unicast. UDP broadcast allows a host to send a single message that will be received by every host on the network. Instead of sending N-1 state updates, we only have to send one. 

Broadcast has some limitations. Broadcast messages don't travel off the network the host is on; routers should drop a broadcast packet and not forward it off-network. This means broadcast is useful primarily in a lab environment in which the hosts are co-located, and not so much in a geographically distributed simulation. 

As with most things network-related there are ways to get around these broadcast limitations, but just don't. It's not worth it.

Broadcast is the most widely used method to send DIS PDUs. It's traditional to use broadcast UDP port 3000 for DIS.

####Multicast

Multicast is a more sophisticated extension of broadcast. Like broadcast, it can send a single message to every host on a network. Multicast can also send a message to only those hosts that have subscribed to a "multicast group." 

Multicast is a superior option to broadcast. The research into and implementation of multicast was done in the mid-90's, a little after DIS was standardized, and as a result DIS has for historical and installed base reasons usually settled for broadcast, despite its inferiority. If you have a choice you should always pick multicat over broadcast. The only reason to continue using broadcast is historical inertia and interoperability with applications that are pre-configured to use broadcast.

Why is it better? Several reasons.

One thing multicast gives us is the ability to traverse routers. Broadcast is limited to a single network, while multicast can traverse network boundaries if the routers connecting networks are configured to allow this. Multicast configuration of the routers is not a given. 

This document is trying to avoid becoming a networking tutorial.  You can read more about multicast at <a href="http://www.cisco.com/c/dam/en/us/products/collateral/ios-nx-os-software/ip-multicast/prod_presentation0900aecd80310883.pdf">http://www.cisco.com/c/dam/en/us/products/collateral/ios-nx-os-software/ip-multicast/prod_presentation0900aecd80310883.pdf</a> But understanding some of the multicast implementation details helps you understand its usefulness in NVE scalability.

You don't have to configure anything to use multicast within a single network. There is no extra configuration above and beyond that of broadcast. If the design requires that state updates traverse networks then the network can be configured to do multicast routing. This realistically cannot be done with broadcast. Multicast does everything broadcast does, and has the capacity to be more capable. TCP/IP stacks nearly universally support multicast, even severely limited devices such as cell phones (Android and IOS), Raspberry Pi, and many Arduino devices. 

In classical networking terms, at the ethernet level multicast is essentially identical to broadcast. In more modern, switched networking environments it can be considerably better.

"Layer 3 switches," sometimes called "smart switches," are in most network infrastructure buildouts these days. The interface the user often sees is the network port in the wall the ethernet cable plugs into, which travels back to a L3 switch in a networking closet, but more is going on behind the scenes. These switches have become more capable over the years and they now do many of the tasks formerly reserved for routers. One of the configuration options for L3 switches is called "IGMP Snooping." When a host subscribes to a multicast group the TCP/IP stack sends a notification to the first hop router (present or not) that the host has subscribed to a particular group, for example "235.1.2.3". The router uses this information in the Internet Group Managment Protocol (IGMP) to help build mulitcast routing tables. Switches can use this information to help segregate multicast traffic.

When the IGMP message hits the switch on the way to the router the switch can listen in ("snoop") on the traffic. When it sees a subscription to 235.1.2.3 pass by it turns on multicast traffic for that group to the switch port the request came from, while leaving all other switch ports deaf to the traffic associated with that group. If we have ten switch ports, and only hosts on ports 1 and 2 are subscribed to multicast group 235.1.2.3, then the UDP state update traffic will only be forwarded out ports 1 and 2. Hosts on other ports will not see any traffic from that multicast group at all.

This is beneficial to NVE performance, as we'll see later in the section on Distributed Data Management (DDM). In a NVE with heavy state update traffic we will lose the performance battle if all UDP state update packets arrive at the network interface, travel up the TCP/IP stack, are delivered to the application and parsed,  only to be thrown away. It is much more efficient to limit traffic as early in the process as possible. Not even delivering updates to the network interface card of the host if we know the host is not interested is an optimal solution to this problem.

Another way that multicast can improve performance is the algorithms the network interface card (NIC) uses to receive Ethernet traffic. Ethernet frames contain the information in a UDP packet, nested Russian doll-style. The network interface card has knowledge of what multicast groups the host has subscribed to, similar to the way IGMP snooping works. Good NICs can imperfectly filter out UDP multicast messages in hardware and completely avoid passing irrelevant traffic up the TCP/IP stack. Actual implementation of this technique can be spotty. A good implementation depends on a sharp author for the ethernet card driver. But avoiding tasking the higher layers of the TCP/IP stack can be a significant win in environments with a lot of traffic from several multicast groups.

All this means, again, that multicast performs at least as well as broadcast, has the ability to exploit multicast routing to be more capable, can exploit L3 switches to be more efficient, and has no downside. The only reason to choose broadcast over multicast is compatiblity with the installed base.

### Distributed Data Management

Distributed Data Management (DDM) is a term that I'm retro-applying to DIS. It originated in HLA, as near as I can tell. An alternative term is Area of Interest Management (AOIM), the name given to the concept in Mike Macedonia's 1995 PhD thesis. See "Further Reading" for details.

The problem DDM is trying to solve is filtering out state updates that are irrelevant to a participant. Consider a theater-level combat simulation of the Persian Gulf. A Burke class destroyer is conducting anti-air operations, while 50 miles inland a dismounted infantryman with an AK-47 is moving. Meanwhile a red force aircraft is a further 50 miles inland. All the entities involved are sending state updates.

The Burke class destroyer is almost certainly not interested in state updates from the dismounted infantryman. He's too far away to affect us, or for the Burke to have an effect on him. Nonetheless in an architecture that uses a single UDP port and broadcast the Burke will receive state updates from the dismount. If we have thousands of dismounts and hundreds of vehicles the host that owns the Burke will receive the state updates from all these entities, parse them, and then throw them away once it realizes that the information is useless. This is obviously bad for performance.

In contrast the Burke will be very interested indeed in the red force aircraft despite the fact that it is even further inland. 

Two entities of the same type may not be interested in each other. Our AK-47 armed insurgents may be 5K away from each other and unable to influence each other. For best performance they shouldn't be receive state updates from each other, either.

There's another case that's somewhat more subtle: if the state update is so old, due to latency or some other reason, it may no longer be of use to us. If we received it an parsed it we would throw it away once we realized how old it was.

In Macedonia's telling, NVEs can do DDM based on spatial, temporal, and functional criteria. The Burke simulator in the example above can use functional DDM to filter out all the dismounted infantry and tanks while still receiving state updates from aircraft. Or we could use spatial DDM to ensure that infantry more than 5K apart don't receive state updates from each other, or ignore state updates if they are more than 500 ms old. 

The central concept of DDM is to segregate and limit the dynamic state updates to only those hosts to which it would be of value. A key requirement is that the traffic be filtered _before_ it arrives at the simulation application. It's impractical to receive, parse, and process all the traffic in a large NVE if we then discard all but the small quantity of state updates we are interested in.

DIS, is as a standard, silent on the subject of DDM. 

Multicast is a popular technology for implementing this requirements. 





 
 




###Further Reading
EVE Online Scaling: http://www.talkunafraid.co.uk/2010/01/eve-scalability-explained/

More EVE Online scaling, from EVE engineers: http://www.ics.uci.edu/~avaladar/papers/brandt.pdf

Cambridge PhD on scalability: https://www.microsoft.com/en-us/research/publication/distributed-virtual-environment-scalability-and-security/

Multicast: http://www.cisco.com/c/dam/en/us/products/collateral/ios-nx-os-software/ip-multicast/prod_presentation0900aecd80310883.pdf

NICs and multicast: https://sourceforge.net/p/e1000/mailman/message/23791895/

Mike Macedonia AOIM thesis: http://gamepipe.usc.edu/~zyda/resources/Theses/Michael.Macedonia.pdf
