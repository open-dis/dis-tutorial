# Department of Defense Modeling and Simulation Standards

There are three major network standards in DoD modeling and simulation: Distributed Interactive Simulation (DIS), High Level Architecture (HLA) and Test and Training Enabling Architecture (TENA). Each has evolved to serve different niches in Modeling and Simulation (M&S). While this document focuses on explaining DIS, the reader should also understand the overall role DIS and the other standards play in the DoD M&S world.

Ultimately distributed simulations are exchanging state information, often about *entities*--vehicles, persons, ships, or aircraft. If a simulation wants to display a tank from another simulation it needs to know something about that tank--its position, which direction it's facing, how fast it's traveling, and other information. The data needs to be sent across the network from one host to any other hosts that may need to know about the tank. The receiving host must know how to decode the message, called the message's *syntax* and must also know what the meaning of the data in the message is, called the *semantics*. The syntax may specify that so many bytes into the data sent across the network there are three floating point numbers. If we know the syntax, we can retrieve and decode those numbers. But the semantics of those numbers are a trickier business. Do they describe a position in the world? An entity's orientation? The direction in which a tank's turret is pointing? Participating hosts must know both how to decode messages and what the contents of the message mean.

DIS, TENA, and HLA can be used in roles other than describing the position of entities in the world. DIS can be used to carry voice data, which allows simulated radio traffic can be passed over the network. All three protocols can be used to describe other phenomena,  such as electromagnetic emissions, but most classical military training applications are focused on describing the position of things in the world and their interactions. 

## DIS

DIS was the original standard for modeling and simulation. It consists of 

* A set of standardized messages for exchanging state information
* Agreements about semantics. This includes what coordinate system to use, units of measurement, and enumerated values that provide a compact way to describe agreed-upon meaning
* Agreements for handling information, the sequence in which messages are exchanged, discovery of simulation entities as they appear, and other procedures

There are dozens of individual DIS messages, called Protocol Data Units (PDUs). Each PDU exactly describes the position and format of data in the message. For example, one PDU, called the Entity State PDU (ESPDU), transmits the position and orientation of an entity, along with other information. The entity's position is 48 bytes from the start of the PDU, and consists of three double precision floating point numbers for the X, Y, and Z values. A simulation that wants to transmit the position of an entity needs to construct the entity state PDU message in exactly the format specified by the standard. This part of the problem relates to the message's syntax.

The host that receives the message can decode the ESPDU according to the agreed-upon syntax and get three double precision floating point numbers, but if the message is to be made use of both the sender and receiver should understand the coordinate system and the same units of measurement used in the message. Are the three floating point numbers a latitude, longitude, and altitude? Are the latitude and longitude in decimal degrees or decimal radians? Or are the floating point numbers Military Grid Reference System (MGRS) coordinates and an altitude? Is the altitude in meters or feet? Is the altitude measured from sea level or ground level? Agreements about the semantics of the three floating point numbers are specified by the DIS standard, but not in the contents message being transmitted. It is assumed that the floating point numbers in the message are using the coordinate systems and units specified by the standard.

Not all message exchanges consist of simple and atomic state updates. Simulating a shooting event in DIS requires that multiple messages be transmitted about the shooter, target, and the munition being fired. The sequence in which the messages must be exchanged is also specified by the DIS standard.

Many simulations using DIS only partially implement the full DIS standard. If a simulation makes no use of electromagnetic warfare PDUs then the implementation of DIS used in that application may well not implement them. This means that they will be deaf to any of the PDUs with information about electromagnetic operations that were sent by other simulation participants--if the application receives a PDU that describes an electromagnetic happening it may simply ignore the PDU.

### What Does DIS Standardize?

What DIS standardizes is straightforward: the format of PDUs, the semantics of their contents, and how they are exchanged. This is a popular way to standardize network traffic and was used in the 80's and 90's for the many Internet Engineering Task Force (IETF) Requests for Comment (RFCs) that form the backbone of the internet today. The Domain Name Service (DNS) protocol, the HTTP protocol, and the TCP protocol are defined in similar ways. As we'll see, HLA and TENA made different choices about how to standardize their protocols.

### Versions of DIS

DIS has been through several revisions. The proto-DIS version was SIMNET, a DARPA research project from prior to the standardization of DIS. In 1995 the SIMNET protocol was updated and standardized with a major standards group, IEEE, as DIS version 5. The standards approval process is painstaking and painful. The desired outcome is for two or more different programmers to read the standard and write completely interoperable implementations despite not communicating with each other. This is a tall order--getting all the syntax and semantics agreed upon is difficult, and requires very specific and detailed descriptions in the standards document.

