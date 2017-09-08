## III: DIS Messages

(Intro to problem)

### Explaining DIS to Readers

DIS designers back in the 1980's and 1990's had to design a way to handle state infromation transmitted between hosts. It's a difficult problem to solve, and one that hadn't yet been discusseed much at the time, but they came up with a pretty good solution. 

As has been mentioned, DIS does this with dozens of different messages, but we have not yet discussed what the messages are, or how they are used. There are two aspects to describing DIS messages: what data is present, and how the data is arranged in the message. In addition to thise we need to know how the message interacts with other messages. Consider one tank shooting at another tank. It will include information about what tank is shooting at another specific tank, and transmit that informtaion in a known format and known quantity. But we also need information about how and when the simulation creates the firing PDU, and what part of the simulation issues the detonation PDU, and when that happens. That's information about the simulation's DIS protocol works. 

Describing this--both the syntax and information in the PDU, and how the PDU interacts with other messages--can be distracting. In this tutorial section it is a tricky description problem to solve. Instead we generally describes the information that's in the message. This gives the programmer an idea about what data needs to be set or read when creating or reading a message. This section can (optionaly) also describes what this intended for in general terms and how it interacts with other messages, but tries to be general.

But that's not enough in specific terms. In addition to this section, it's valuable to also look at the approach used in Section IV, which expands on the use of DIS traffic when implementing a specific task in compliance with the standard. For example, creating an entity, or one vehicle shooting at another. This gives more details on using DIS to accomplish a solution.

At the same time, this tutorial is not about how to write an implementation of DIS. It helps, but in the end, anyone writing their own implemntation of the PDUs they are using. That involves acquiring a copy of the IEEE-1278 standard, which has creater detail about individual fields and where they are placed in messages. In the end, our interpretation will be less accurate than the defining IEEE-1278 standard itself, and you should read the source document. 

### Byte Order

Byte order. Yeesh.

DIS sends information in binary format between hosts. Those hosts may have CPUs from any of many vendors, and CPU makers have made different choices about how to represent numbers that take more than one byte to represent. An "integer," for example, often is represented with 4 bytes. But the question is, does the byte farthest to the left have the highest value, or the byte farthest to the right? This seems odd, but the CPU vendors made different choices for decades. The TCP/IP protocol largely chose to do "big endian" arrangement for multi-byte numbers. In fact, it happens so often that "big endian" is sometimes called "network byte order." But the Intel CPUs and, today, several other CPUS choose to use "little endia" multibyte numbers. 

For details on big vs. little endian, see https://en.wikipedia.org/wiki/Endianness

DIS sends many multi-byte data fields such as short integers, full integers, floating point numbers, and double precision floating point numbers. From a programming operation standpoint one danger is to write your own DIS code, read a PDU, and then incorrectly decode the DIS message as little endian binary data. This will cause very strange results, because the field values will be translated to values far away from reality. 

This is often not as bad as it may seem for programmers. They often use pre-existing libraries that hide the byte order within a higher level API; in the case of DIS, there are almost always implementations that take care of endianess issues themselves. However, implementators of DIS simulations sometimes write their own DIS implementations, and they need to be aware of the issue. Those who choose to log messages to storage may need to be aware of byte order captures as well. Some PDUs include the ability to include simulation-generated data in binary format as well, and this is often set to big-endian format, while some others use little-endian format. If anything goes wrong with transmitted user data you should check the endian format used on both sides.

In the end, be aware of the possiblity of error when you create a DIS message and then put it onto the network. There's a possibility that it will be placed onto the network in the wrong byte order.

### Languages and Implementations

What's standardized in DIS is the messages placed on the network, not  an API, or for that matter languages at all. Where HLA has standardized APIs for Java and C++, DIS can be implementated in Python, Javascript, C++, Objective-C, C#, or any other language that can read and write binary code. Even within C++ there can be different APIs in the implementation.

