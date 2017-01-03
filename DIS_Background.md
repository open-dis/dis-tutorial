#The Missing Handbook
## DIS Background

Distributed Interactive Simulation (DIS) is one of the three main standards for exachanging state information in military simulations. Despite its widespread use, much of the background information about DIS is scattered across many documents at many locations, or is the result of experience and lore on the part of practioners. People using DIS can read the standard itself, available as IEEE-1278.1, but the standard aims for precision rather than providing a broad and understandable overview. Obatining the standard from IEEE also costs a modest sum, and getting a purchase order through the bureaucracy is an annoying hurdle for the typical target audience of this handbook. Lore or folk understanding of DIS implementations in working simulations is notoriously difficult to capture. One has to find the right person with the right knowledge, and he has to be available and willing to answer questions. 

There's no centralized place to learn about DIS and how to use it in applications. This document is intended to be an open source and community maintained introduction to the theory and practice of DIS. 

Often people who find they need to learn something about DIS are programmers who are thrown head-first into the problem. They're given some vague instructions, usually summed up as "Hey, we need to implement DIS in our application. Go make it work." The programmers sometimes don't have experience with simulation or virutal worlds. They're often working on the project for a few weeks before moving on to something else. They're OK with coding, but using DIS involves hidden assumptions about the problem domain. For example, one would think that it is easy to direct an object in a virtual world to move one meter north. But what coordinate system is being used? Are SI or Imperial units being used in that coordinate system? How does one uniquely identify the object to be moved so that it and it alone moves? All these hidden assumptions can take a programmer days to unravel.

Another audience for this document is military personnel or support people charged with making existing DIS simulations work. They usually have good understanding of the basics of networking and software installation, but the problem domain of military simulation virutal worlds is large, complex, and poorly documented. They're often subject experts in the military aspects of the simulation, but not the nuts and bolts of how it works. One would like to think that they can work at a high level of abstraction and leave the details to the programmers, but that's often not the case. A basic understanding of how things are done in DIS is often a great help in communicating with programmers. 

Those working in HLA or TENA also can benefit from this document. The HLA Realtime Reference Platform Federation Object Model (RPR-FOM) used many of the concepts from DIS, and TENA often uses aspects of DIS as well.

Studying the standard in isolation can be confusing if the reader has no familiarity with the problems DIS is trying to solve.  For all the reasons discussed above this document also includes a brief overview of distributed simulations, and some of the problems faced when implementing them. So, as an aid to the audiences mentioned above, some background information on distributed simulations and virtual worlds is also included. If you already know all this, you can safely skip it. But for most programmers and administrators it provides the context for features or data that may seem mysterious at first. 

DIS consists of a few dozen standardized network messages exchanged between simulations. Understanding what these messages are and how to create them is the easy part of using DIS. There is a host of other information that goes along with the message formats.

If you just want to sling some code and skip all the throat-clearing, you can start reading the "Protocol Data Units: Exchanging State Information" section. 

DIS standardizes the format of network packets, and has no formal API. What matters is the format of packets on the wire; the implementation of the code that puts them into that format is up to the user. This means that if you compare implementations from two different DIS vendoer libraries the code will look very different. The examples in this document rely primarily on the open-dis project, available at https://github.org/open-dis. The open-dis project has DIS library implementations in Java, C++, Javascript, Python, C#, and Objective-C, along with sample applications. There are other implementations out there, both open source and commercial. There are also many home-grown implementations of the standard.

##History

DIS arose from a Defense Advanced Research Agency (DARPA) project in the 1980's called SIMNET. At the time TCP/IP and high speed networks were just getting their legs, computers were becoming powerful enough to do the compuation, and 3D graphics was in its infancy. Individual simulators of the era sometimes had displays that replicated a soldier's view of the battlefield, but they weren't networked with each other. Each simulator worked in isolation. An aircraft simulator couldn't see a tank controlled by another simulator. The idea of SIMNET, quite advanced for the time, was to create a virtual, shared battlefield. SIMNET's major advance--it was arguably the first large real-time distirubted virtual world--was to create the research and enviroment that allowed this to happen. 

A screen capture from an early SIMNET application is shown below:

<img src="images/SimnetDisplay.jpg"/>

Each participant is in a simulator that controls one tank, and each tank views the shared virutal battlefield. All the vehicles interact in the same shared enviroment. If one simulator causes a tank to move, the other partipants see that tank move, in real time, in the shared environment. Networked first person shooter games like Call of Duty do this routinely today, but at the time the concept was revolutionary.

The graphics portion of the shared virutal world is a subject unto itself. We will be essentially ignoring the graphics portion of virtual worlds, and focusing on what the network is doing. 

Before the application could be implemented there needed to be a way to exchange *state information* between simulators. State information is data about one participant in the simulation. In the case of a tank, the state information may include it's position, the direction it's facing, how fast it's moving, whether it's on fire, and which way the turret is facing. It's this state information, and the format that it is exchanged in, that DIS standardizes.

DARPA projects are intended to transition out of the incubator research phase and into useful implementations that add value to the military. SIMNET worked out many off the issues involved in implementing a real-time virtual environment, but it needed to be implemented outside of the purview of DARPA. The group that would eventually become the Simulation Interoperability Standards Group (SISO) took over development of the network protocol portion of the project, renamed DIS, in a series of workshops held from 1989 to 1996. 

It was in the government's interest to have simulators interoperate with each other, and to avoid vendor lock-in. To be useful the DIS protocol had to be a *standard*. Simply providing a language implementation that did the job without also specifying what was being exchanged was inadequate. So SISO refined the SIMNET network protocol and developed a formal description of it, then took it to the IEEE, where it was approved as an international standard (IEEE-1278.1). From that point on anyone could buy the IEEE standard and write their own implementation. 

As is inevitable with these things, the standard has to be maintained and updated in light of experience and new technology. The first major release of a standard DIS was DIS version 5, in 1995. It has since been updated with version 6, in 1998, and version 7, in 2012. The text of the version 7 standard clarified a number of ambiguities in interpreting the standard. Some new messages have been added over the years, including those that support directed energy weapons. SISO continues to support and update DIS in working groups.

## Further Reading

**Simulation Interoperabilty Standards Organization (SISO):** http://sisostds.org/<br>
**The IEEE DIS Standard, 1998 (Version 6):** https://standards.ieee.org/findstds/standard/1278.1a-1998.html<br>
**DIS Wikipedia:** https://en.wikipedia.org/wiki/Distributed_Interactive_Simulation<br>
**DIS Plain and Simple, another document that provides information about DIS:** https://www.sisostds.org/DigitalLibrary.aspx?Command=Core_Download&EntryId=29302<br>
**SIMNET wikipedia:** https://en.wikipedia.org/wiki/SIMNET<br>
**SIMNET History:** http://www.iitsec.org/about/awardsandrecognition/Documents/2015_FellowPaper_Miller.pdf<br>
**Still More SIMNET History:** http://www.dtic.mil/dtic/tr/fulltext/u2/a294786.pdf<br>
**A whole website devoted to SIMNET history:** http://simnet-history.org/<br>