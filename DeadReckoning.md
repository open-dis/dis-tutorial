##Dead Reckoning

Dead reckoning is a technique that makes informed guesses about the location of entities in order to reduce network traffic and mitigate the effects of latency.

Imagine an entity moving in a straight line at a constant velocity. The entity is owned by one particular simulation in a networked virtual environent. Its state--namely, its position--is changing, and we need to inform other participating simulations in the NVE about the change in dynamic state information. 

The entity is experiencing constant changes to its shared, dynamic state. How can we make the other participating simulations closely match the entity's state as it changes? 

###Brute Force & Ignorance
A simulation participating in a NVE strives to match its visual display to the underlying reality of the simulation's other participants. If the simulation that owns the entity discussed above sends out updates once a second that means the entity will appear to do "hyperspace jumps" from the old position to the new position every second, because the state updates are arriving at that frequency. This may or may not be significant, depending on the circumstances. Large hyperspace jumps are distracting if the application is a virtual environment, the sine qua non of which is to create a sense of realistic, shared presence. If the entity is moving slowly and the hyperspace jumps are small the user might not even notice them. If the application is a map-based display of entity locations the user might not be distracted by position jumps of even hundreds of meters if the map's scale is large enough.  In any event users of map applications have more forgiving expectations about display update changes; the hyperspace jumps on a map don't take them out of the sense of presence the way they would if they occurred in a virtual environment. 

In the end, the significance of the simulation's display update rate depends on the training objectives of the simulation.

Still, in many applications, particularly virtual environments, we want to limit the update frequency artifacts apparent to the user. For our entity moving in a straight line at a constant velocity one possiblity is for the simulation that owns the entity to simply send out more frequent updates. Instead of sending out a update for the entity's position once a second, we can send out updates once every 30th of a second, and the entity will be animated more smoothly. There are some obvious drawbacks to this approach. First of all, bandwidth. We have just increased the bandwidth used for updates for each entity by a factor of 30. This might not be terrible in some instances. In DIS an entity state PDU has a minimum payload of 144 bytes plus 28 bytes of network overhead, so our bandwidth use increased from 172 bytes/second to over 5K bytes/sec. This isn't so bad in a typical wired network that has 100 mbit/sec ethernet, but if a NVE has a thousand entities it starts becoming a factor.

There are more serious and subtle problems with the brute force approach than just bandwidth use. Network performance is a multi-dimensional optimization problem and NVE state updates are often in a corner case that causes significant issues. NVE state updates conveyed via UDP are often small and frequent, and that's a worst case situation for UDP network performance. Receiving many small UDP updates limits the number of packets that can be received per second, even though the bandwidth throughput is far below the theoretical maximum. 

Receiving a UDP packet is a computationally time-consuming affair at a high enough rate. The network interface card will raise interrupts that need to be handled by the CPU and operating system, and as of this writing a realistic maximum is about 50,000 UDP packets per CPU core. Our 30,000 updates per second outlined above is starting to bump up against that and as a result we'll probably see some dropped UDP packets. We can get better throughput if we bundle several PDUs into one UDP packet to send fewer, larger UDP messages (see the section on PDU bundling) but this also means the average latency of the updates is increased.  The bundling approach requires that we wait for several update messages to fill an outgoing queue or wait for a timer to exprire before we have enough to bundle and send.

The brute force approach also means we have to decode more packets and do the processing associated with applying the updates to the system, and this increases CPU load. In production virtual environments we have CPU budget allocations for different aspects of the system--so much for AI, so much for graphics and physics, and a much smaller amount for network operations.  Networking will get the short end of the stick in budget allocation debates.

For all these reasons a pure brute force approach is not realistic for anything other than small virtual environments.

###Dead Reckoning to Reduce Traffic

An alternative approach for our hypothetical entity moving in a straight line is to use dead reckoning to make guesses about the location of entities. If we send state updates once a second we can, on the receiving side, interprolate the position of the entity based on its velocity. The DIS entity state PDU includes fields for entity velocity, so the last ESPDU has enough information to allow us to calculate this. 

We receive an update at t=0 for an entity moving north at 10 m/s (a little over 20 mph). At a frequency we choose--perhaps 30 per second--we can run our dead reckoning algorithm to guess where the location of the entity is. In our case, we will move the entity 0.3 m north, about a foot, at every tick of the algorithm. The math in the DR algorithm is fairly efficient, at least more so than receiving and processing UDP packets.

This is all fine and good. But this all assumes that the location and velocity alone provides a pretty good guess for where the entity is located between receiving state updates. What if that's not such a good guess? What we want is several different algorithms that can provide different guesses depending on the nature of the entity's behavior. 

DIS entity state PDUs address this allowing the owner of the entity--the applicaiton sending updates--to specify what algorithm the receiver should use. The DeadReckoningParameters record of the Entity State PDU contains an "deadReckoningAlgorithm" enumeration field. The values in the table below map to the alogrithm to be used.

<img src="images/DeadReckoningAlgorithms.jpg">DeadReckoningAlgorithms.jpg</img>

The algorithms are mostly straight forward descriptions of Newtonian mechanics. 

If the value "1" is seen in the field, the entity should not be dead reckoned at all. Dead reckoning is not computationally free, and if the entity is not moving at all it makes sense to tell the receiver to not perform the computations at all. 

DR algorithm 2 uses only velocity to guess the location of the entity. DR algorithm 3 expands the kinematic information used in DR to angular velocity, which allows the receiver to guess the entity's orientation as well. DR algorithm 4 expands this further to linear accleration. DR algorithm 5 uses linear velocity and acceleration, with no angular components. 

DR algorithms 6 through nine are similar to the above, but use the local, body-centered coordinate system rather than the global coordinate system.

###Dead Reckoning Thresholds

One of the interesting insights of DIS is that the owner of the entity can change the DR algorithm used, and is not limited to sending out updates only at fixed intervals. If the owner of the entity realizes that the receivers will be out of sync with the owner it can immediately send an entity state PDU with the current entity state information. Let's say our tank makes a left turn. The owner knows that all the receivers at DR'ing the entity and expect it to continue in a straight line. Rather than waiting for the next heartbeat message to send out a state update, the owning application can send a new ESPDU immediately when the turn is made. 


###Dead Reckoning to Mitigate Latency Effects

###What If the Dead Reckoning is Wrong?

 


Further Reading:

Bandwidth benchmarking: http://wiki.networksecuritytoolkit.org/index.php/LAN_Ethernet_Maximum_Rates,_Generation,_Capturing_%26_Monitoring

UDP internals: https://www.codeproject.com/articles/275715/real-time-communications-over-udp-protocol-udp-rt

UDP Linux internals: https://blog.packagecloud.io/eng/2016/06/22/monitoring-tuning-linux-networking-stack-receiving-data/#data-arrives

Performance tuning: https://blog.cloudflare.com/how-to-receive-a-million-packets/

Dead Reckoning performance: <a href="documents/DeadReckoning_Ryan.pdf">documents/DeadReckoning_Ryan.pdf</a>