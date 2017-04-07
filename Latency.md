## Latency

Latency is the time it takes for a message to travel from one application to another. Latency is distinct from bandwidth, a measure of the amount of data that can be sent per time period. It's possible to have a high bandwidth, high latency connection. An example of a connection like this is a satellite in geosynchronus orbit over which we can send 100 MB/sec. That's high bandwidth, but at the same time it takes 250ms for a message to get from earth to the satillite and back.  This latency has a hard lower limit established by the speed of light; any message has to travel up to orbit at 72,000 KM and then back down. There can also be low bandwidth, low latency connection, over which we can't send very much data, but what data we do send arrives quickly. 

Another metric of network performance is Packet Delay Variation (PDV), sometimes called jitter. Jitter is, loosely defined, the variance of the latency. There are multiple detailed metrics for how to measure PDV or jitter when you get down to brass tacks an try to define a statistic.  The "variation of latency" term captures the essential meaning. The IETF RFC in the "further readings" section discusses the issues involved in defining a precise definition.

Latency can pose very complex theoretical problems in virtual worlds yet sometimes applicaitons can have direct and practical mitigation strategies.  Military simulations may be required to operate in high latency environments due to the unusual environments in which they operate. Especially in LVC environments networks may be field-deployed and tie together multi-site applications. If this is the case, and a high latency environment can't be avoided, then networked virtual environments can compensate in several ways. This comes at the cost of more simulation application complexity.

### The Latency Problem

The essence if a virtual world is creating the illusion that application avatars from several hosts are interacting with each other in a shared virtual space. A fundamental problem that needs to be addressed is that it takes time for an entity state update to travel from one host to another. 

Suppose the simulation user is looking at the display of a virtual world application and views an entity published by another host. Is the entity really where the display says it is? It depends. 

The host publishing the entity sends out state updates with the entity's position, but it takes time for the state update to get to our host. The application that publishes the entity prepares the update message, sets the timestamp field, and then sends the message out over the local operating system's network stack. The message must travel across the network, be delivered up our local host's network stack, and be handed off to our application, where our application parses the message, does any local processing or computations, and updates the graphics display. That time delay--the latency--between the publisher sending the message and the receiver that runs the display can cause problems when attempting to maintain the illusion of a shared world. Even if two applications are running on the same host the we can still see the effects of latency.  The time necessary for a message to traverse the network in the above list of latency components is only one element that contributes to overall latency; the application still must deal with the inherent latency of creating, copying, and parsing messages.

Latency can be a problem in many aspects of a simulation. Broadly speaking, latency can impact any _shared, dynamic_ state in virtual worlds. The entity's location is an example of this phenomenon. Someone looking at the display of a simulator, such as Close Combat Tactical Trainer, sees multiple soldier avatars each controlled by a different host. Suppose he looks at a particular enemy solider on the display. Is the enemy soldier where our display says it is? It could be. For example if the entity hasn't moved for the last 30 minutes it's likely that the shared, dynamic state information for the simulaiton is consistent between the cooperating applications.  The state updates have been sent and received long ago, and the state hasn't changed. Both applications see the entity at the same location. 

On the other hand, what if the solier entity is moving? The position of the avatar we see on our screen differs from what the host controlling the avatar believes the position to be.  Without any latency compenstation techniques, the difference in entity position between the two hosts will be Entity Velocity * Latency. The two hosts will see the same entity in different positions, depending on how fast the entity is moving and what the latency is. See figure x for an illustration of this principle.

Figure X

For some applications it might not matter if the data about entity positions is not completely consistent between hosts. Even if all of them are not exactly where we think they are, the entity positions may be close enough for the purposes of the simulation. A map-based display for an artillery fires training simulator may only care if the entities are within a few meters of their displayed location. On the other hand, a virtual or augmented reality application may need the hosts to agree on the location of entities to within a few centimers of what other applications believe the entity's position to be. In the end, it depends on what the simulation is trying to accomplish.

