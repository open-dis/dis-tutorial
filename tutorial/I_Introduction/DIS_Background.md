# Distributed Interactive Simulation

## I. Introduction

### a. DIS Background

Distributed Interactive Simulation (DIS) is a software standard used to help implement military simulation applications. The simulations that use DIS have hosts connected by a network, and the DIS protocol helps exchange information about the combat units in the simulation. This includes what types of vehicles are used, how they interact, or how they are used in combat operations. DIS is used in many United States Department of Defense (DoD) applications, and has been for decades. 

The software standard DIS involves definitions for dozens of network messages that are exchanged between hosts. The syntax and semantics of the messages, which are called Protocol Data Units (PDUs) in DIS, are carefully defined. The PDUs can be exchanged between CPUs of multiple designs, running many types of operating systems, and these operations can be done in multiple software languages. This helps make DIS flexible and effective.

To achieve its simulation operation objectives the DIS standard includes more than just message format issues. The syntax of messages is defined, but DIS also includes more information. Individual messages also include positions expressed in a particular global coordinate system, for example, and there are many other DIS rules that solve problems, such as detecting the presence of netowrked entities, or performing combat operations. The logical operations necessary to complete these operations becomes tricky and non-obvious. DIS simulation users must learn how to make use of the DIS operations, and this can become difficult unless the implementor knows how to do it. There is a standard for DIS defined by the Institute of Electrical and Electronics Engineers (IEEE) standards organization known as IEEE-1278.1. However in any standard the emphasis is placed on achieving unambigous and accurate definitions rather than helpful descriptions of how to make use of the defined features.

That is part of what this document is intended to achieve: describe and teach the effective implementation of the features that DIS can implement. The DIS standard is useful, widely used, and at the same time those using it can find it difficult to implement real application features due to the complex nature involved. It's helpful to have clear explanations. 

That's only part of it. DIS is flexible, and can be used in a range of applications. Simply listening to and saving the messages sent on the network from a live exercise can be very useful to analysts. They can later used the saved messages to examine what real vehciles or people actually did and use the collected data to help evaluate the effectiveness of combat tactics. Learning how this works, which can involve essentially no graphical display of the entities in a simuation at all, is a change from what's called the Networked Virtual Environment" (NVE) since there is no "virtual" graphics aspect for the user to view. 

The problem space of DIS is common in many ways to those that appear in the commercial game entertainment world. It is very unusual for commercial entertainment games to use DIS, but the technological implementation problems faced by games are often similar to those faced by DIS. If you're a commercial game programmer, some of the issues discussed here may help your commercial implementations.

There are other features of DIS that will be assessed as well. From an practical or even academic standpoint the number of questions raised through DIS can be enormous. It's therefore helpful to have specialists cooperate on this DIS Tutorial project. The tutorial project's structure is, one hopes, helpful in allowing experts on a topic to supply their answers while not causing issues with other sections of the tutorial.

### b. DIS Tutorial Purpose

Often the people who need to learn something about DIS are programmers who are thrown head-first into the problem. They're given some vague instructions, usually summed up as "Hey, we need to implement DIS in our application. Go make it work." Sometimes the programmers don't have prior experience with distributed simulations or virutal worlds. They often work on the project for a few weeks before moving on to something else, so they need to learn about the subject quickly. They're OK with coding, and often with network programming, but using DIS often involves a problem domain that is not clear to newcomers. For example, one would think that it is easy to direct an object in a virtual world to move one meter northwest. This is tricker than it may seem at first glance. What coordinate system is being used, and is that using metric or imperial units? How does one uniquely select an object so that it and it alone moves? Learning about each of these tasks can take a programmer days to unravel if he must rely on only the IEEE standard.

Another audience for this document is military or support personnel responsible for making existing DIS simulations work. They usually have good understanding of the military problem domain and perhaps the basics of networking and software installation. While they are subject matter experts on the military actions in the simulation, they may not be familiar with the nuts and bolts of how the simulation protocol works. An understanding of how things are done in DIS is often a great help in getting a simulation working, or understanding the limitations and features that are difficult or impossible to implement in a simulation.

