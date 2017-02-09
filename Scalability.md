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

One of the central problems to solve in a large NVE is keeping state updates down to a reasonable level. If too many state updates are sent we'll either flood the network or overwhelm the ability of a host to receive, parse, and process state updates.

####Unicast

Unicast socket state updates--in which a message containing a state update is sent to a single host--is the least scalable way to distribute state across hosts. 

Start with a NVE that has three participating hosts, each controlling a single entity. A state update for the entity each host owns needs to be sent twice. Each of the other hosts needs to do the same thing, so total traffic on the network is M(3-1) * 3, where M is the message size. As we increase the number of hosts the traffic goes up accordingly, generalized for the network as a whole as M(N-1) * N. You'll notice that if you simplify this there's an N^2 term, meaning the bandwidth use goes up with the square of the number of participants. That's a bad outcome. As N starts getting bigger the product of our equation starts getting bigger very fast. 

####Broadcast

Broadcast is way to avoid the N^2 term that crops up in unicast. UDP broadcast allows a host to send a single message that will be received by every host on the network. Instead of sending N-1 state updates, we only have to send one. 

Broadcast has some limitations. Broadcast messages don't travel off the network the host is on; routers should drop a broadcast packet and not forward it off-network. This means broadcast is useful primarily in a lab environment that has the hosts co-located, and not so much in a geographically distributed simulation. 

As with most things network-related there are ways to get around these broadcast limitations, but just don't. It's not worth it.

Broadcast is the most widely used method to send DIS PDUs.

####Multicast

Multicast is a more sophisticated extension of broadcast. Broadcast sends a single message to every host on the network. Multicast can send a message to only those hosts that have subscribed to a "multicast group."

There's something else multicast gives us: the ability to traverse routers. Broadcast is limited to a single network. Multicast can traverse networks if the routers connecting networks are configured to allow this. Multicast configuration is not a given. 


Multicast is a superior option to broadcast. The research on and implementation of multicast was done in the mid-90's, a little after DIS was standardized, and as a result DIS for historical reasons settled on broadcast. Traditionally DIS uses UDP port 3000. But multicast is better, and if you have a choice you should always pick that. The only reason to continue using broadcast is historical inertia and interoperability with applications that are pre-configured to use broadcast.

 
 




###Further Reading
EVE Online Scaling: http://www.talkunafraid.co.uk/2010/01/eve-scalability-explained/

More EVE Online scaling, from EVE engineers: http://www.ics.uci.edu/~avaladar/papers/brandt.pdf

Cambridge PhD on scalability: https://www.microsoft.com/en-us/research/publication/distributed-virtual-environment-scalability-and-security/