If we know what direction the entity controlled by the remote host is moving and what the latency between the hosts is we can use this information to mitigate the latency problem. We can use Dead reckoning, sometimes called extrapolation, of the entity's position in our application to guess about where the host controlling the entity believes the entity to be. If the entity is traveling in a straight line at a constant velocity and our application is using a dead reckoning algorithm that models that behavior, our application may have correctly estimated the location.  Displays on both hosts show the entity in the essentially the same position. But it may not. If the entity in the publishing application suddenly changes course our application can't discover that fact until a state update with the new direction and state actually arrives. That won't happen, at a minimum, for the full period of the latency between the applications. The two applications will not have completely consistent state information.

It's important to note that the application can make use of the timestamp field in combination with dead reckoning to reduce preceived latency. The timestamp field (if an absolute time format) gives the receiving application an estimate of where the entity was at a specific point it time. We can use that information, along with the time as perceived on the local application, to dead reckon an estimate of where the entity should be at the current time. See the dead reckoning section of this document for details. 

### Dead Reckoning to Mitigate Latency Effects

Suppose we write a "Fast and Furious" themed simulator for training Humvee drivers. Two drivers are in a head-to-head drag race in lanes next to each other, driving virtual Humvees. There's 200 ms of latency between the simulators. What views do the simulators have of the other vehicle?

If we relied solely on dead reckoning used as above to reduce the number of update packets sent, all the updates we received would describe the state of the other Humvee 200 ms ago. At 100 mph (and highly optimistically assuming a Humvee could get up to 100 mph) that translates into a discrepancy about 9 meters in the position of the other vehicle. The other simulator would have a similary mistaken view of us. When the crossed the finish line each might think it won the race. We need another technique to reduce the effects of latency.

In DIS this can be done by using the timestamp field in combination with the dead reckoning algorithms. Every PDU contains a timestamp field that, if the standard is being followed, includes a measure of time since the top of the hour. When we receive the entity state PDU update we can perform a relatively simple operation: based on the specified DR algorithm, extrapolate the position of the entity. If the time is synchronized between hosts using a service such as Network Time Protocol (NPT) as discussed in the <a href="Timestamps.md">Timestamps</a> section, we can compare this to our own view of the current time. This will give us an estimate of the total latency for updates. We'll then run the DR algorithm and get an estimate of the true position of the other Humvee. DIS DR algorithm five is probably a good choice; it includes both velocity and acceleration in the DR computations, and ignores angular velocity. 

Note that we are now using DR for a reason distinct from decreasing bandwidth use. It's being used to descrease the effects of latency. This isn't cost free; running the DR algorithms for both the entities being received and the entities we publish can consume some computational resources. But in the end, most modern CPUs have several cores, and these tasks can often be parallelized. Simulations are often not restrained by their ability to do computations, but rather by graphics or I/O.

### Consistency vs. Throughput

There's a fundamental tradeoff between the consistency of the shared state information and how responsive the applications are. 

Imagine two applications, A and B, that implement a networked virtual environment. Each is publishing entities that move about randomly, so dead reckoning doesn't help us, because dead reckoning depends on predictable movement. Application A will see B's entities a little time lagged, and likewise for B's view of A's entities. It takes some time period, L, to transfer entity state information between the applications.

At first glance it might appear that we can solve this problem by insisting that all applications have the same shared, dynamic state. We'll demand that A and B have exactly the same state information at the same time and implement some clever algorithms to make this happen. The distributed database application world loves this stuff, and they've developed algorithms such as distributed two-phased commits that feature atomic (all or nothing) transactions in a networked environment. The problem is that this takes time, and during that time we can't effect still more changes to the dynamic shared state. 

Let's say application A publishes an entity position update. We start our clever algorithm for consistent shared state, such as a two phase commit (see additional reading) which involves sending an update, waiting for confirmation that application B is ready to commit the update, sending a commit request, and then waiting for a acknowledgement that the commit has occured. Notice that this requires several round trips, each of time L. Suddenly our update time is several multiples of L, and our state updates aren't ocurring very quickly. What happens if the user in application A pushes a joystick to moves his entity while we are running our two-phased commit algorithm for consistent shared state with the prior position update? If we insist on completely consistent application state, our application can't update the local entity's position until our distributed update has completed or rolled back. This is very frustrating for the user; he's pushing on the joystick to move his entity, but the entity's position isn't changing. All the applications have consistent shared state, but the throughput and responsiveness is unacceptable. It gets worse if there are also applications C, D, E, and F in the virtual world, and any of the messages in the two-phase commit dance are lost in transmission. Also, notice that the coordination messages needed to coordinate a consistent state take up bandwidth. 

