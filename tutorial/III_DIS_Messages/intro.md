## III: DIS Messages

(Intro to problem)

### Explaining DIS to Readers

DIS designers back in the 1980's and 1990's had to design a way to handle state infromation transmitted between hosts. It's a difficult problem to solve, and one that hadn't yet been discusseed much at the time, but they came up with a pretty good solution. 

As has been mentioned, DIS does this with dozens of different messages, but we have not yet discussed what the messages are, or how they are used. There are two aspects to describing DIS messages: what data is present, and how the data is arranged in the message. In addition to thise we need to know how the message interacts with other messages. Consider one tank shooting at another tank. It will include information about what tank is shooting at another specific tank, and transmit that informtaion in a known format and known quantity. But we also need information about how and when the simulation creates the firing PDU, and what part of the simulation issues the detonation PDU, and when that happens. That's information about the simulation's DIS' protocol works. 

Describing this--both the syntax and information in the PDU, and how the PDU interacts with other messages--can be distracting. In this tutorial section it is a tricky description problem to solve. Instead we generally describes the information that's in the message. This gives the programmer an idea about what data needs to be set or read when creating or reading a message. This section can (optionaly) also describes what this intended for in general terms and how it interacts with other messages, but tries to be general.

But that's not enough in specific terms. In addition to this section, it's valuable to also look at the approach used in Section IV, which expands on the use of DIS traffic when implementing a specific task in compliance with the standard. For example, creating an entity, or one vehicle shooting at another. This gives more details on using DIS to accomplish a solution.

### Byte Order

Byte order. Yeesh.

DIS sends information in binary format between hosts. Those hosts may have CPUs from any of many vendors, and CPU makers have made different choices about how to represent numbers that take more than one byte to represent. An "integer," for example, often is represented with 4 bytes. But the question is, does the byte farthest to the left have the highest value, or the byte farthest to the right? This seems odd, but the CPU vendors made different choices for decades. The TCP/IP protocol largely chose to do "big endian" arrangement for multi-byte numbers. In fact, it happens so often that "big endian" is sometimes called "network byte order." But the Intel CPUs and, today, several other CPUS choose to use "little endia" multibyte numbers. 

For details on big vs. little endian, see https://en.wikipedia.org/wiki/Endianness

DIS sends many multi-byte data fields such as short integers, full integers, floating point numbers, and double precision floating point numbers. From a programming operation standpoint one danger is to write your own DIS code, read a PDU, and then incorrectly decode the DIS message as little endian bnary data. This will cause very strange results, because the field values will be translated to values far away from reality. 

This is often not as bad as it may seem for programmers. They often use pre-existing libraries that hide the byte order with a higher level API; in the case of DIS, there are almost always implementations that take care of endianess issues themselves. However, implementators of DIS simulations sometimes write their own DIS implementations, and they need to be aware of the issue. Those who choose to log messages to storage may need to be aware of byte order captures as well.

In the end, be aware of the possiblity of error when you create a DIS message and then put it onto the network. There's a possibility that it will be placed onto the network in the wrong byte order.

### Languages and Implementations

What's standardized in DIS is the messages placed on the network, not  APIs, or for that matter languages at all. Where HLA has standardized APIs for Java and C++, DIS can be implementated in Python, Javascript, C++, Objective-C, C#, or any other language that can read and write binary code. Even within C++ there can be different APIs in the implementation.

To compare two open source implementations in the , consider KDIS (https://sourceforge.net/projects/kdis/) and Open-DIS (https://github.com/open-dis/open-dis-cpp) and their implementatons of one of the Entity State PDU, which is one of the most used PDUs. Both implementations have slightly different code to do exactly the same thing, in this case setting a number in an object that identifies what type of PDU message this is. In the case of KDIS, it looks like this:

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

On the other hand, the Open-DIS C++ source code for gettng and settin the PDU type in a PDU looks like this:

~~~
unsigned char getPduType() const; 
void setPduType(unsigned char pX); 
~~~

The function name for setting the pdu type is not the same--one uses a capital letters in places the other does not, to begin with. That means changing a C++ simulation to use Open-DIS rather than KDIS is likely to involve considerable work to change the source code. 

Likewise, a the API changes between languages. The Open-DIS Python implementation of DIS relies on the programmer directly accessing the pduType field of PDU object instead of using an accessor method:

~~~
self.pduType = 1
~~~

As does the Open-DIS Javascript implementation. The Java Open-DIS implementation relies on the "getPduType()" and "setPduType()" methods, which were chosen by the DIS protocol implementor. There is no standard at all for the API to set the value--any method name at all is legitimate, and any popular language implementation can be used in any language capable of reading and writing binary data to the network. 

### List of All PDUs 

A display showing the complete list of PDUs is shown below.

![Alt text](III_DIS_Messages/images/pduHierarchy.jpg)

Notice the "inheritance"-style structure of PDUs. 


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


This fields are at the start of every one of the dozens of PDUs, though the values inside these fields vary. 

#### Protocol Version 
As with many software implementations new and updated software is sometimes released. In the case of DIS, there are three typically three versions of DIS that some implementations use.

DIS Protocol Version 5 is is a IEEE standard of DIS introduced in 1995. The binary value for 5 is placed in the field.

DIS Protocol Version 6 was introduced by a later IEEE version in 1998. It corrected some ambiguous or incorrect implementations of DIS.

DIS Protocol Version 7 was approved by SISO and IEEE in 2012. It introduced some new PDUs related to energy emissions for military action.

#### Exercise ID
on any given network there may be multiple copies of a simulation running. Perhaps a single given application may have five copies running on the same network. This can introduce confusion, and we would want some way for the first copy to distinguish itself from copies two, three, four, and five. This is what the Exercise ID and do. When we start the application we can specify a unique number for that copy of the simulation.

#### PDU Type
Every type of PDU (see below) in DIS has a different number assigned to it. The Entity State PDU has a value of 1 in this field, for example. Simulations that receive a binary format PDU can peak at this binary field, decode the value, and then parse the rest of the PDU accordingly. Once we decode the value we know what we need to do to decode the rest of the PDU.

#### Timestamp
The Timestamp field relates to when the PDU was sent. It's a 32 bit field, and the subject is complex. It can be used to determine which PDU was sent first; if send via UDP networks, the PDUs might not arrive in the same order they were sent. There are two versions of time saved, one based on absolute time values, and another based on the sender's local clock time. The field itself represents units of time that have passed since the start of the hour, which means that the value of the field will drop at the start of the hour.

The timestamp field is discussed in great depth elsewhere.

#### Length

Some PDUs are of variable length. The length field tells us exactly how long the PDU is. In some cases network packets contain several PDUs; knowing the exact length of each PDU in the packet helps us decode the entire set of several PDUs.

#### PDU Status
This is also a somewhat complex topic that needs more space to explain. The PDU Status field contains bit areas that can be extracted to reveal more information about the PDU, and how it relates to other traffic.

#### Padding
The PDU header was originally sent with 16 bits of unused space. This was intended to allow some later expansions of headers and cause few problems in backward compatibility. DIS version 7 used 8 of the original 16 bits to implement the PDU Status field, and there are 8 bits that are still unused. 


Remember, all PDUs start with the same set of fields listed above. There is a free utility called WireShark (https://www.wireshark.org/) that can be used to capture network traffic and decode the PDU fields, including the PDU header fields. 