In 1998 the DIS standard was updated in a forward-compatible way to version 6. The 1998 standard added a few new PDUs and clarified some semantics, so that DIS version 5 traffic can mostly be handled by DIS version 6 implementations. The reverse is not necessarily true--if a DIS 6 application sends messages to a DIS version 5 application then it is possible to send messages that will not be recognized. DIS version 6 is probably the most widely used version of the DIS protocol.

In 2012 version 7 of DIS was approved. The standard's descriptive text was expanded to clarify the semantic meaning of messages, and a few new PDUs were added, primarily related to directed energy weapons. Version 7 of DIS is again mostly backward-compatible with earlier versions.

DIS can be broadly classified into generations. Generation 1, from before DIS was standardized, can be thought of as SIMNET messages. Generation 2 covers the IEEE-standardized DIS versions 5, 6, and 7. Generation 2 is not compatible with the syntax and semantics of generation 1. Work on DIS continues. DIS version 8 is being mooted as this is written. It may well choose to break backwards binary compatibility in order to take advantage of new features, in which case it could be described as generation 3.

Generation 1 applications are almost entirely dead and gone. (Though you never know about these things. Some bozo has doubtless backed up an application from 1991 on his 5-1/4" floppy disk and will start sending PDUs on your network using his PC-XT without your knowledge.) Generation 2 applications predominate, mostly DIS version 6.

While generation 3 applications (the mooted DIS version 8 and beyond) may not be binary-compatible, any realistic implementation will be able to operate with the aid of gateways or bridges that act as translators. The gateway would receive a DIS version 6 PDU and translate it to DIS version 8 format.

## HLA

DIS was intended to address a particular problem domain: real time virtual environments that describe the position, orientation, and movement of entities in a 3D world. But the DoD has other simulation problem domains not addressed by DIS.  After the success of DIS, the DoD M&S simulation leadership decided to create the One True Simulation Standard that would work in both the problem domain addressed by DIS and at the same time be applicable to a wider collection of simulations. That standard is called High Level Architecture (HLA).  

DIS has (for the most part) a fixed set of messages. The format of all the messages exchanged is defined in the standard, and because DIS was designed for real time virtual simulations the fields that address that problem are what are in the messages. If you wanted to do something else--perhaps write a simulation about missile repair logistics, or a simulation of rail system traffic throughput--DIS is a bad choice, because the semantics of the information contained in the pre-defined messages doesn't match up well with the problem to be simulated. 

HLA moves the content of the messages exchanged out of the standard and into a configuration file that is loaded at runtime. While the DIS standard defines what the content of the messages are, HLA allows the message contents to be defined by the simulation developer. This configuration document--the definition of the messages to be exchanged--is called the Federation Object Model, or the FOM.

The military has many simulations that do not run in real time--they may run faster or slower than real time, AKA wall clock time. DIS applications are assumed to run in wall clock time, at the same speed at which humans perceive time.  That means a simulation of the logistics throughput of a railway network would be very boring. Users would watch months of rail system traffic at the same speed as trains run. In contrast HLA can optionally make use of a simulation clock that differs from wall clock time, either faster or slower. It can also advance time in an event-oriented way, similar to discrete event simulation. 

### What is Standardized in HLA? 

The features that DIS and HLA standardize are different. While DIS specifies the format and semantics of data on the wire, HLA is an API standard. HLA specifies a set of function calls that simulations can use in conjunction with the developer-defined FOM to exchange messages. An HLA simulation must also comply with a set "HLA rules" that all HLA applications must follow. 

If two HLA simulation participants ("federates") are to exchange data they must share a FOM (or if you want to be picky some subset of the FOM.) Without this the simulation participants don't have agreed-upon semantics about the data being exchanged.

There has been work done to standardize FOMs, most notably in the Real-Time Reference Platform FOM (RPR-FOM). When HLA was first introduced there was already a large installed base of DIS simulations. To make the planned transition to HLA easier, RPR-FOM replicated many of the semantics and even syntax of DIS. The same coordinate system was used, and the same semantics for identifying entities, the same dead reckoning algorithms, and more. DIS had already worked out solutions to the major problems encountered in distributed virtual environments, and re-inventing the wheel did not make sense. If an existing application using DIS was to be ported to the HLA standard to exchange data instead, it made sense to use many of the same DIS concepts in RPR-FOM.  The HLA RPR-FOM standard reused concepts that had already been painfully discovered by DIS, and this made a transition to HLA by existing applications easier. Because of this a firm understanding of DIS semantics will go far in helping you work with HLA RPR-FOM applications. 

The application programming interface that programmers use to interact with HLA is called the RTI (Run-Time Infrastructure). Simulation authors can choose to buy an RTI implementation to use for their application, or use a free and open source RTI. The Modeling and Simulation Coordination Office (MSCO) maintains a suite of tests that can be applied to RTIs that can flag any noncompliance, so some RTIs are certified compliant. 

While HLA standardizes the API, the standard is silent about the format of messages exchanged between host RTIs on the network. An RTI implementer can choose to use any format he likes.  This means that two simulations, both using HLA, and both using RPR-FOM, but using RTIs from different vendors cannot directly communicate with each other. They are using different network message formats that contain the same information, ultimately, but are in completely different formats. There is no attempt to standardize the syntax of HLA messages on the wire. The thinking is that because HLA has a standard API HLA this makes it easy to switch between RTI vendors, so a standard wire format was less important. This also allows RTI vendors to innovate under the API with a number of technologies and formats, and compete with each others on a basis of performance.

### Versions

The HLA standard has gone through a number of revisions over the years. The first published standard, from the Defense Modeling and Simulation Office, was made available in 1998 as HLA 1.3. Subsequent versions were promulgated through SISO and, eventually, IEEE. The first IEEE-promulgated standard was IEEE-1516. HLA was adopted by NATO as STANAG-4603. HLA was further updated in 2010 in an updated IEEE standard, IEEE-1516-2010. As of this writing this is the latest version.

## TENA

TENA was developed to serve the needs of the live range community. DIS uses a fixed set of messages to exchange state information, and HLA uses an API, while TENA adopted a remote objects architecture. While DIS and HLA can exchange state information, TENA adds the ability to reuse code.

Users of Common Object Request Broker Architecture (CORBA) will be immediately at home in TENA. The basic concept is that developers write classic language objects, such as those seen in C++ or Java. These objects can be published by applications and accessed remotely via *proxies*, or stand-ins for the actual object. 

Suppose we have an object representing a tank in one participating simulation. That simulation publishes the tank object instance. Other simulation participants can call methods in that object instance, called a *servant*, via a proxy on their own host. The proxy has the same interface as the servant--the set of publicly accessible methods--as the object on the original simulation. When a local application calls a method in the proxy, perhaps including some arguments with the method call, the proxy does no actual computation itself. Instead it packages up the method call, including any arguments, and sends it across the network to the host with the servant. That host runs the code in the servant object's method, then returns the result to the calling proxy. 

From the standpoint of the caller, it looks as if the user is directly calling a method on an object residing on another host.

HLA and DIS pass state information between cooperating hosts. TENA does this as well, for example by using method arguments in a method call, or by causing object state information to be automatically published to interested participants. It provides the ability to run code associated with an object on a remote host as well.  Most coders are familiar with the paradigm of calling methods on objects, and TENA (and CORBA) make that work in what seems to the programmer a familiar and straightforward way.

TENA also provides a repository of reusable TENA objects at its web site.

TENA has not been approved by a standards organization, and the current implementation is not open source. TENA is organized by the United States Office of the Secretary of Defense Test Resource Management Center (TRMC) and a steering committee controls features added to TENA and the development of TENA. The TENA Middleware, which implements the basic plumbing of TENA, is freely available for download from the TENA-sda.org site with a login. Software that is free though not necessarily standardized or open source software is important to the range community. It was felt that licenses and the problems inherent with keeping them current did not work well with the very long and often convoluted product life cycles seen in the DoD range environment. TENA sidestepped the license problem by simply giving away the software.

## What Does Each Standardize?

The three main DoD M&S networking standards decided to focus on different places in the software stack to enforce standards.

DIS choose to standardize the format of messages on the wire, and not the API. This makes it easier for implementations from different vendors to work together. Any network message that conforms to the standard can be read and decoded by whatever software the developer likes. The tradeoff is that vendors can, and do, use any API they like to create those messages. This means changing from one DIS vendor to another can be traumatic. Every piece of the simulation that touches the code responsible for handling DIS  has to be changed to conform to the  API of the new vendor. See figure x.

HLA choose to standardize the HLA API, but not to standardize the format of messages on the wire. This makes changing HLA vendors within a single simulation application easy, at least in theory. Because every vendor of an HLA RTI must implement that same API, they are in principle interchangeable. Considerable work was done with the HLA standard to make using a new RTI vendor as easy as swapping in the DLL of a different vendor. Once the new DLL is in place the simulation can be re-run without recompilation.

See figure y.

The reality can be a little grimmer. Simulations with that significant of a change may need to be re-certified to ensure that no unexpected changes crop up. There's also another axis of incompatibility in the version of HLA being used--HLA 1.3 and IEEE-1516-2010 use somewhat different APIs, as do different versions of HLA. 

Simulations that you wish to interoperate may also be incompatible at the FOM level. Simply saying that two simulations both use HLA does not mean they are compatible. They must also share a FOM, which defines the data that is exchanged.

Remember how DIS defined the format of messages on the wire, while HLA did not? This creates a significant problem for interoperability. Because there is no standard for message formats the messages sent by different HLA vendors are unrecognizable to each other. What is standardized is the API, not the message format.

Finally, TENA also implemented an API standard, and remained silent on the wire format for exchanging messages. It is none of the programmers business what goes on below the API level, and they should have no knowledge of what the wire format is. The situation is not quite as bad as HLA, however, since there is only one official vendor of the HLA middleware. The wire format problem was sidestepped by limiting the number of vendors to one.

See figure z.

## Comparison of Standards

So, which to use? It depends.

DIS standardizes the format of messages on the wire. Any mechanism that creates messages in the desired format is fair game. In contrast HLA is an API standard. That implies that the standard is language-specific, because APIs are also language-specific. There are HLA APIs specified for C++ and Java, and for FORTRAN and ADA in HLA 1.3. If you want to use another language there's no official option, though in some cases a language wrapper could be written around one of the approved APIs. 

In the last decade scripting languages like Python and Javascript have become quite popular, either for writing applications in their own right or because they can act as "glue" or shims for helping applications work together. Javascript in particular has become near-universal in web based environments and "mash-ups" are popular on the web. Python has been used as a server-side glue language to connect applications. HLA's status as a language API is a handicap if you want to use scripting technology because there are not necessarily any scripting language APIs for HLA. Using DIS with Javascript in web applications, usually combined with websockets or WebRTC is very appealling, and feasible because an implementer of the DIS protocol can use any API he likes. Javascript can be used with 3D standards such as WebGL to implement 3D graphics in the web browser. There is a wealth of information to "mash-up" on the web, including maps and geo-referenced data. This is all possible because the lack of a standardized DIS API allowed Javascript DIS to be rapidly developed and deployed because the language only needed to decode existing standardized messages rather than the industry approving Javascript API for DIS.

Notice that while DIS specifies the format of messages on the network, HLA does not. HLA is an API specification, and those that implement HLA can pick any format for messages on the wire that they like. This means that RTIs from different vendors cannot directly communicate with each other--their wire formats are mutually incomprehensible to each other. The lack of a standard format for information on the network wire was, and is still, a controversial design choice. Getting two simulations to communicate requires either that all participants agree on an RTI from a single vendor, or that some sort of a gateway/bridge be used to connect the different RTI vendors.  There has also been some drift between FOMs. Not all deployed simulations use only the standardized RPR-FOM, and have instead added extra or differing information. This can make it difficult for several simulations to work together within an HLA context, even if all the simulations use FOMs similar to RPR-FOM. Simulations using two RTI vendors can theoretically solve integration problem if we make the optimistic assumption that they are using identical FOMs. In principle the users can simply drop in a new RTI using the existing FOM and it will all work. The reality is often different. Changing to a new RTI may require extensive re-certification of the simulation to ensure no significant changes actually occurred. Each simulation likely has its own advocates, and the argument about what RTI to use, and at whose expense, is likely to be heated.

Many HLA simulations use variants of RPR-FOM, which was based on DIS, and there are several gateways that translate from RPR-FOM to DIS. For these reasons and others it is common to connect HLA RPR-FOM simulations together using DIS.  Rather than trying to make the HLA simulations talk directly over HLA, the simulations translate to a common format--DIS--and then use that as a communications backbone. This sidesteps several issues, including the RTI version problem, the incompatible FOM problem, and the vendor-specific network message format problem. Usually no source code changes or recompilation of the HLA application needs to be done. A drawback is that the DIS communications backbone may carry less semantic information than any particular HLA simulation's FOM. Integrating simulations will require a good deal of coordination.

If you need a simulation that uses a clock that runs at something other than real time, HLA is your choice. Neither DIS nor TENA have simulation time that runs in non-realtime. HLA also includes distributed data management (DDM). DDM reduces traffic to simulation participants that are not interested in it. For example, an Burke-class destroyer doing anti-air operations may not be interested in position updates from a dismounted infantry entity armed only with an AK-47 who is 20 miles inland. HLA includes features that can eliminate sending this traffic to the Burke destroyer.

HLA is popular for single applications, but it's hard or at least expensive to get two HLA applications from different vendors to communicate directly with each other. That two applications "use HLA" doesn't mean that they're interoperable. First of all, they need to both use a compatible FOM, the set of data to be exchanged between simulation participants. While RPR-FOM is popular and a SISO standard, the simulations that use it seem to in practice wind up using "RPR-FOM based" FOMs. They add extra information to the RPR-FOM, and the FOMs wind up differing from the standard. HLA simulations also need to use compatible versions of HLA. HLA 1.3 and IEEE-1516 are both popular versions, and differ somewhat in their APIs. Finally if the participants communicate directly with each other they need to use HLA RTIs from the same vendor. A Pitch RTI does not know the message format used by a MaK RTI, even if both are using RPR-FOM. Standardization of the message format was not a priority for the HLA designers. What they can do is utilize a "gateway" between the two simulations. The gateway runs both a copy of the MaK HLA RTI and the Pitch HLA RTI, and translates messages between the two simulations.

But from a practical standpoint it's often true that it's easier to use a RPR-FOM to DIS gateway than to write a new gateway to make simulations with slightly different RPR-FOMS communicate with each other. In practice many different HLA simulations are tied together by having each use a RPR-FOM to DIS gateway. All the simulations translate to DIS, and then translate the DIS messages on a backbone back to their HLA federation. RPR-FOM/DIS gateways tend to be widespread, commodity software products, and it's simpler to use DIS as a lingua franca to tie simulations together, rather than write the bespoke code for an HLA-to-HLA gateway. This choice becomes more compelling as the number of HLA simulations to integrate goes up. If we have five RPR-FOM simulations using five different RTI vendors trying to write an HLA gateway to accommodate all five becomes a mess. Trying to force every simulation to use the same RTI vendor will probably be a mess as well, at the political level if nothing else. The I/ITSEC paper in the "Further Reading" section glancingly mentions the challenge of integrating HLA simulations, which led to a decision to use DIS as the common format for Operation Blended Warrior.

TENA is often used in a range environment. It has considerable technical merits, but outside of a range environment it's a tough sell. DIS and HLA have much larger installed bases in the simulation domain. 

## Summary

 The three major DoD simulations each have their strengths, and in some integrations it's possible to have simulations all three protocols. As a practical matter, it's often easiest to have each simulation translate to DIS via a gateway.

## Further Reading

**HLA Tutorial from Pitch:** <a href="http://www.pitchtechnologies.com/hlatutorial/">http://www.pitchtechnologies.com/hlatutorial/</a><br>

**The TENA organization site, where users can register for a free download of the TENA middleware, and find more tutorials:** <a href="http://tena-sda.org">http://tena-sda.org</a><br>

**Python as a Glue Language:** <a href="https://www.python.org/doc/essays/omg-darpa-mcc-position/">href="https://www.python.org/doc/essays/omg-darpa-mcc-position/</a><br>

**Combat Modeling** <a href="https://www.amazon.com/Engineering-Principles-Modeling-Distributed-Simulation/dp/0470874295/ref=asap_bc?ie=UTF8">Andreas Tolk's book on combat modeling</a>

**Networked Graphics** <a href="https://www.amazon.com/Networked-Graphics-Building-Virtual-Environments/dp/0123744237/ref=sr_1_sc_2?s=books&ie=UTF8&qid=1485502973&sr=1-2-spell&keywords=networked+virutal+environments"> Steed & Olivera's book on networked virtual environments</a>.

**DIS/RPR-FOM Protocol support group at SISO:** <a href="https://www.sisostds.org/StandardsActivities/SupportGroups/DISRPRFOMPSG.aspx">https://www.sisostds.org/StandardsActivities/SupportGroups/DISRPRFOMPSG.aspx</a><br>

**Discussion of the 2015 IITSEC "Blended Warrior" exercise, which tied together 40-some simulations on the show floor.** <a href="http://www.iitsecdocs.com/">http://www.iitsecdocs.com/</a>, search for paper titled "Washington, We Have a Problem."

**HLA RTI Wire standards are a contentious topic. Every few years someone tosses a grenade onto the mailing list. For a discussion of the topic from the perspective of an HLA RTI vendor see** <a href="https://www.sisostds.org/DesktopModules/Bring2mind/DMX/Download.aspx?Command=Core_Download&EntryId=24573&PortalId=0&TabId=105">this presentation</a><br>


