##Combat

DIS was designed for use in the military, and one of the military's core competencies is shooting at people. DIS must enable combat operation training to be useful to the military.

Shooting is tricky in part because of the latency inherent in a distributed real time simulation. See the <A href="Latency.md">latency</a> section for more detail on why networked virtual environments (NVEs) are usually out of sync with each other to one extent or another. Each participant in the simulation may have a different idea about where an entity "really" is. This can be mitigated but not entirely eliminated.

There are other challenges with shooting related to interoperability. We want simulations from different vendors, written years apart from each other, to interoperate as painlessly as possible. To accomplish this the simulations need to be _loosely coupled_, a term that means they should depend on each other as little as possible and have as little knowledge as possible about each other. DIS is effectively a message-passing system, and that is usually conducive to loosely coupled systems. Every application involved--there may be several--should know as little as possible about the other particpants, and the information about the combat should be contained in the messages being exchanged rather than in the participants.  

Shooting in DIS is represented by a sequence of a fire PDU and a detonation PDU. The fire PDU carries the information associated with a weapon firing. DIS is typically broadcast-oriented, and every other simulation participant will receive the fire PDU. They can use this to model visual effects associated with the firing, such as muzzle flash, dust clouds, or smoke. The detonation PDU is tied to a preceding fire PDU and contains information about the munition that is used in the shot. Like the fire PDU, the detonation PDU is typcially received by all simulation particpants. Any participant, including both a specifically targeted particpant and any other entity can assess damage to itself that results from the detonation. 

Note the "to itself." Usually the effects of the detonation are determined by the entity near it, which is usually not the shooter. Damage assessed on the honor system, which means that cheating is possible. Cheating is a problem in the commercial gaming world, but typically not in the military, despite Captain Kirk's Kobyashi Maru exploits.

The details of the interaction and how the fire and detonation fields are filled out vary depending on the type of combat, for example direct vs indirect fire. There is considerable room for language lawyering in the DIS standard. The mechanics of shooting are discussed in more detail below. 


### The PDUs involved

The Fire PDU Javadoc documentation for Open-DIS is <a href="javadoc/edu/nps/moves/dis/FirePdu.html">here</a>. It inherits from the WarfareFamily PDU, which has two fields: a firingEntityID and a targetEntityID. Entity IDs have been discussed earlier <a href="EntityIdentifiers.md">here</a> They are a record that contains three numbers that, together, uniquely identify an entity in the world. The firingEntityID identifies the shooter, and the targetEntityID is the ID of the target.

Remember that this is the Open-DIS implementation of the DIS protocol we are discussing. Other implementations can and will have different class names and variable names. The KDIS C++ implementation calls this class <a href="http://kdis.sourceforge.net/classdoc/class_k_d_i_s_1_1_p_d_u_1_1_warfare___header.html">Fire\_PDU</a>, which inherits from a class called Warfare\_Header with attributes m\_FiringEntityID and m\_TargetEntityID. The person who implemented that class library simply chose different names for the classes. This is perfectly legal in DIS, where standardization occurs in the format of messages, not the programming language API.

The detonation PDU represents a munition impact event. 

### Direct Fire
In DIS the protocol's rules for shooting have some special cases. The primary case, or at least the one everyone thinks of first, is direct fire. An entity has an opponent in view, and shoots.  An element of the simulation issues a Fire PDU, and the simulation models the shot as a ballistic event. The round(s) impact, and the simulation issues a detonation PDU. The targeted entity and any other entities that may be interested examine the detonation PDU and assess damage to themselves. 








