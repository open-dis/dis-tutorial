## High Level Architecture

DIS was the first standard for distributed simulations. Some time later it was believed that it could be improved upon by using different approaches than those of the 80's, when DIS was created. This resulted in High Level Architecture (HLA).

There are some important differences between DIS and HLA, but they often share important features as well, particularly when describing combat operations. The HLA architecture can cover a wider range of problems in addition to those addressed by DIS.

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

#### Georgia Institute of Technology, Computational Science and Engineering Division, Richard M. Fujimoto

[The High Level Architecture: Introduction](http://www.acm-sigsim-mskr.org/Courseware/Fujimoto/Slides/FujimotoSlides-20-HighLevelArchitectureIntro.pdf)

### HLA and DIS

#### RPR-FOM

HLA was designed and built to be more general than DIS, but at the same time it was very useful to have HLA configurations that did many of the same things. Readers of the tutorials above know something about Federation Object Modules (FOMs). The FOMs define the objects and attributes in an HLA federation. 

SISO realized that it would be useful to define a FOM similar to that of DIS, and that's exactly what they did. The Real-time Platform Reference
Federation Object Model [(RPR-FOM)](https://www.sisostds.org/DesktopModules/Bring2mind/DMX/Download.aspx?Command=Core_Download&EntryId=30823&PortalId=0&TabId=105) defines a FOM that copies many DIS concepts. RPR-FOM makes it easier to work with DIS appliations.

Consider the location of a simulation entity. In an application RPR-FOM object we can define an object attribute:

~~~
<field>
    <name>WorldLocation</name>
    <dataType>WorldLocationStruct</dataType>
    <semantics>-NULL-</semantics>
 </field>
~~~

The simulated object includes an attribute defining its location in the world. The format of this attribute is identical to that used by DIS. As we will see, the WorldLocationStruct defined in the RPR-FOM is exactly the same as that used in DIS.  

~~~
<fixedRecordData>
                <name>WorldLocationStruct</name>
                <encoding>HLAfixedRecord</encoding>
                <semantics>Location of the origin of the entity's coordinate system shall be specified by a set of three coordinates: X, Y, and Z. The shape of the earth shall be specified using DMA TR 8350.2, 1987. The origin of the world coordinate system shall be the centroid of the earth, with the X-axis passing through the prime meridian at the equator, the Y-axis passing through 90 degrees east longitude at the equator, and the Z-axis passing through the north pole. These coordinates shall represent meters from the centroid of the earth.</semantics>
                <field>
                    <name>X</name>
                    <dataType>WorldLocationOffset</dataType>
                    <semantics>-NULL-</semantics>
                </field>
                <field>
                    <name>Y</name>
                    <dataType>WorldLocationOffset</dataType>
                    <semantics>-NULL-</semantics>
                </field>
                <field>
                    <name>Z</name>
                    <dataType>WorldLocationOffset</dataType>
                    <semantics>-NULL-</semantics>
                </field>
~~~

The closeness of RPR-FOM to DIS is quite useful for many applicatons.

#### Simulation Size

HLA can almost always create simulations that can include more entities than DIS-based applications.

Distributed simulations transmit simulation entity attribute values between hosts. This may include information such as position and orientation, and also describe the entity's speed and acceleration. As we shall see later in descriptions of DIS's entity state PDU, DIS will transmit all of these attribute values every few seconds even if they do not change. This increases the network use for every entity in the simulation. A simulated truck parked next to a road will send updates every few seconds for all of the attributes mentioned above, even though they did not change. The increased use of the network, which has a limited capacity, can reduce the number of entities the simulation can support.

In contrast HLA can send updates oof the same attributes to other hosts only when they are changed. A parked truck does not change its position or orientation, and its speed and acceleration remain at zero while parked. HLA can send no updates at all to the other participants in the simulation. This drives down network use by letting HLA applications use less bandwidth. In the end, HLA can suppport more simulated entities because it reduces network use for each simulated entites.

#### Network Message Formats

HLA took some fundamentally different technical approaches when compared to those of DIS. DIS made the choice to standardize the syntax and semantics of a few dozen messages sent on the network. All programming languages that can read and send binary data messages are capable of decoding and sending DIS messages. This includes C, C++, Java, Javascript, Objective-C, Python, and dozens of others. Sometimes simulation application programmers like to use specific languages for various reasons. Python and Javascript have been interesting and powerful programming languages of late. 

HLA took a different approach. Rather than define the format of messages, it uses standardized Application Protocol Interface (API) for a limited set of languages. The list of APIs for HLA is at [SISO](https://www.sisostds.org/APIs.aspx). Every API is, by definition, specific to a programming language. 

The API defines a set of function calls, and the function calls must be language-specific. The primary APIs for HLA are C++ and Java. (There's also a rarely used API called "Web Services." Web services refers to a technology that seems not very usable in distributed simulations due to its high latency rates, though it is still supported by SISO. There are today better performing web technologies which will be discussed.)

The full APIs defined are available at SISO. For example, a function in the API for a Java version of the [HLA API](https://www.sisostds.org/DesktopModules/Bring2mind/DMX/Download.aspx?Command=Core_Download&EntryId=42469&PortalId=0&TabId=105) looks like this:

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
 
There is also a C++ API function that performs the same operation, but the syntax of that function call in C++ API element is of course compliant with the C++ language.

Developers who want to use other languages, such as Python or Javascript, may run into problems if in the end a call must be made to the Java or C++ APIs for those languages to access HLA. In contrast the developer can directly decode the DIS messages in the language he prefers to use.

Another interesting problem is how the HLA API function calls are actually achieved. The API defines the names of function calls and what they do, but do not define how the function works. In the end, messages must be exchanged between hosts, and HLA does not define the message format used to accomplish this. The message format to achieve the result of discoverObjectInstance is determined by the vendor that implements the HLA API.

At the abstract level the function above is a call to search for an object instance. But at the practical level the API is silent about how to accomplish discoverObjectInstance(). The messages exchanged between hosts may contain data in the [big or little endian format](https://en.wikipedia.org/wiki/Endianness), and there may be several messages passed between simulation hosts. Since HLA defines the API, but not the nature of messages necessary to implement the API, in practice every implementation of HLA has different binary messages issued on the network. 
 
The lack of a network standard can make multiple applications working together difficult. Imagine two HLA applications that use exactly the same HLA Federation Object Model (FOM). The simulation's FOM is a configuration component that defines the simulation's entities and the entity attributes they have. TankApp uses a vendor of HLA that sells a product called SuperHLA, while the application we want it to workk with, called AircraftApp, uses an HLA implementation product named AwesomeHLA. The two vendors use exactly the same API, but the format of messages they put on the network are different from each other, unknown, and incompatible. SuperHLA cannot receive messages sent by AwesomeHLA, and AwesomeHLA cannot receive messages sent by SuperHLA. Perhaps the programmers for SuperHLA decided to use little endian messages, while AwesomeHLA developers chose to use big endian formats. The HLA implementations have no idea about how they should decode the binary messages of the other HLA implementation.

If the two appliations are to interoperate one option is to use the same HLA implementation, either SuperHLA or AwesomeHLA, in both applications. HLA adopted a strong interoperability standard, and it should be possible to point the application at a different HLA library and run it without error or recompiling. In the case of the TankApp and AircraftApp simulations we should be able to pick one of the HLA implementation libraries, use it in both applications, and start the applications again without recompilation. (In practice there seems to be some reluctance by program managers to do this without a good deal of testing.)

Another option is for each application to share its data in DIS format. In addition to using HLA internally the application may issue a feed to the network about entity movement in DIS format. Perhaps the other application that can then receive the DIS feed and share it into its own HLA implementation. The TankApp uses SuperHLA and also issues DIS traffic; AircraftApp uses software to read the DIS issued by TankApp and feed the information into AwesomeHLA.

The DIS solution becomes more practical as the two applicatons start becoming more differing. For example imagine TankApp has a slightly different FOM than AircraftApp. After that four other applications are added to the interaction pool with the intention of all six applications working with each other. The applications use slightly different FOMs, and three differnet versions of HLA by default. For a situation such as that described above, DIS can be a useful tool. Examples of this include that of Interservice/Industry Training, Simulation and Education Conference [I/ITSEC](http://exhibits.iitsec.org/2016//custom/Playbook_OBW_NTSAfinal1110.pdf), called Operation Blended Warrior.

### Conclusion

HLA provides a number of advances over DIS, but also has some language-based restrictions. 

There are several guides to HLA that are better than what I could write. You should read them.



 
  
 
 

