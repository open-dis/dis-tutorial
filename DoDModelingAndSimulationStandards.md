#Department of Defense Modeling and Simlation Standards

There are three major network standards in DoD modeling and simulation: Distributed Interactive Simulation (DIS), High Level Architecture (HLA) and Test and Training Enabling Architecture (TENA). Each has evolved to serve different niches in M&S. While this document focuses on explaining DIS, the reader should also understand the place of DIS in  the DOD modeling and simulation world.

Distributed simulations are, ultimately, exchanging state information, usually about *entities*--vehicles, persons, ships, or aircraft. If a simulation wants to display a tank from another simulation it needs to know something about that tank--its position, which direction it's facing, how fast it's traveling, and other information. The data needs to be sent across the network from one host to any other hosts that may need to know about the tank. DIS, HLA, and TENA have solved this problem in different ways.

## DIS

DIS was the original standard for modeling and simulation. It consists of 

* A set of standardized messages for exchanging state information
* Agreements about semantics. This includes what coordinate system to use, units of measurement, and enumerated values that provide a compact way to describe agreed-upon meaning
* Standard agreements for handling information, entity discovery, and other procedures

There are dozens of DIS messages, called Protocol Data Units (PDUs). Each PDU exactly describes the position and format of data in the message. For example, one PDU, called the entity state PDU, transmits the position of an entity, along with other information. The entity's position is 48 bytes from the start of the PDU, and consists of three double precision floating point numbers for the X, Y, and Z values. A simulation that wants to transmit the position of an entity needs to construct the entity state PDU message in exactly the format specified by the standard. 

What's implicit in this message is that both the sender and receiver are using the same coordinate system, and the same units of measurement. These agreements about the semantics of those three floating point numbers are specified by the standard as well.

Not all message exchanges consist of simple state updates. For example simulating shooting requires that multiple messages be exchanged between the shooter and target. The sequence in which the messages must be exchanged to accomplish this are also specified by the DIS standard.

Many simulations using DIS only partially implement the standard. If a simulation makes no use of electromagnetic warfare PDUs then many applications will simply not implement them. This means that they will be deaf to any of these PDUs sent by other simulations.

##HLA

DIS was intended to address a particular problem domain: real-time virtual environments. However the DoD has broader simulation problems to solve that DIS can't address. The M&S leadership wanted a single standard that could be used across a wider range of simulation applications. As a result, starting in 1995, the DoD started the process of creating a new standard for modeling and simulation, an effort which eventually evolved into the HLA standard.

HLA brings a broader set of tools that can be applied to M&S applications. DIS works in real time, AKA wall clock time. This works well for DIS simulations, where it is usually expected that there will be humans in the simulation loop, and a simulation should move no faster or slower than what a human would experience in real time. But some simulations may need to diverge from real time. HLA may optionally make use of a simulation clock that can differ from real time. Also, the DIS PDUs define a collection of state information. In addition state information not included in the DIS standard is more difficult to exchange. HLA applications can specify the  state information that the interoperating applications exchange. 

While DIS specifies the format of data on the wire, HLA is an API standard. The standard specifies a set of function calls that simulations can use, along with a set of ten "HLA rules" that compliant applications must follow. The state information to be exchanged is outside of the standard and defined by each application in something called a "Federation Object Model" (FOM).  For two simulations to interact they must share a FOM. 

There has been some work done to standardize FOMs, most notably in the Real-Time Reference Platform FOM (RPR-FOM). When HLA was first introduced there was already a large installed base of distributed virtual simulations. To make the planned transition to HLA easier, RPR-FOM replicated much of the semantics of DIS. The same coordinate system was used, and the same semantics for identifying entities, dead reckoning algorithms, and more. DIS had already worked out the major issues involved, and re-inventing the wheel did not make sense. A firm understanding of DIS semantics will go far in helping you work with HLA RPR-FOM applications. 

The interface that programmers use to interact with HLA is called the RTI (Run-Time Infrastructure). Simulation authors can choose to buy an RTI to use for their application or use a free and open source RTI. The Modeling and Simulation Coordination Office (MSCO) maintains a suite of tests that can be applied to RTIs that can flag any noncompliance with the standard, so some RTIs are certified. 