We may not be able to ensure a completely consistent shared dynamic state at all if we also require real time simulation. In a real time simulation the simulation has to advance at the same rate as wall clock time. If several messages need to be exchanged, with L latency each time, we may not be able to execute the distributed transactions as quickly as the state changes occur in real time.

Yet another option is to keep the authoritative game state on a central server. This is a popular technique in commercial games. If someone shoots at someone else the positions of the shooter and target and any physics involved are resolved on the central server. For various reasons (including player cheating) this can be a useful technique, but in the end it in some ways just makes the problem look different--now we have to worry about consistency between the client and the authoritative central server instead of between clients. In any event DIS made the design choice to use an entirely peer-to-peer architecture with no central server at all, so we can ignore this option in the context of DIS.

In practice, applications accept the reality that the shared states of the applications can be a little out of sync with each other in order to get acceptable responsiveness, or even a real time simulation that works at all. The lack of synchronized game state creates other problems we'll discuss later.

### How Bad is Latency?

Suppose our application is an interactive map that receives DIS ESPDUs and plots their position. A battlefield map may not be adverely affected at all if the entities are one second out of sync with the publishing application because the inconsistencies in the map display are trivial compared to the accuracy the application needs. Virtual simulations are much more sensitive to latency issues, and are the most challenging application to get right. 

The entertainment industry has many first person shooter (FPS) games that demand attention to latency details. FPS games like DOOM, Call of Duty, and Counterstrike are very popular, and players may be scattered across a continent. They have very tight, "twitch" interactions between entities, usually involving player avatars shooting at each other, and this requires low latency and high precision. Simulations with entities that move in a more stately manner, perhaps a naval ship simulator, may have game play that allows slower reaction times because the latency-induced position errors are smaller and not as relevant to the user experience. The military often focuses on training for teamwork and procedures, even in virtual worlds, rather than tasks that require fast reaction time.

How bad is latency, anyway?

Many military simulations are run in one room at a single site and this reduces network latency to the mimimum. It's often less than 5 ms between hosts that are on the same ethernet network in the same room. If running on a wireless network  instead of a conventional ethernet network media then latency can be a bit higher.  The latency grows as the network "distance" between the applications increases, with "distance" defined very casually. Every time a network packet crosses a switch or makes a router hop some latency is introduced. Home cable modems can add around 5-40ms, and DSL modems around 10-70ms. A  dial-up modem can add 100-200ms. (Go use stone-age technology somewhere else.) In some military applications there are other sources of latency. In an LVC environment it's not uncommon for the state update messages to undergo multiple format changes. A live update from Automatic Information System (AIS) commerical ship position reports may have to have its format changed from the native AIS format to DIS, and then perhaps be converted again to XML so it can transit a security guard that sits between the unclassified and classified networks. From there it may need to be ingested into an HLA simulation or handed off to a C4I system, and each of those has their own message format. Some military network links go over satellites in geosynchronus orbit 25,000 miles above earth. The message may be encrypted and decrypted.  Each of these steps introduces more latency in addition to the network latency.

The speed of light provides a lower bound on network latency. A rough rule of thumb is that crossing one time zone has a minimum of around 10ms of latency. This can only increase from there, depending on the network hops taken and the efficiency of the routers on the path between the hosts.

In addition to network latency there are other sources of lag. A display frame rate of 60 frames per second is pretty good--that's how frequently the display is updating the presentation of game state to the user. That translates into 17 ms of lag between frame refresh operations. The virutal world or other type of simulation application also performs a loop the involves receiving data, performing computations, and sending any updates required, and this obviously takes time. It may be a significant factor in latency if complicated physics, AI, or I/O such as database lookups is involved before the message can be used to update the screen.

The table below shows the observed network latency from the Naval Postgraduate School in Monterey, California (not far from San Francisco and Silicon Valley) to several Amazon Web Services (AWS) regions where Amazon cloud servers are hosted. NPS has a good connection to high speed research networks. Non-academic sites are likely to be worse.

