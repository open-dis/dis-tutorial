##Latency

Latency can have a very simple practical solutions yet at the same time be a very complex theoretical problem.

### The Latency Problem

The essence if a virtual world is creating the illusion that all participants are interacting with each other in the same virtual space. A fundamental problem is that it takes time for an entity state update to get from one application to another.

Suppose the simulation user is looking at the display of a virtual world application, and is viewing an entity published by another host. Is the entity really where the display says it is? It depends. The host publishing the entity is sending out state updates with the entity's position. It takes time for the state update to get to us. The the application that publishes the entity must prepare the update, send it out over the local operating system's network stack, and then the message must travel across the network, be delivered up our local host's network stack to our application, where our application parses the message and updates the graphics display. During that time delay the entity may move. Even if two applications are running on the same host the we can still see latency--removing the network transmission time does not reduce latency to zero. Entity location is one example of this phenomenon, but there are others. More broadly, latency can impact any _shared, dynamic_ state in virtual worlds. If there is dynamic terrain shared between applications then we want all hosts to have a consistent view of the terrain.

So is the entity were our display says it is? It could be. For example if the entity hasn't moved for the last 30 minutes it's likely that the shared, dynamic state information is consistent between the cooperating applications. Even if it's not exactly where we think it is, it may still be close enough. If we're doing dead reckoning of the entity our application will be using an algorithm to guess about the entity's location. If the entity is traveling in a straight line at a constant velocity and our application is using a dead reckoning algorithm that fits well with that behavior, our application may have correctly estimated the location and displays on both hosts show the entity in the same position. But it may not. If the entity in the publishing application suddenly changes course our application can't discover that fact until a state update with the new direction and state actually arrives. That won't happen, at a minimum, for the full period of the latency between the applications.

###Consistency vs. Throughput

There's a fundamental tradeoff between the consistency of the shared state information and how responsive the applications are. 

Imagine two applications, A and B, that implement a networked virtual environment. Each is publishing entities that move about randomly, so dead reckoning doesn't help us. Application A sees B's entities a little time lagged, and likewise for B's view of A's entities, because it takes some time period, L, to transfer state information between the applications.

At first glance it might appear that we can solve this problem by insisting that all applications have the same state. We'll demand that A and B have exactly the same shared, dynamic state by implementing some clever algorithms. The distributed database application world loves this stuff, and they've developed algorithms like two-phased commits that allow atomic (all or nothing) transactions in a distributed environment. The problem is that this takes time, and during that time we can't effect still more changes to the shared, dynamic state. 

Let's say application A publishes an entity position update. We start our clever algorithm for consistent shared state, which usually involves sending an update, waiting for confirmation that application B is ready to commit the update, and then sending a commit request and waiting for a acknowledgement that the commit has occured. Notice that this requires several round trips, each of time L. Suddenly our update time is several multiples of L. What happens if the user in application A pushes a joystick to moves his entity while we are running our clever algorithm for consistent shared state on the last position update? If we insist on completely consistent application state, our application can't update the local entity's position until our distributed update has completed or rolled back. This is extremely frustrating for the user; he's pushing on the joystick to move his entity, but the entity's position isn't changing. All the applications have consistent shared state, but the throughput and responsiveness is unacceptable. It gets worse if there are also applications C, D, E, and F in the virtual world, and any of the messages in the two-phase commit dance can be lost in transmission. Also, notice that the coordination messages needed to coordinate a consistent state take up bandwidth. 

In practice, we almost always accept that the shared states of the applications are a little out of sync with each other in order to get acceptable responsiveness. That creates other problems we'll discuss later.

###How bad is it, and how good does it need to be?

How bad is network latency, and what does the application need in order to be useful? If our application is a map display latency might not matter much. A battlefield map that shows the location of tanks might not be adverely affected if the entities are one second out of sync with the publishing application. The inconsistencies in the map are trivial compared to the accuracy the application needs. Virtual simulations are the most challenging environment for latency. 

Many military simulations are run in one room at a single site. 



FURTHER READING

Sandhep Singhal and Michael Zyda, _Networked Virtual Environments_, Addison Wesley 1999. It's a very good book that discusses many of the fundamental problems in virtual worlds.
  
Two-Phased commits: <a href="https://en.wikipedia.org/wiki/Two-phase_commit_protocol">https://en.wikipedia.org/wiki/Two-phase_commit_protocol</a>

Game latency: https://web.cs.wpi.edu/~claypool/papers/precision-deadline-mmsys/claypool-precision-deadline.pdf