While HLA standardizes the API, the standard is silent about the format of messages exchanged between host RTIs on the network. An RTI implementor can choose to use any format he likes.  This means that two simulations, both using HLA, and both using RPR-FOM, but using RTIs from different vendors cannot directly communicate with each other because they are using different network message formats. The thinking is that HLA, because it has a standard API, makes it easy to switch between RTI vendors, so a standard wire format was less important. This also allows RTI vendors to innovate under the API with a number of technologies.

The HLA standard has gone through a number of revisions over the years. The first published standard, from the Defense Modeling and Simulation Office, was made available in 1998 has HLA 1.3. Subsequent versions were promulgated through SISO and, eventually, IEEE. The first IEEE-promulgated standard was IEEE-1516. HLA was adopted by NATO as STANAG-4603. HLA was further updated in 2010 in an updated IEEE standard, IEEE-1516-2010. As of this writing this is the latest version.

## TENA

TENA was developed to serve the needs of the live range community. DIS uses a fixed set of messages to exchange state information. HLA uses an API. TENA adopted a remote objects architecture. While DIS and HLA can exchange state information, TENA adds the ability to reuse code.

Users of Common Object Request Broker Architecture (CORBA) will be immediately at home in TENA. The basic concept is that developers write classic language objects, as seen in C++ or Java. These objects can be published by applications and accessed remotely via *proxies*, or stand-ins for the actual object. 

Suppose we have an object representing a tank in one participating simulation. Other simulation participants can call methods in that object, called *servant*, via a proxy on their own host. The proxy has the same interface as the servant--the set of publicly accessible methods--as the object on the original simulation. When a local application calls a method in the proxy, perhaps including some arguments with the method call, the proxy does no actual computation itself. Instead it packages up the method call, including any arguments, and sends it across the network to the host with the servant. That host runs the code in the servant object's method, then returns the result to the calling proxy. 

From the standpoint of the caller, it looks as if the user is directly calling a method on an object residing on another host.

HLA and DIS pass state information between cooperating hosts. TENA provides the ability to access code running on remote hosts as well. It can be programmer-friendly as well. Most coders are familiar with the idea of calling methods, and TENA and CORBA make that work in a familiar environment. 

TENA also provides a repository of reusable TENA objects at its web site.

TENA has not been approved by a standards organization, and the current implementation is not open source. TENA is organized by the United States Office of the Secretary of Defense Test Resource Management Center (TRMC). The TENA Middleware, which implments the basic plumbing of TENA, is freely available for download from the TENA-sda.org site with a login. Free (though not necessarily standardized or open source) software was important to the range community. It was felt that licences and the problems inherent with keeping them current did not work well with the very long and often convoluted product life cycles seen in the DoD range environment. TENA sidestepped the license problem by simply giving away the software.

## What is Standardized?

The three main DoD M&S networking standards decided to focus on different places in the software stack to enforce standard behavior.

DIS choose to standardize the format of messages on the wire, and not the API. This makes it easier for implementations from different vendors to work together. The tradeoff is that vendors can, and do, use any API they like to create those messages. The drawback is that changing from one DIS vendor to another can be traumatic. Every piece of code that touches the DIS library API has to be changed to meet the  API of the new vendor.

HLA choose to standardize the HLA API, but not to standardize the format of messages on the wire. This makes getting simulations using different RTI vendors to exchange messages hard, but changing vendors easy, at least in theory. Considerable work was done with HLA to make using a new RTI vendor as easy as swapping in a new DLL. The reality can be a little grimmer. Simulations with that significant of a change may need to be re-certified to ensure that no unexpected changes crop up. There's another axis of incompatibility in the version of HLA being used--HLA 1.3 and IEEE-1516-2010 use somewhat different APIs. Finally, the simulations may be incompatible at the FOM level. Simply saying that two simulations both use HLA does not mean they are compatible.

Finally, TENA also implemented an API standard, and remained silent on the wire format for exchanging messages. It is none of the programmers business what goes on below the API level, and they should have no knowlege of what the wire format is. The situation is not quite as bad as HLA, however, since there is only one offical vendor of the HLA middleware. The wire format problem was sidestepped by limiting the number of vendors to one.

## Comparision of Standards

So, which to use? It depends.

DIS standardizes the format of messages on the wire. Any mechanism that creates messages in the desired format is fair game. In contrast HLA is an API standard. That means that the standard is language-specific. There are HLA APIs specified for C++ and Java, and for FORTRAN and ADA in HLA 1.3. If you want to use another language there's no official option. 

