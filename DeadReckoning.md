##Dead Reckoning

Dead reckoning is a technique that makes informed guesses about the location of entities in order to reduce network traffic and mitigate the effects of latency.

Imagine an entity moving in a straight line at a constant velocity. The entity is owned by one particular simulation in a networked virtual environent. Its state--namely, its position--is changing, and we need to inform other participating simulations in the NVE about the change in dynamic state information. 

The entity is experiencing constant changes to its shared, dynamic state. How can we make the other participating simulations closely match the entity's state as it changes? 

###Brute Force & Ignorance
A simulation participating in a NVE strives to match its visual display to the underlying reality of the simulation's other participants. If the simulation that owns the entity discussed above sends out updates once a second that means the entity will appear to do "hyperspace jumps" from the old position to the new position every second because that is the frequency at which state updates are arriving. This may or may not be significant, depending on the circumstances. Large hyperspace jumps are distracting if the application is a virtual environment, the sine qua non of which is to create a sense of realistic, shared presence. If the entity is moving slowly and the hyperspace jumps are small the user might not even notice them. If the application is a map-based and the scale of the map is large enough the user might not be distracted by position jumps of even hundreds of meters.  In addition users of map applications have more forgiving expectations about display update changes; the hyperspace jumps on a map don't take them out of the sense of presence the way they would if they occurred in a virtual environment. We can also exploit the lower expectations they have for map displays. In the end, the significance of the simulation's display update rate depends on the training objectives of the simulation.

Still, in many applications, particularly virtual environments, we want to limit the update frequency artifacts apparent to the user. For our entity moving in a straight line at a constant velocity one possiblity is for the simulation that owns the entity to just send out more frequent updates. Instead of sending out a update for the entity's position once a second, we can send out updates once every 30th of a second, and the entity will be animated more smoothly. There are some obvious drawbacks to this approach. First of all, bandwidth. We have just increased the bandwidth used for updates for each entity by a factor of 30. This might not be terrible in some instances. In DIS an entity state PDU has a minimum payload of 144 bytes plus 28 bytes of network overhead, so our bandwidth use increased from 172 bytes/second to over 5K bytes/sec. This isn't so bad in a typical wired network that has 100 mbit/sec ethernet, but if a NVE has a thousand entities it starts to become a factor.

There are more serious and subtle problems with the brute force approach than just bandwidth use. Network performance is a multi-dimensional optimization problem. NVE state updates are often in a corner case for network performance that causes significant issues. NVE state updates conveyed via UDP are often small and frequent, and that's a worst case situation when updates are sent over UDP sockets. Receiving many small UDP messages often runs into practical limits well before the theoretical maximum bandwidth is reached.

Receiving a UDP packets at a high rate is a computationally time-consuming affair. Deep in the operating system the network interface card will raise interrupts that need to be handled by the CPU and operating system, and as of this writing a realistic maximum is about 50,000 UDP packets per CPU core. Our 30,000 updates per second outlined above is starting to bump up against that and as a result we'll probably see some dropped UDP packets. We can get better throughput if we bundle several PDUs into one UDP packet to send fewer, larger UDP messages (see the section on PDU bundling) but this also means the average latency of the updates is increased.  The bundling approach requires that we wait for several update messages to fill an outgoing queue before we have enough to bundle and send.

The brute force approach also means we have to decode more packets and do the processing associated with applying the updates to the system, and this increases CPU load. When going from one update message per second to 30 per second we now have to decode an extra 29 messages per second, which usually involves memory copies and other operations. In production virtual environments the designers often have CPU budget allocations for different aspects of the system--so much for AI, so much for graphics and physics, and a much smaller amount for network operations.  Networking will almost always get the short end of the stick in budget allocation debates because designers would rather spend the cycles on spiffy in-game physics rather than parsing network messages.

For all these reasons a pure brute force approach is not realistic for anything other than small virtual environments. It can have its place, but in larger NVEs it's not a practical approach. 

###Dead Reckoning to Reduce Traffic

An alternative approach for our hypothetical entity moving in a straight line is to use dead reckoning to make guesses about the location of entities. If we send state updates once a second we can, on the receiving side, interprolate the position of the entity based on its velocity. The DIS entity state PDU includes a field for entity velocity, so the most recent ESPDU received has enough information to allow us to calculate this. 

We receive an update at t=0 for an entity moving north at 10 m/s (a little over 20 mph). At a frequency we choose--perhaps 30 per second--we can run our dead reckoning algorithm to guess where the location of the entity is. In our case, we will move the entity 0.3 m north, about a foot, at every tick of the algorithm. The math in the DR algorithm is fairly efficient, at least more so than receiving and processing UDP packets.

This is all fine and good. But this all assumes that the location and velocity alone provides a pretty good guess for where the entity is located between receiving state updates. What if that's not such a good guess? What we want is several different algorithms that can provide different approaches for making guess depending on the nature of the entity's behavior.  DIS entity state PDUs allows the owner of the entity--the applicaiton sending updates--to specify what algorithm the receiver should use. The owner usually has excellent information about what DR algorithm is reasonable, and the DeadReckoningParameters record of the Entity State PDU contains an "deadReckoningAlgorithm" enumeration field. When the application that owns the entity puts out a state update it specifies what algorithm to use, and includes the information, such as velocity and acceleration, in the PDU. 