Those using simulations that instead of DIS use HLA, TENA or WebLVC can also benefit from this manual. The HLA Realtime Platform Reference Federation Object Model (RPR-FOM) uses many of the concepts from DIS, and so can TENA. So understanding DIS also helps HLA RPR-FOM and TENA users. Sometimes HLA RPR-FOM simulations and DIS simulations communicate with each other via a protocol gateway, and the use of the gateway can be helped by users who appreciate the shared concepts.

Studying the standard in isolation can be confusing if the reader has no familiarity with the problems inherent to distributed simulations. The IEEE-1278 standards document does not usually explain the "why" it choose to solve the problems it did, or even that the problems it solves are in fact problems. This document includes an overview of distributed simulations and the inherent issues faced when implementing them. In order to explain the issues, background information on distributed simulations and virtual worlds is presented. If you already know all this, you can safely skip it. But for most programmers and administrators it provides the context for features or data in DIS that may seem mysterious at first. 

DIS consists of a few dozen network messages exchanged between simulations. Understanding the syntax of these messages and how to create and receive them is the easy part of DIS. A deeper understanding of what the semantic content of the messages are, and what problems they are trying to solve, is more difficult and more valuable.

If you just want to sling some code and skip all the throat-clearing and theory, you can start reading the "Protocol Data Units: Exchanging State Information" section. 

DIS standardizes the format of network messages but has no formal programming API. If a programmer wants to create what is known as an "Entity State Protocol", a network message that defines the location and orientation of an object in a simulation, the implementation of DIS is free to choose function calls of either 

~~~
espdu.setLocation(newLocation);
~~~

or 

~~~
espdu.setLoc(newLocation);
~~~

Those who implement the DIS standard can use any API they choose. The code in this document primarily uses the open-dis implementation, which is available at https://github.com/open-dis. There are implementations for several languages, including Java, Javascript, C++, C#, Objective-C, and Python. There are other implementations of DIS, both open source and commercial. There are also many home-grown implementations of the standard that were created by simulation implementors. They just wrote their own DIS implementation, or the portions of the DIS standard they needed. This means that the code-writers out there are likely see differences in the source code of two applications that do the same thing. But if they understand DIS, the objective of this document, they should be able to overcome the implementation issues.

There are other features of DIS that will be assessed as well. From an practical or even academic standpoint the number of questions raised through DIS can be enormous. It's therefore helpful to have specialists cooperate on this DIS Tutorial project. The tutorial project's structure is, one hopes, helpful in allowing experts on a topic to supply their answers while not causing issues with other sections of the tutorial.

### c. Graphics

To take the last topic first, the graphics portion of the shared virtual world is a subject unto itself because of the inherent complex nature of the topic. The art that portrays the shared environment may vary depending on the training objectives. In the commercial world, imagine the graphics of "Call of Duty" or other first person shooter entertainment games. Users who buy the games like good-looking and fast game graphics. In the DoD world, sometimes the training objectives also require high quality and quick graphics operations. For example, some flight simulators that replicate ground attack operations. Some applications also rooted in the DoD can instead use 2D maps to portray a shared environment. The objective of the simulation in this case is to provide users with information about where vehicles and units are, rather than individual vehicle appearance. A map-based graphics simulator may also require position updates once every few seconds rather than several times per second.

The choices about what graphics to include in a DIS application depend entirely on the DoD's training objectives. An implementor may be able to use Google Maps or Open Street Maps, for example. The map graphics are not realistic 3D displays of vehicles, but may achieve the simulation objectives. Alternatively some applications can use 3D graphics in a manner reminiscent of modern commercial games. There are many ways to draw the 3D images we see on the screen, from OpenGL and Direct3D to higher level scene graphs, such as OpenInventor or X3D. At an even higher level of abstraction objects can be rendered with the aid of a 3D game engine such as Lumberyard or Unity. A DIS application may have rudimentary 3D graphics instead of photorealistic 3D graphics, depending on the training use. Again, the audience being trained may benefit from high quality graphics, or still be well trained by a graphics system that is simple but effective in accomplishing the training objective.

Computer graphics is a large and complex subject, and instruction or examples often depend on the graphics standard chosen to describe the environment. We will discuss some graphics implementations for both for 2D maps and 3D applications. In some understandings, graphics use in simulations can be distinguished as being separate from DIS networking. The reality is that graphics are often used in simulations that use DIS, and from a practical standpoint a DIS tutorial has to at least mention how to use it.

