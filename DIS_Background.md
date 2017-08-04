# DIS: The Missing Handbook
## DIS Background

Distributed Interactive Simulation (DIS) is, along with High Level Architecture (HLA) and Test and Training Enabling Architecture (TENA), one of the three main standards for military simulations. This document is intended to help you understand DIS's implementation and how to use it. Many of the concepts used in DIS are re-used in HLA and TENA applications, so understanding DIS helps you understand other simulation applications used in the US Deparment of Defense and other nations as well. It can even be useful if you want to understand what commercial entertainment games do.

DIS and its concepts are widely used, but not necessarily explained well in a single document or book provided to programmers and users. DIS is approved as an IEEE standard. That standards document is available (as IEEE-1278.1), but it is focused on defining the format of DIS network messages rather than explaining how to use DIS to those implementing simulations. The theories of use for some DIS features may be scattered across many documents at many locations. The Simulation Interoperability Standards Organization (SISO) document archive is a good source, but the papers are numerous and spread out. Some aspects of DIS are known to practioners only on the basis of group experience and lore. 

There's no centralized place to learn about DIS and its use in applications. This document is intended to be an open source and community maintained introduction to and manual for DIS--both its supporting theory, and the practical implementation and configuration choices made by programmers who write simulations and technicians who run simulations.

Often the people who need to learn something about DIS are programmers who are thrown head-first into the problem. They're given some vague instructions, usually summed up as "Hey, we need to implement DIS in our application. Go make it work." Sometimes the programmers don't have prior experience with distributed simulations or virutal worlds. They often work on the project for a few weeks before moving on to something else, so they need to learn about the subject quickly. They're OK with coding, and often with network programming, but using DIS often involves a problem domain that is not clear to newcomers. For example, one would think that it is easy to direct an object in a virtual world to move one meter northwest. This is tricker than it may seem at first glance. What coordinate system is being used, and is that using metric or imperial units? How does one uniquely select an object so that it and it alone moves? Learning about each of these tasks can take a programmer days to unravel if he must rely on only the IEEE standard.

Another audience for this document is military or support personnel responsible for making existing DIS simulations work. They usually have good understanding of the military problem domain and perhaps the basics of networking and software installation. While they are subject matter experts on the military actions in the simulation, they may not be familiar with the nuts and bolts of how the simulation protocol works. An understanding of how things are done in DIS is often a great help in getting a simulation working, or understanding the limitations and features that are difficult or impossible to implement in a simulation.

Those using simulations that instead of DIS use HLA or TENA can also benefit from this manual. The HLA Realtime Platform Reference Federation Object Model (RPR-FOM) uses many of the concepts from DIS, and so can TENA. So understanding DIS also helps HLA RPR-FOM and TENA users. Sometimes HLA RPR-FOM simulations and DIS simulations communicate with each other via a protocol gateway, and the use of the gateway can be helped by users who appreciate the shared concepts.

Studying the standard in isolation can be confusing if the reader has no familiarity with the problems inherent to distributed simulations. The IEEE-1278 standards document does not usually explain the "why" it choose to solve the problems it did, or even that the problems it solves are in fact problems. This document includes an overview of distributed simulations and the inherent issues faced when implementing them. In order to explain the issues, background information on distributed simulations and virtual worlds is presented. If you already know all this, you can safely skip it. But for most programmers and administrators it provides the context for features or data in DIS that may seem mysterious at first. 

DIS consists of a few dozen network messages exchanged between simulations. Understanding the syntax of these messages and how to create and receive them is the easy part of using DIS. A deeper understanding of what the semantic content of the messages are, and what problems they are trying to solve, is more difficult and more valuable.

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

## DIS History

DIS arose from a Defense Advanced Research Agency (DARPA) project in the 1980's called SIMNET. At the time TCP/IP and high speed networks were just getting their legs, computers and networks were becoming powerful enough to do the computational operations needed, and 3D graphics was in its infancy. 

A screen capture from an early SIMNET application is shown below:

<img src="images/SimnetDisplay.jpg"/>

Each participant is in a simulator that controls one tank, and each simulator views the shared virutal battlefield. All the vehicles interact in the same shared enviroment. If one simulator causes the tank it controls to move, the other partipants see the movement, in real time. 

The simulators of the era sometimes had displays that replicated a soldier's view of the battlefield, but the host running the simulation wasn't networked with other hosts. Each simulator worked in isolation, and an aircraft simulator couldn't see a tank controlled by another simulator. The idea of SIMNET--quite advanced for the time--was to create a virtual, shared battlefield in which all participants on multiple computers could see and interact with each other. SIMNET's major accomplishment--it was arguably one of the first large real-time distirubted virtual world--was to serve as a basis for the research that allowed DIS to happen. 

