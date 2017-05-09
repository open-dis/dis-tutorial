## DIS Implementations

There are a number of DIS implementations in several languages, both open source and commercial. 

The open source implementations are free, as in "free puppy." They may have rough edges, and have lower levels of support than commercial offerings. It usually beats writing your own, though.

### Open-DIS
Open-DIS is a popular implementation. The main site is at <a href="http://github.com/open-dis">http://github.com/open-dis</a>. If you're reading this, you've probably already found it. It has implementations of DIS for Java, C++, Python, C#, Objective-C, and Javascript, for DIS versions 6 and 7.

The Open-DIS language implementations were written by using an XML document that describes in abstract terms the structure of PDUs. For example, this XML fragment describes a record that may be part of a PDU:

~~~~
<class name="Vector3Double" inheritsFrom="root" comment="Three double precision floating point values, x, y, and z. Used for world coordinates Section 6.2.97.">
  
  <attribute name="x" comment = "X value">
    <primitive type="double"/>
  </attribute>

  <attribute name="y" comment="y Value">
    <primitive type="double"/>
  </attribute>

  <attribute name="z" comment="Z value">
    <primitive type="double"/>
  </attribute>
</class>
~~~~

A program can be written to parse this XML document and generate language implementations. In the case of Java, this would include a "Vector3Double" class with getter and setter methods for x, y, and z. The XML document also provides enough information to marshal and unmarshal the data in a class to the format specified by the DIS standard. This simplifies writing new language implementations; it takes roughly a thousand lines of Java code to create a new language implementation.

### KDIS

KDIS is an open source C++ implementation of DIS in C++. It's available from sourceforge at <a href="https://sourceforge.net/projects/kdis/">https://sourceforge.net/projects/kdis</a>

### RedSim

<a href="http://www.redsim.com/">RedSim</a> is a commercial company that sells DIS tools. 

### MaK

<a href="http://www.mak.com/products/link/vr-link">Måk Technologies</a> sells a "VR-Link" product that provides an API that can handle either DIS or HLA. 

### Partial Implementations

There's a long history in DIS of providing implementatations of only the PDUs one actually makes use of, often home-grown. It's not that difficult to write five or so PDUs, so you often see someone just write it and include it as an element of their project.