| Region               | Latency (ms) | 
|----------------------|--------------|
| US-East (Virginia)   | 89           |
| US-East (Ohio)       | 85           | 
| US-West (California) | 30           | 
| US-West (Oregon)     | 52 |
| Europe (Ireland)     | 170 |
| Europe (Frankfurt)   | 179 |
| Asia Pacific (Singapore) | 217 |
| Asia Pacific (Sydney) | 194 |
| Asia Pacific (Japan) | 144 |
| Asia Pacific (Korea) | 155 |
| Asia Pacific (Mumbai) | 294 |
| South America (Brazil) | 266 |
| China (Beijing) | 422 |

A graph displaying observed latency distribution between California and Texas (circa 2010) is shown below. The network was operating under "normal" production load, shared with production system network traffic and with no attempts to optimize via quality of service measures. This gives an idea of typical variance in the latency, and how the latency of messages is distributed. 

<img src="images/LatencyGraph.jpg">

How much does latency affect a simulation? Some estimates for the position errors resulting from various latencies are in the table below.

| Delay  | Tank (100 km/h) | Aircraft (1000 km/hr) | Missile (4000 km/hr) |
|--------|-----------------|-----------------------|----------------------|
| 1000   | 28 m | 278 m | 1111 m |
| 85     |  2 m | 24 m | 94.4 m|
| 60     | 1.67 m | 17 m | 67 m|
| 25     | 0.7 m | 7 m | 28 m |
| 1      | 0.03 m | 0.28 m | 1.1 m |

As you can see, slower-moving entities are less senstitive to latency errors, and fast-moving entities more sensitive. Are the position errors big enough to worry about? That depends on the simulation, but the answer can easily be "yes." In practice, whether a DIS virtual world simulation is "true" is often subjective. The objective of the simulation is often training rather than a Platonic ideal of absolute truth. If it's convincing--if it creates a sense of presence and reality good enough for training, and if the results aren't so far off from ground truth that negative training occurs, it can still be useful. In the end, the users are being trained to the correct standard, even if some white lies are being told to the users. Whether this assumption about the harmless effects of simulation latency remains true  may not hold for other applications, such as combat analysis or procurement decisions.

### Latency and Causation

Latency can also affect perceived cause-and-effect in simulations. Suppose we have an artillery simulator, a tank simulator and a UAV simulator with inter-application latencies that are not the same. The latency between the artillery and tank simulator is 10 ms, tank-UAV latency is 20 ms, and artillery-UAV latency is 100 ms. This performance may be caused by any number of real world network architecture issues.

| Simulator | Artillery | Tank | UAV |
|-----------|-----------|------|-----|
| **Artillery** | -         |10 ms | 100 ms| 
| **Tank**      | 10 ms     | -    | 20 ms |
| **UAV**       | 100 ms    | 20 ms | -  |


The artillery unit fires on the tank, and destroys it. The tank simulator changes its state to show itself as destroyed, and sends out a state update. From the perspective of the UAV the tank will be destroyed before the artillery fires. The artillery fires at t=0, and the tank simulator is informed at t=10. The tank in the simulator discovers it has been destroyed and sends out an update to its state. The new "destroyed" tank state arrives at the UAV at time t=30 (or 10 + 20). The artillery simulator's shot appears at the UAV simulator only at time t=100. The tanks explodes, and 70ms later we see the artillery that caused the explosion firing. 

This is sometimes called a causality violation. It may arise from other causes in addition to steady-state latency issues. Remember, UDP makes no guarantees about in-order packet delivery, or reliablity for that matter, so it's possible for UDP packets to arrive in a different order than which they were sent.

This can mitigated to an extent, certainly if the messages are being captured and replayed.  The <a href="PDUBundling.md">timestamp</a> field in the DIS PDU header can contain an absolute time hack, the time since the top of the hour.   If the simulation is so configured to use absolute time stamps this can be used to order the PDUs in rough absolute time order for replay and analysis.

### Latency and User Perceptions

Suppose we have a simulation for a drag race. Two simulated cars in (virtual) adjacent lanes launch from the start line and race to the finish, and the two hosts controlling the cars are separated by a network that has a total of 200ms of latency.

