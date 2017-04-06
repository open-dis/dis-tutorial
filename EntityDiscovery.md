##Entity Discovery

Imagine that a program depicting a virtual world starts on a host. There are several other simulation participants that have been running and describing the position of entities for some time; perhaps ONESAF and JCATS have been publishing constructive entities for hours before our virtual simulation starts. How does our program learn of all the entities that have been published by other particpants?

### What doesn't happen

To understand why DIS took the approach to discovering entities it did, it's useful to consider some algorithms that were _not_ used.

One way to discover entities would be for the program, on startup, to contact some sort of central server, and ask that server to return a list of all the entities in the world. A corallary to this is that any participant that publishes an entity would notify the central server of this fact. If DIS were designed in this era, that's probably the design choice that would have been made.  But writing a server back then was considered at least moderately deep magic, and there were few standards for a server API. Some sort of custom API for querying the server would have to be written, and more importantly standardized. 

If DIS was designed today the choice would likely be to use an HTTP server as a central registration point for entities. Web servers are nearly trivially easy to set up, and HTTP is a standards-based interface. The web server could also be used for some other tasks, such as serving simulation content. There are a wealth of tools to create custom web services that are standards-based. Still, this design choice would not be cost free. DIS made the choice to be peer-to-peer and serverless. No server is required to make implementations from different vendors work together. In theory, simulations can simply be started, and will interoperate out of the box, with no configuration. The reality often falls short of this, as can be seen with the proliferation of gateways, but it is true that not requiring a server to be present simplifies exercise setup and configuration in many cases.

Another possible solution to the problem would be for the simulation that has just started to ask the other particpants for a list of the entities they publish. Perhaps the simulation that is joining could broadcast a "Give me a list of all your entities" message, and then build a complete picture of the virtual world from the responses. This approach can have problems as well. DIS usually uses UDP, and UDP is unreliable. There is no guarantee that the "give me a list of your entities" message will be received by the other participants, and no guarantee that the responses will be received by the host sending the message. In fact, there may be what is sometimes called an "ack implosion." If a participant sends out a request message and a hundred other participants hear it and respond, then the sender may be overwhelmed by hundreds of responses flooding in at nearly the same time. There are various ways in which this can be mitigated, such as randomized response times, but suddenly the solution we thought would be simple and direct has become more complex.

### What happens 

DIS simply listens on the network for Entity State PDUs. Each ESPDU it receives contains a unique ID and an entity type. As other participants send ESPDUs, our simulation receives the messages and builds a list of the other entities in the virutal world. This approach has a number of virtues. It is very simple to implement, and requires no central server. It works without configuration. 

The hidden assumption in this approach is that the entities must periodically send ESPDUs, even if their state does not change. Imagine a tank sitting still. It's state is not changing, so one might think that it is not necessary to send ESPDUs that just confirm that nothing has changed. That's not the case. Simulations that have recently joined would have no idea that the entity exists. As a result the DIS standard mandates that entities send "heartbeat" messages in the form of ESPDUs every few seconds even if the state of the entity has not changed. This is one of the design trade-offs DIS made: in exchange for a simple and robust entity discovery mechanism, DIS uses more bandwidth because of all the heartbeat messages. The effect can be significant. Vehicle entities often don't move, and ESPDUs are also used to describe some other things, such as minefields or buildings, that _never_ move. In a brigade or high level constructive simulation the network traffic can become quite chatty. Consider a simulation publishing a thousand constructive entities. Each ESPDU has a minimum payload of 144 bytes, plus 28 bytes for the TCP/IP headers. If a heartbeat message is sent every five seconds, this translates into about 30KB/sec of heartbeat messages. The effect is worse if each ESPDU is in a seperate datagram because receiving a UDP datagram is a somewhat expensive operation for the host. HLA, in contrast, uses a publish-and-subscribe design, and heartbeat messages are not required. This allows HLA to use the network more efficiently.

The heartbeat algorithm also accepts an inherent delay in discovering all the entities in the world. A simulation has to wait for at least one heartbeat cycle to discover all entities. It can be worse than this, for example if some ESPDUs are dropped by UDP. It's safer to wait for a few heartbeat cycles when building an entity list. Usually from a practical standpoing the disovery lag is fairly small and manageable.

This algorithm also suggests a technique for discovering when an entity has left the virtual world. Since they're required to send an ESPDU every heartbeat cycle, if we fail to hear from an entity we have previously discovered for several cycles, we can assume it has been removed by the publisher. Several cycles are needed to detect removal because UDP comes with the inherent risk of dropping packets.

How long is the hearbeat cycle? It depends. Typical values are 5-10 seconds for air and land vehicles. Traditionally DIS had a heartbeat time of five seconds. As experience with simulations grew it became apparent that sedentary entities could have a longer heartbeat period. Some simulations are what are called "Full Heartbeat Compliant" (FHC) and can have longer heartbeats for certain classes of entities. Older simulations are called Minimum Heartbeat Compliant (MHC) and have a single, shorter heartbeat for all entities, regardless of type. The world being what it is, you can expect that DIS simulations that use both strategies will wind up interoperating, resulting in a Mixed Heartbeat Compliance (MHC) environment. Remember that a longer heartbeat also implies a longer timeout period, and that if heartbeats vary by entity type, so do timeouts. The table below shows some typical heartbeat values for FHC simulations.

| Platform    | FHC  | MHC | 
|-------------|------|---  |
| Air Vehicle | 5 sec| 10  | 
| Land Vehicle| 55   | 10  |
| Stationary  | 60   | 10  |


Stationary entities, such as minefields, may have heartbeats of 60 seconds. It's usually fairly safe to use a heartbeat value of around 10 seconds. Older MHC simulations will assume an heartbeat time of 5 seconds. If you're interoperating with one of these simulations you should set the heartbeat for all entities to that of the simulation with the shortest heartbeat.  

It's traditional to set the timeout value to three times the heartbeat rate to allow for dropped UDP messages. For a 10 second heartbeat value that means that if we don't hear from an entity for 30 seconds we can assume that it has left the simulation. There's a small chance we will incorrectly remove an entity, but this requires three consecutive dropped UDP datagrams. Even if we do remove the entity, it will be re-added the next time we receive an ESDPDU. 

Variable heartbeat times based on entity type make the code required to implement somewhat more complex, but not excessively so.

### Alternative methods

The description above is a simplification. DIS also has Simulation Management family PDUs that include "Create entity" and "Remove entity" messages that provide alternate pathways to create and remove entities. A full implementation of DIS should respect these. In the wild these PDUs seem to have spotty implementations at best, and the odds are good that other simulations will simply ignore them if you send them. At the very least you should confirm that the simulations you plan on interoperating with will do something with the Simulation Management PDUs. 

### Summary

DIS uses a simple and robust method for discovering entities. There are some drawbacks to the approach it chose, including profuse use of the network for simulations with a large entity count. 