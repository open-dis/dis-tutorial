# Simulation Standards

## High Level Architecture

DIS was the first standard for distributed simulations. Some time later it was believed that it could be improved upon by using different approaches than had been used in the 80's, when DIS was created. This resulted in High Level Architecture (HLA).

There are some important differences between DIS and HLA, but they sometimes share important features as well, particularly when describing combat operations. The HLA architecture can cover a wider range of problems in addition to that addressed by DIS.

### Off-Site Tutorials

There are several interesting tutorials about HLA already present. Rather than attempting to supply yet another, the approach in this section is to simply link to the existing HLA tutorials. 

Here's a list of some online HLA tutorials:

#### Pitch Technologies

[Pitch Technologies HLA Tutorial](http://www.pitchtechnologies.com/hlatutorial/) 

#### McGill University

[McGill University, Roger MacFarlane](http://msdl.cs.mcgill.ca/people/hv/teaching/MSBDesign/COMP762B2003/presentations/HLA1.pdf)

#### Center for Object Technology

[How to become an HLA
guru in a short(er) time](http://www.cit.dk/COT/reports/reports/Case6/06/cot-6-06.pdf)

### Compatibility and DIS

#### Capacity

HLA can almost always create simulations that handle more entities than DIS-based applications.

Distributed simulations are transmitting attribute values between hosts. For example, this may include position, orientation, describe the entity type, and the entity's speed. As we shall see later in descriptions of DIS's entity state PDU, DIS will transmit all of these attribute values every few seconds even if they do not change. This drives up the simulation's bandwidth and frequency of use on the network, and tends to drive down the number of entities that can be supported in a simulation.

In contrast HLA can update the same attrbutes only when they change. This drives down network

#### Network Formats

HLA took some fundamentally different technical approaches when compared to those of DIS. DIS made the choice to standardize the syntax and semantics of a few dozen messages sent on the network. All programming languages that can address binary data issues are capable of decoding the messages. This includes C, C++, Java, Javascript, Objective-C, Python, and dozens of others. For some devotees of particular languages or those developing in a language-specific framework that used a somewhat rare language, this could be a useful feature. 

HLA took a different approach. Rather than define the format of messages, it standardized an Application Protocol Interface (API). The API is, by definition, specific to a programming language. The API defines a set of function calls, and those function calls are language-specific. The primary APIs for HLA are C++ and Java. (There's also a very rarely used API for web services; it seems not very usable due to the high latency rates of web services, which do not line up with the performance of more modern web technology techniques.)

The APIs defined are available at SISO. For example, functions in the API for a Java version of the [HLA API](https://www.sisostds.org/DesktopModules/Bring2mind/DMX/Download.aspx?Command=Core_Download&EntryId=42469&PortalId=0&TabId=105) looks like this:

~~~
virtual void discoverObjectInstance (
 ObjectHandle theObject, // supplied C1
 ObjectClassHandle theObjectClass, // supplied C1
 const char * theObjectName) // supplied C4
throw (
 CouldNotDiscover,
 ObjectClassNotKnown,
 FederateInternalError) = 0;
 ~~~
 
There also exists a C++ API that performs the same operation. These function calls are of course language-specific, and those who want to use other languages may run into problems. (Unless they manage to make C++/Java function calls from their own language.)

The more interesting problem is how the functions are actually accomplished. The API defines the what the function calls are, but not the format the messages exchanged between are in. For example, consider a function call that updates an attribute, which in Java looks like this:

~~~
virtual
void requestClassAttributeValueUpdate (
 ObjectClassHandle theClass, // supplied C1
 const AttributeHandleSet& theAttributes) // supplied C4
throw (
 ObjectClassNotDefined,
 AttributeNotDefined,
 FederateNotExecutionMember,
 ConcurrentAccessAttempted,
 SaveInProgress,
 RestoreInProgress,
 ~~~
 
 At the abstract level this is a call to change a value on multiple distributed hosts. But at the practical level the API is silent about how to accomplish this. The messages exchanged may contain data in the [big or little endian format](https://en.wikipedia.org/wiki/Endianness), for example, and there are many other things that may change between implementations of the HLA API.
 
Because the same versions of HLA require identical APIs, this can mean that for a single applicaton changing the HLA vendor is probably easy. Developers can simply replace one HLA library vendor with another, often without even recompiling the applicaton. This is a useful feature.

At the same time, the lack of a network standard can make multiple applications working together difficult. Imagine two HLA applications using exactly the same Federation Object Model (FOM), a simulation component that defines the entities and the attributes they have. TankApp uses an HLA vendor named SuperHLA, while AircraftApp uses an HLA vendor named AwesomeHLA. The two vendors use exactly the same API, but the format of messages they put on the network are different and incompatible. 

If the two appliations are to interoperate one option is to use the same HLA implementation, from either SuperHLA or AwesomeHLA, in both applications. 

Another option is for each application to share its data in DIS format. In addition to using HLA internally it may issue a feed regarding entity movement in DIS. There are applications that can then read this DIS feed and share it to a separate HLA vendor application. The TankApp uses SuperHLA to issue DIS traffic; AircraftApp uses AwesomeHLA to read this DIS and make calls to the API. 

The DIS component is harder to implement in the situaton described above, but at the same time there can be significant managerial resistance to changing HLA vendors even for two nearly identical simulations. The DIS solution becomes more practical as the two applicatons start becoming more different. For example imagine TankApp has a slightly different FOM than AircraftApp. Then four other applications are added to the pool, each with the intention of all six applications working with each other. There are slightly different FOMs, and three differnet versions of HLA. For a situation such as that described above, DIS can be a useful tool. 


 
  
 
 