DARPA projects were intended to transition out of the incubator research phase and into useful actual implementations. The SIMNET project worked out many of the state information exchange issues that were needed. Once that was done it needed to be standardized and refined outside of DARPA. The group that would eventually do this was Simulation Interoperability Standards Group (SISO) that took over development of the network protocol portion of the project, which they renamed to DIS. SISO developed DIS in a series of workshops held from 1989 to 1996. Once the protocol was developed they took the relevant documents to the IEEE standards group and achieved DIS standard approval.

In today's commercial game world games like "Call of Duty" or "World of Tanks" do shared environments between hosts routinely. The companies that own these games make a lot of money selling such applications to the public. At the time of SIMNET the concept of a shared, networked environment was revolutionary.

## Architecture Background

There are several parts to the concepts that go along with distributed (multiple host) simulations: networking, the semantics and format of the messages being exchanged, and graphics or operations that occur at each simulation.

### Graphics

To take the last topic first, the graphics portion of the shared virtual world is a subject unto itself because of the inherent complex nature of the topic. The art that portrays the shared environment may vary depending on the training objectives. In the commercial world, imagine the graphics of "Call of Duty" or other first person shooter entertainment games. Users who buy the games like good-looking and fast operating graphics. In the DoD world, sometimes the training objectives also require high quality and quick graphics operations. For example, some flight simulators that replicate ground attack operations. Some applications also rooted in the DoD can instead use 2D maps to portray a shared environment. The objective of the simulation in this case is to provide users with information about where vehicles and units are, rather than individual vehicle appearance. A map-based graphics simulator may also require position updates once every few seconds rather than several times per second.

The choices about what graphics to include in a DIS application depend entirely on the DoD's training objectives. An implementor may be able to use Google Maps or Open Street Maps, for example, or implement their own map-based requirements. Alternatively some applications can use 3D graphics in a manner reminiscent of modern commercial FPS games. There are many ways to draw the 3D images we see on the screen, from OpenGL and Direct3D to higher level scene graphs, such as OpenInventor or X3D. At an even higher level of abstraction objects can be rendered with the aid of a 3D game engine such as Lumberyard or Unity. A DIS application may have rudimentary 3D graphics instead of photorealistic 3D graphics, depending on the training use. Again, the audience being trained may benefit from high quality graphics, or still be well trained by a graphics system that is simple but effective in accomplishing the training objective.

Computer graphics is a large and complex subject, and instruction or examples often depend on the graphics standard chosen to describe the environment. We will discuss some graphics implementations for both for 2D maps and 3D applications. In some understandings, graphics use in simulations can be distinguished as being separate from DIS networking. The reality is that graphics are often used in simulations that use DIS, and from a practical standpoint a DIS tutorial has to at least mention how to use it.

### Networking, Formats, and Semantics

Before the distributed simulation application can be implemented there needed to be a way to exchange *state information* between simulators. State information includes data about a participant in the simulation that is transmitted to other simulation hosts. In the case of a tank, the state information includes its position, the direction the vehicle is facing, how fast it is moving, whether it is on fire, and subjects such as which way the turret is pointing. It's this state information and the format that it is exchanged in that DIS standardizes. Once the state information is exchanged the graphics components we just described above can be used to draw the scene that the users see. 

It is in the government's interest to have simulators interoperate with each other, in particular to prevent vendor lock-in. If the protocol for exchanging state information is owned by a company and that company can prevent simulator competitors from entering the market, or charge more to make their simulators interoperate with those from other companies. To be useful the DIS protocol had to be a *standard*, and an open one. Simply providing a language implementation that did the job without also specifying what was being exchanged was inadequate. So SISO refined the SIMNET network protocol and developed a formal description of it, then took it to the IEEE, where it was approved as an international standard (IEEE-1278.1). From that point on anyone could buy the IEEE standard document and then write their own implementation of the protocol.

As is inevitable with these things, the standard has to be maintained and updated in light of experience and new technology. From the late 80's until about 1995 the DARPA SIMNET protocol was used; this predated the adoption of DIS as an IEEE standard. The first major release of a standard DIS was DIS version 5, in 1995. It was updated with version 6, in 1998, when a few new network messages were added. Version 7 was adopted in 2012, and that version maintained an almost complete backwards compatiblity to the DIS version 5 of 1995. At the same time it added a few new PDUs (network messages) related to directed energy weapons and also clarified the semantics of protocol. SISO continues to support and update DIS in working groups, today in parallel with the HLA RPR-FOM. 