The values in the table below map to the alogrithm to be used.

<img src="images/DeadReckoningAlgorithms.jpg">DeadReckoningAlgorithms.jpg</img>

The algorithms are mostly straight forward applications of Newtonian mechanics. 

If the value "1" is seen in the field, the entity should not be dead reckoned at all. Dead reckoning is not computationally free, and if the entity is not moving it makes sense to tell the receiver to simply not perform the computations. 

DR algorithm two uses only velocity to guess the location of the entity. DR algorithm three expands the kinematic information used in DR to angular velocity, which allows the receiver to guess the entity's orientation as well. DR algorithm four expands this further to linear accleration. DR algorithm five uses linear velocity and acceleration, with no angular components. 

DR algorithms six through nine are similar to the above, but use the local, body-centered coordinate system rather than the global coordinate system.

###Dead Reckoning Thresholds

One of the interesting insights of DIS is that the owner of the entity can change the DR algorithm used, and is also not limited to sending out updates only at fixed intervals. If the owner of the entity realizes that the receivers will be out of sync with the owner it can immediately send an entity state PDU with the current entity state information. Let's say our tank makes a left turn. The owner knows that all the receivers at DR'ing the entity and expect it to continue in a straight line. Rather than waiting for the next heartbeat message to send out a state update, the owning application can immediately send a new ESPDU when the turn is made. This will minimize the time the receiving applications are out of sync with the owner.

The idea of sending out updates when we know the simulations listening to our updates will become out of sync can be generalized. We know what DR algorithms other participants are using--our simulation told them what to use. We also know what data we sent them, so we know enough to compute where they think we are. So a technique is to run the dead reckoning algorithm on our host as well--we'll do exactly the same computations as the other participating simulations. When we discover that the dead reckoned position exceeds some specified threshold from where we know the entity is, we send out an immediate state update.


###Dead Reckoning to Mitigate Latency Effects

Suppose we write a "Fast and Furious" themed simulator for training reprobate Humvee drivers. Two drivers are in a head-to-head drag race in lanes next to each other, driving virtual Humvees. There's 200 ms of latency between the simulators. What views do the simulators have of the other vehicle?

If we relied solely on dead reckoning used as above to reduce the number of update packets sent, all the updates we received would describe the state of the other Humvee 200 ms ago. At 100 mph (and highly optimistically assuming a Humvee could get up to 100 mph) that translates into a discrepancy about 9 meters in the position of the other vehicle. The other simulator would have a similary mistaken view of us. When the crossed the finish line each might think it won the race. We need another technique to reduce the effects of latency.

In DIS this can be done by using the timestamp field in combination with the dead reckoning algorithms. Every PDU contains a timestamp field that, if the standard is being followed, includes a measure of time since the top of the hour. When we receive the entity state PDU update we can perform a relatively simple operation: based on the specified DR algorithm, extrapolate the position of the entity. If the time is synchronized between hosts using a service such as Network Time Protocol (NPT) as discussed in the <a href="Timestamps.md">Timestamps</a> section, we can compare this to our own view of the current time. This will give us an estimate of the total latency for updates. We'll then run the DR algorithm and get an estimate of the true position of the other Humvee. DIS DR algorithm five is probably a good choice; it includes both velocity and acceleration in the DR computations, and ignores angular velocity. 

Note that we are now using DR for a reason distinct from decreasing bandwidth use. It's being used to descrease the effects of latency. This isn't cost free; running the DR algorithms for both the entities being received and the entities we publish can consume some computational resources. But in the end, most modern CPUs have several cores, and these tasks can often be parallelized. Simulations are often not restrained by their ability to do computations, but rather by graphics or I/O.



###What If the Dead Reckoning is Wrong?

Obviously, the DR algorithm could fail. One participant could let off the gas. This will likely trip the DR threshold and cause an update message to be sent, but it will still take 200 ms before it arrives at the other host. During this period the other host will continue to DR and update the screen position of the Humvee, which will show us a false position.

So what do we do in this case? Basically, we lie to the user. A key part of virutal worlds is keeping the user immersed and providing him a sense of presence. When we discover the local DR algorithm has incorrectly placed an entity the usual approach is to gently correct the position of the entity to the latest reported position. The key is to make the movement look realistic. 
 


###Further Reading:

Bandwidth benchmarking: http://wiki.networksecuritytoolkit.org/index.php/LAN_Ethernet_Maximum_Rates,_Generation,_Capturing_%26_Monitoring

UDP internals: https://www.codeproject.com/articles/275715/real-time-communications-over-udp-protocol-udp-rt

UDP Linux internals: https://blog.packagecloud.io/eng/2016/06/22/monitoring-tuning-linux-networking-stack-receiving-data/#data-arrives

Performance tuning: https://blog.cloudflare.com/how-to-receive-a-million-packets/

Dead Reckoning performance: <a href="documents/DeadReckoning_Ryan.pdf">documents/DeadReckoning_Ryan.pdf</a>