To compare two open source implementations in the , consider KDIS (https://sourceforge.net/projects/kdis/) and Open-DIS (https://github.com/open-dis/open-dis-cpp) and their API implementatons of one of an Entity State PDU, one of the most used PDUs. Both implementations have slightly different code to do exactly the same thing, in this case setting a number in an object that identifies what type of PDU message this is. In the case of KDIS, it looks like this:

~~~
//************************************
// FullName:    KDIS::PDU::Header6::SetPDUType
//              KDIS::PDU::Header6::GetPDUType
// Description: The type of PDU. Set by PDU automatically.
//              Only change if you know what you are doing.
// Parameter:   PDUType Type
//************************************
void SetPDUType( KDIS::DATA_TYPE::ENUMS::PDUType Type );
KDIS::DATA_TYPE::ENUMS::PDUType GetPDUType() const;
~~~

On the other hand, the Open-DIS C++ source code for gettng and settin the PDU type in any PDU looks like this:

~~~
unsigned char getPduType() const; 
void setPduType(unsigned char pX); 
~~~

The function name for setting the pdu type is not the same--one uses a capital letters in places the other does not, to begin with. That means changing a C++ simulation to use Open-DIS rather than KDIS is likely to involve considerable work to change the simulation code. The function calls in the code would need to change, at least, and it would likely involve many other changes to the code logic.

Likewise, a the API changes between languages. The Open-DIS Python language implementation of DIS relies on the programmer directly accessing the pduType data field of PDU object instead of using an accessor method:

~~~
self.pduType = 1
~~~

As does the Open-DIS Javascript implementation. The direct access (arguably) follows some of the Python and Javascript language writing habits, while C++ and Java typically use access methods to set or retrieve field values. The Java Open-DIS implementation relies on the "getPduType()" and "setPduType()" methods and the habits of the Java language. There is no standard at all for the names of the API functions to set the value--any method name at all is legitimate, and any popular language implementation can be used in any language capable of reading and writing binary data to the network. 

### List of All PDUs 

A display showing the complete list of PDUs is shown below.

![Alt text](III_DIS_Messages/images/pduHierarchy.jpg)

Notice the "inheritance"-style structure of PDUs. 

If you're planning on writing an implemetation of DIS the information in this section is not enough. If you want to do that you should acquire a copy of the IEEE-1278 document. The information in that standards document has the required information, and it is unrealistic to duplicate it here. It does give some idea about what information is in the various PDUs, and what they are used for.


### PDU Header

Every one of the PDUs in DIS starts with the same fields. You can think of it as a superclass and that all PDUs inherit those data fields.

| Field Name           | Data Type |  
|----------------------|--------------|
| Protocol Version     | 8 bit enumeration  | 
| Exercise ID          | 8 bit unsigned int |
| PDU Type             | 8 bit enumeration  |
| Protocol Family      | 8 bit enumeration  |
| Timestamp            | 32 bit unsigned integer |
| Length               | 16 bit unsigned integer |
| PDU Status           | 8 bit record            |
| Padding              | 8 bits unused |


This fields are at the start of every one of the dozens of PDUs, and the values inside these fields vary. An Entity State PDU will always have a "pdu type" field value of 1, and that lets a binary-reading application identify the type of PDU that just arrived. 

#### Protocol Version 
As with many software implementations new and updated software is sometimes released. In the case of DIS, there are typically three versions of DIS that some implementations use.

DIS Protocol Version 5 is is a IEEE standard of DIS introduced in 1995. The binary value for 5 is placed in the field. Version 5 is somewhat rarely seen in lab applications.

DIS Protocol Version 6 was introduced by a later IEEE version in 1998. It corrected some ambiguous or incorrect implementations of DIS. It is likely the most seen version of DIS used in applications.

DIS Protocol Version 7 was approved by SISO and IEEE in 2012. It introduced some new PDUs related to energy emissions for military action.

This information can be important. DIS versions are typically backward-compatible, but not always forward-compatible. Version 7 implementations can usually handle version 6 messages, but version 6 and be confused by new messages sent by version 7 energy emission PDUs.

#### Exercise ID
on any given network there may be multiple copies of a simulation running. Perhaps a single given application may have five copies running on the same network. This can introduce confusion, and we would want some way for the first copy to distinguish itself from copies two, three, four, and five. This is what the Exercise ID and do. When we start the application we can specify a unique number for that copy of the simulation.

#### PDU Type
Every type of PDU (see below) in DIS has a different number assigned to it. The Entity State PDU has a value of 1 in this field, for example. Simulations that receive a binary format PDU can peak at this binary field, decode the value, and then parse the rest of the PDU accordingly. Once we decode the value we know what we need to do to decode the rest of the PDU.

#### Timestamp
The Timestamp field relates to when the PDU was sent. It's a 32 bit field, and the subject is complex. It can be used to determine which PDU was sent first; if send via UDP networks, the PDUs might not arrive in the same order they were sent. There are two versions of time saved, one based on absolute time values, and another based on the sender's local clock time. The field itself represents units of time that have passed since the start of the hour, which means that the value of the field will drop at the start of the hour.

The timestamp field is discussed in greater depth elsewhere.

#### Length

Some PDUs are of variable length. The length field tells us exactly how long the PDU is. In some cases network packets contain several PDUs; knowing the exact length of each PDU in the packet helps us decode the entire set of several PDUs.

#### PDU Status
This is also a somewhat complex topic that needs more space to explain. The PDU Status field contains bit areas that can be extracted to reveal more information about the PDU, and how it relates to other traffic.

#### Padding
The PDU header was originally sent with 16 bits of unused space. This was intended to allow some later expansions of headers and cause few problems in backward compatibility. DIS version 7 used 8 of the original 16 bits to implement the PDU Status field, and there are 8 bits that are still unused. 


Remember, all PDUs start with the same set of fields listed above. There is a free utility called WireShark (https://www.wireshark.org/) that can be used to capture network traffic and decode the PDU fields, including the PDU header fields. 


## Entity Families

### Entity Information Family

The Entity Information Family is a group of PDUs that are related to that of the position and other information about entties. They describe the location of entities, and sometimes their collision. An image of the PDUs in the family is below.


![Alt text](III_DIS_Messages/images/EntityInformationFamilyPdus.jpg)

#### Entity State PDU
The entity state PDU is one of the most widely used PDUs in DIS. It includes the unique ID of the entity described, numeric values that describe the type of entity, and its position, orientation, velocity, acceleration, and the dead reckoning algorithm that should be used between the receipt of other position PDUs.

Describing what the Entity State PDU (ESPDU) does can be complicated or simple. Some of the capabilities are described in greater detail elsehwere in this document.

The Java language class documentation for the ESPDU class is available here. 

##### PDU header
Every ESPDU starts with the PDU header, just as does every other PDU. 

##### Enity ID
Every entity handled by DIS--every vehicle, every person whose position is described, every ship, every aircraft--must have an ID to uniquely identify it. This is what the entity ID is. It is described later, butiIt consists of a triplet of three numeric values: {Site, Application, Entity}. The triplet, together, must be unique. Arriving ESPDUs decode the entity ID and use it to update the position  and orientation of the entity it is tracking.

Entity ID is discussed in greater depth in Section IV: [Enity Identifiers](../IV_DIS_Issues/EntityIdentifiers.md)

##### Force ID

There can be more than one (or two!) force affiliations on the battlefield. The force ID field lets you specify this. The values set are defined in the Enumerated and Bit Encoded Values (EBV) document published by SISO. This document contains many pre-defned values. This is the case for force ID fields, as shown below:

| Force | Integer Field Value |
|-------|---------------------| 
| Other | 0  |
| Friendly | 1 |
| Opposing | 2 |
| Neutral  | 3 |

##### Number of Variable Parameters

The ESPDU can also contain some extra parameters with arbitary, programmer-defined data. This field identifes the number of the parameters (which are of a pre-defined size) at the end of the PDU. This is descrbied in greater detail later in the document.

##### Entity type
 
One question is how the receiver should draw the entity. How does the simulation know what it looks like? The type of the entity being described is included in the entity type field of the ESPDU. The receiving simulation can identify the entity type and, if it has a model for the entity, use that model to draw on the screen.

| Field Name | Value|
|------------|------|
| Entity Kind | The kind of entity described by the Entity Type record |
| Domain      | The domain in which the entity operates (e.g., subsurface, surface, and land) except for munition entities     |
| Country     | Nation to which the entity belongs |
| Categroy    | Unique ID |
| Subcategor  | Unique ID |
| Specific    | Unique ID |
| Extra       | Unqiue ID |

The EBV document includes SISO-defined collections of entity types. For example, the UK Challenger Main Battle tank has these values:


| Field Name | Value|
|------------|------|
| Entity Kind | 1 |
| Domain      | 1 (land) |
| Country     | 223 (UK) |
| Categroy    | 1 |
| Subcategor  | 2 |
| Specific    | 2 (Mk 2) |
| Extra       | Unused |

This information was defined in the EBV SISO document, and is an agreed-upon, compact, and exact vocabulary for defining entity types. 

##### Alternate Entity Type

This is exactly like an Entity Type field. However, some simulation applications also want to allow simulations to use deceptive appearances to other simulations. If an aircraft issues deceptive electronic signatures to make a fighter aircraft appear to be a civilian airliner, that is possible. The alternate entity type field holds a description of what airliner that entity is, and other simulations may present an airliner in the 3D display, rather than an F-16.

##### Entity Linear Velocity

How fast the entity is moving. Three coordinate values (x, y, and z) are used. This is quite valuable for making the entity appear to travel in a smooth manner by using dead reckoning to move the entity between receptions of individual ESPDUs, which might appear only seconds apart. We don't want the movement to appear to be jerky or hyperspace-jump like.

The coordinate system used in the field varies. It could be global, with a coordinate system that has its origin at the center of the earth, or it may use a more local coordinate system. The type of coordinate system used in the field is set in the dead reckoning field below.

##### Entity Location

The entity location is interesting. It uses a three-value record, X, Y, and Z, that measures the distance from the center of earth. These values can be converted to latitude, longitude, and altitude with some mathematical work, or to MGRS coordinates, or to a local coordinate system placed with its origin at a known location. It is described further in a later section.

Entity Location is dicussed in more detail at [Entity Location](../IV_DIS_Issues/CoordinateSystems.md)

##### Entity orientation
This determines which way the entity is pointing. It's a little mysterious; what defines the "front" or "up" of an entity? Still, it can often be defned. As with the location, this is described elsewhere, but is done with what are called "euler angless."

##### Entity appearances

Some entityeis may be burning, or smoking, and this alters how receiving simulations should draw the entity. There are several appearance settings, and this is accomplished in the ESPDU by using a 32-bit integer. Sub-regions of the integer are used to describe the appearnce. 

##### Dead Reckoning Parameters

This represents how the sending simulation believes dead reckoning should be done. For example, should it include the entity's acceleration, or not. The angular acceleration, or not? The object's linear acceleration, or not?

This is another subject discussed elsewhere. (Sigh.)

##### Entity Marking

This is a useful debugging measure. The marking is effectively 11 string characters. This lets presenting applications use thestring to hae a small description drawn along with the 3D model. Viewers can view something like "Open-DISApp" or "FooApp".


##### Capabilities

A 32-bit integer. Subranges of the integer describe what the entity is capable of.

##### Variable Parameters

The ESPDU can contain a list of variable paramters. Each of the paramters is 128 bits, total, long. This can be used to contan such information as the direction in which the rotating turent of a tank is pointing, and what the elevation of the gun is. This deends on the  sending and receiving simulations having an agreement on what the variable paramters mean, and what the endian format of the data is in.




#### Collision PDU

#### Collision-Elastic PDU

#### Entity State Update PDU

#### Attribute PDU

### Warfare Protocol Family

#### Firing PDU

#### Detonation PDUD

#### Directed Energy PDU

#### Entity Damage Status PDU