Simulation A has a good idea of where it is, but we also want to show where the other car is so the driver can adjust his strategy. We receive updates from simulation B 200 ms after the position of the car is sent. From the standpoint of simulation A, B's car is 200 ms behind its actual position, or at 100 mph there's about nine meters of discrepency. Simulation B has a similar mistaken view of A's postion. When they cross the line each user may believe they won the race.

We can avoid some of this with dead reckoning. The entity state PDU can include fields for the velocity, acceleration, and, critically, an absolute timestamp. The simulations can use this information to better depict an estimated position for its counterpart's car. When simulation A receives the state update it notes the reported position of the entity and when the update was sent. We can then apply a dead reckoning alogrithm to estimate where the entity is at the current time, based on its velocity, acceleration, and the time that has elapsed since the update was sent. 

Is this perfect? Nope. If the engine of simulation B's car blows up during that 200 ms of latency the dead reckoning will be wrong, and we'll have a mistaken view of the relative positions. But it's arguably better than the alternative. 



### Solutions

One emerging method for coping with latency is to make distributed networked virtual environments less distributed. That sounds contradictory, but isn't, quite. Cloud computing has compelling business advantages over conventional approaches and promises significant cost savings. Virtual machines in the cloud can be run very cheaply. There are also applications like Remote Desktop on Windows, X-Windows or VNC on Unix, or Apple Remote Desktop in the Apple environment that let the user remotely view the desktop of a machine running elsewhere. The conventional approach to distributed simulation is to keep the both the participating hosts and the displays local to the user. If the simulation is geographically distributed this also means the latency can be high between the hosts running the simulation, and therefore the local application physics starts becoming complex. But if the hosts running the simulation are co-located on the cloud the latency-induced location errors are smaller, because latency between hosts is reduced to the bare minimum. This of course is pushing the problem around on the plate rather than actually solving it, but it may rearrange it in a way that's useful. The user is now seeing what is in effect a streaming video of the desktop that's running on the cloud. All his user input--his mouse clicks, his keyboard input, his joystick inputs--is going from his local desktop to the cloud, latency time L away, which means his inputs are less responsive. The video of the desktop running in the cloud has to be sent back to the local desktop, which takes time and makes the display less responsive. We'll also probably need more bandwidth to communicate with the server; we're streaming back the video display instead of sending state updates, and the state updates tend to be smaller.  The tradeoff is that it may make the physics workable in high latency distributed applications.

Dead reckoning is the most popular way to compensate for latency. See the dead reckoning section for details. 


That's a lot of problems, and not a lot of solutions. It's the nature of the beast. Do what you can to keep latency low. Conventional wisdom in the commercial gaming world is that FPS games should have under 100ms of latency. Human reaction time is around 250ms; if your simulation is trying to do human-in-the-loop, twitch reaction training it can't be much higher than that, and that's very much pushing it. High latencies can be gotten away with for certain types of applications, such as non-virtual simulations. In a high latency environment simulation designs can try to de-emphasize the reaction time component of training, and emphasize things like teamwork or training for procedures that rely less on reaction time.

FURTHER READING

Sandhep Singhal and Michael Zyda, _Networked Virtual Environments_, Addison Wesley 1999. It's a very good book that discusses many of the fundamental problems in virtual worlds.

Andreas Tolk, Combat Modeling for discussion of causation and drag racing
  
Two-Phased commits: <a href="https://en.wikipedia.org/wiki/Two-phase_commit_protocol">https://en.wikipedia.org/wiki/Two-phase_commit_protocol</a>

Game latency: https://web.cs.wpi.edu/~claypool/papers/precision-deadline-mmsys/claypool-precision-deadline.pdf

Packet Delay Variance as discussed by the IETF: <A href="https://tools.ietf.org/html/rfc5481">https://tools.ietf.org/html/rfc5481</a>

Cloudping, a tool for finding the average latency to AWS regions: <a href="http://cloudping.mobilfactory.co.kr/">http://cloudping.mobilfactory.co.kr/</a>

An MS thesis devoted to measuring latency in DIS from Captain Drinkwater at AFIT: <a href="documents/DISLatencyThesis.pdf">documents/DISLatencyThesis.pdf</a>