### Networking

Sending the messages defined by DIS involves using, almost always, the TCP/IP networking system. That's simply because TCP/IP has become so widespread. Once upon a time there were other software networking standards, such as DECnet, IBM Systems Network Architecture (SNA), Open Systems Interconnection (OSI), or AppleTalk. Those are simply not in use to much of an extent these days. In the case of DIS, can be exceptions to the use of TCP/IP in some radio applications, but this is somewhat rare.

Using TCP/IP to send DIS messages is not terribly bad. It is simple enough to use TCP, UDP, broadcast, and multicast. For the most part in this document the objective is to be as simple as possible when discussing the subject. Network programming is intended to stay at the highest levels possible, excluding, to the extent possible, such topics as the IP or lower levels.

## Simulation Terminology

There's a question of what to call applications similar to those described above, and academics love to have arguments about terminology. "Virtual world" or "virtual environment" were the early names for the class of application. A virtual world aims for a replication of a real world combined with a sense of immersion, and that requires high fidelity and responsive graphics. Developers can integrate other human senses into the virtual world application, such as haptics (touch), audio, or even smell to increase the feeling of presence.

Some of the early implementations ran on a single, large computer that had several graphical displays attached to it, while other implementations ran on multiple computers connected by a network. "Networked Virtual Environment (NVE) is a more useful description of the applications that run on multiple hosts compared to those that run on a single host.

First person shooter commercial games use essentially the same technoloy as the NVEs used by the military, and must deal with the same implementation issues that we will discuss later. The primary difference between military simulation NVEs and commercial games is the application's use, not the technology. Military simulations are intended for training and analysis, while games are written to entertain customers. Even if the technology is fundamentally the same, a game used in military training can result in a bad outcome for the users--for example, by making a user think that he will be invulnerable to rifle fire if he ducks behind a sheetrock wall. That behavior may be fun in a game, but it doesn't reflect reality and trains the military to do dangerous things.

The size of gaming/entertainment industry dwarfs that of the military simulation industry, and the games they sell are often more visually polished. A single top level game title may cost hundreds of millions to develop and market. The business models of the entertainment industry are different from those of the defense industry. The product life cycle of a game may be only a few years, while a military simulation may be in use for decades. What's more, an entertainment game developer is usually not interested in a standard network protocol. They consider vendor lock-in a feature, not a bug.

Both commercial games and some military simulation applications used for training may share theoretical names such as "first person shooter." But they have different goals.

## Other Uses

DIS was originally intended for virtual and visually-based environments. But existence of a network protocol for exchanging state information was discovered to be useful in other ways, too. At its root, DIS describes the position of things in the world, and that capability can be used in applications other than NVEs. If we subtract the graphics element of the application we're left with a data feed that includes a description of the dynamic state of a battlefield. We can use this information for a variety of purposes, many of them analytical. 

One possible application is to simply archive all the entity position reports. This lets analysts examine at some later period what happened in a simulation, or even what happened in a live exercise. A live training operation may involve every vehicle sending a DIS update when a vehicle moves. If this information is archived, the analyst can use the data later to evaluate user actions.

Constructive simulations can control entities with Artificial Intelligence (AI), whether it be simple or complex, and those entities can use DIS to publish their positions. Applications can use this to create brigade, division, or even corps-sized simulated units that manuever on the battlefield. 

DIS has the potential to work in interoperations with the commercial world as well. Augmented reality is an emerging technology and has received enormous investments from technology companies such as Microsoft, Google, and Facebook. It's probable that augmented reality applications will receive updates from constructive simulations running on mobile devices. Augmented reality goggles worn by a soldier may receive constructive (imaginary) entity updates in DIS format and display them to the user.

DIS is frequently used as "glue" or act as a "shim" to enable applications that use HLA or TENA to talk to each other. HLA has virtues, but interoperablity between HLA applications is a challenge. It's often easier to get two HLA applications that are RPR-FOM variants to talk to each other using DIS rather than directly over HLA. 

## Parting Thoughts

Given the technology of the era, the architects of DIS were visionary. Even decades after it was developed and standardized it still holds up quite well. The research it prompted was trailblazing, and served as the starting point for many military simulations and then entertainment industry game applications. The ideas worked out in DIS are still widely used today.

## Further Reading

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