In the last decade scripting languages like Python and Javascript have become quite popular, either for writing applications in their own right or because they can act as "glue" for making applications work together. Javascript in particular has become near-universal in web based environments, and Python has been used as a server-side "glue" language to connect applications. HLA's status as a language API is a handicap if you want to use scripting technology. Using DIS with Javascript in web applications, usually combined with websockets or WebRTC is very appealling. 3D standards such as WebGL enable 3D graphics in the web browser. There is a wealth of information to "mash-up" on the web, including maps and georeferenced data.

Notice that while DIS specifies the format of messages on the network, HLA does not. HLA is an API specification, and those that implement HLA can pick any format for messages on the wire that they like. This means that RTIs from different vendors cannot directly communicate with each other--their wire formats are mutually incomprehensible to each other. The lack of a standard format for information on the network wire was, and is still, a controversial design choice. Getting two simulations to communicate requires either that all participants agree on an RTI from a single vendor, or that some sort of a gateway/bridge be used to connect the different RTI vendors.  There has also been some drift between FOMs. Not all deployed simulations use the bare RPR-FOM, and have instead added extra information to the RPR-FOM. This can make it difficult for several simulations to work together within an HLA context. Simulations using two RTI vendors may be a somewhat easy to solve integration problem if we make the optimistic assumption that they are using identical FOMs. In theory the users can simply drop in a new RTI and it will all work. The reality is often different. Changing to a new RTI may require extensive re-certification of the simulation to ensure no significant changes actually occurred.  

Many HLA simulations use variants of RPR-FOM, which was based on DIS, and there are several gateways that translate from RPR-FOM to DIS. For these reasons and others it is fairly common to connect HLA simulations /federations together using DIS.  Rather than trying to make the HLA simulations talk directly over HLA, the simulations translate to a common format--DIS--and then use that as a communications backbone. This sidesteps several issues, including the RTI version problem, the slightly incompatible FOM problem, and the vendor-specific network message format problem. Usually no source code changes or recompilation of the HLA application needs to be done. A drawback is that the DIS communications backbone may carry less semantic information than any particular HLA simulation's FOM.

If you need a simulation that uses a clock that runs at something other than real time, HLA is your choice. Neither DIS nor TENA have simulation time that runs in non-realtime. HLA also includes distributed data management (DDM). DDM reduces traffic to simulation participants that are not interested in it. For example, an Burke-class destroyer doing anti-air operations may not be interested in position updates from a dismounted infantry entity armed only with an AK-47 who is 20 miles inland. HLA includes features that can eliminate sending this traffic to the Burke destroyer.

TENA is often used in a range environment. It has considerable technical merits, but outside of a range environment it's a tough sell. DIS and HLA have much larger installed bases in the simulation domain. 

## Further Reading

**HLA Tutorial from Pitch:** <a href="http://www.pitchtechnologies.com/hlatutorial/">http://www.pitchtechnologies.com/hlatutorial/</a><br>

**The TENA organization site, where users can register for a free download of the TENA middleware, and find more tutorials:** <a href="http://tena-sda.org">http://tena-sda.org</a><br>

**Python as a Glue Language:** <a href="https://www.python.org/doc/essays/omg-darpa-mcc-position/">href="https://www.python.org/doc/essays/omg-darpa-mcc-position/</a><br>

**Combat Modeling** <a href="https://www.amazon.com/Engineering-Principles-Modeling-Distributed-Simulation/dp/0470874295/ref=asap_bc?ie=UTF8">Andreas Tolk's book on combat modeling</a>

**Networked Graphics** <a href="https://www.amazon.com/Networked-Graphics-Building-Virtual-Environments/dp/0123744237/ref=sr_1_sc_2?s=books&ie=UTF8&qid=1485502973&sr=1-2-spell&keywords=networked+virutal+environments"> Steed & Olivera's book on networked virtual environments</a>.

**DIS/RPR-FOM Protocol support group at SISO:** <a href="https://www.sisostds.org/StandardsActivities/SupportGroups/DISRPRFOMPSG.aspx">https://www.sisostds.org/StandardsActivities/SupportGroups/DISRPRFOMPSG.aspx</a><br>

**Discussion of the 2015 IITSEC "Blended Warrior" exercise, which tied together 40-some simulations on the show floor.** <a href="http://www.iitsecdocs.com/">http://www.iitsecdocs.com/</a>, search for paper titled "Washington, We Have a Problem."