### d. Formats and Semantics

Before the distributed simulation application can be implemented there needed to be a way to exchange *state information* between simulators. State information includes data about a participant in the simulation that is transmitted to other simulation hosts. In the case of a tank, the state information includes its position, the direction the vehicle is facing, how fast it is moving, whether it is on fire, and subjects such as which way the turret is pointing. It's this state information and the format that it is exchanged in that DIS standardizes. Once the state information is exchanged the graphics components we just described above can be used to draw the scene that the users see. 

It is in the government's interest to have simulators interoperate with each other, in particular to prevent vendor lock-in. If the protocol for exchanging state information is owned by a company and that company can prevent simulator competitors from entering the market, or charge more to make their simulators interoperate with those from other companies. To be useful the DIS protocol had to be a *standard*, and an open one. Simply providing a language implementation that did the job without also specifying what was being exchanged was inadequate. So SISO refined the SIMNET network protocol and developed a formal description of it, then took it to the IEEE, where it was approved as an international standard (IEEE-1278.1). From that point on anyone could buy the IEEE standard document and then write their own implementation of the protocol.

As is inevitable with these things, the standard has to be maintained and updated in light of experience and new technology. From the late 80's until about 1995 the DARPA SIMNET protocol was used; this predated the adoption of DIS as an IEEE standard. The first major release of a standard DIS was DIS version 5, in 1995. It was updated with version 6, in 1998, when a few new network messages were added. Version 7 was adopted in 2012, and that version maintained an almost complete backwards compatiblity to the DIS version 5 of 1995. At the same time it added a few new PDUs (network messages) related to directed energy weapons and also clarified the semantics of protocol. SISO continues to support and update DIS in working groups, today in parallel with the HLA RPR-FOM. 

### e. Networking

Sending the messages defined by DIS involves using, almost always, the TCP/IP networking system. That's simply because TCP/IP has become so widespread. Once upon a time there were other software networking standards, such as DECnet, IBM Systems Network Architecture (SNA), Open Systems Interconnection (OSI), or AppleTalk. Those high level network protocols are simply not in use to much of an extent these days. In the case of DIS, can be exceptions to the use of TCP/IP in radio alert applications, but this is somewhat rare.

Using TCP/IP to send DIS messages is useful. It is simple enough to use TCP, UDP, broadcast, and multicast. For the most part in this document the objective is to be as simple as possible when discussing the subject. Network programming is intended to stay at the highest levels possible, excluding, to the extent possible, such topics as the IP or lower levels.

### f. Parting Thoughts

Given the technology of the era, the architects of DIS were visionary. Even decades after it was developed and standardized it still holds up quite well. The research it prompted was trailblazing, and served as the starting point for many military simulations and then entertainment industry game applications. The ideas worked out in DIS are still widely used today.

### g. Further Reading

**Simulation Interoperabilty Standards Organization (SISO):** http://sisostds.org/<br>
**The IEEE DIS Standard, 1998 (Version 6):** https://standards.ieee.org/findstds/standard/1278.1a-1998.html<br>
**DIS Wikipedia:** https://en.wikipedia.org/wiki/Distributed_Interactive_Simulation<br>
**DIS Plain and Simple, another document that provides information about DIS:** https://www.sisostds.org/DigitalLibrary.aspx?Command=Core_Download&EntryId=29302<br>
**SIMNET wikipedia:** https://en.wikipedia.org/wiki/SIMNET<br>
**SIMNET History:** http://www.iitsec.org/about/awardsandrecognition/Documents/2015_FellowPaper_Miller.pdf<br>
**Still More SIMNET History:** http://www.dtic.mil/dtic/tr/fulltext/u2/a294786.pdf<br>
**A whole website devoted to SIMNET history:** http://simnet-history.org/<br>
**Networked Graphics: Building Networked Games and Virtual Environments**, Anthony Steed and Manuel Oliveira. https://www.amazon.com/Networked-Graphics-Building-Virtual-Environments/dp/0123744237

**Networked Virtual Environments: Design and Implementation**, Sandeep Singhal and Mike Zyda. Sadly out of print. https://www.amazon.com/Networked-Virtual-Environments-Design-Implementation/dp/0201325578/

