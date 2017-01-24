##Combat

DIS was designed for use in the military, and one of the military's core competencies is shooting at people. DIS has to enable training for this.

Shooting in DIS is represented by fire and detonation PDUs. The fire PDU carries the information associated with a weapon firing. DIS is typiclly broadcast-oriented, and every other simulation participant will receive the fire PDU. They can use this to model visual effects associated with the firing, such as muzzle flash, dust clouds, or smoke. 

The detonation PDU is tied to a preceding fire PDU. It contains information about the munition that impacts. Like the fire PDU, the detonation PDU is typcially received by all simulation particpants. Any participant, including a specifically targeted particpant, can assess damage to itself that results from the detonation. 


### The Fire PDU

The Fire PDU Javadoc documentation for Open-DIS is <a href="javadoc/edu/nps/moves/dis/FirePdu.html">here</a>. It inherits from the WarfareFamily PDU, which adds two fields: a firingEntityID and a targetEntityID. Entity IDs have been discussed earlier <a href="EntityIdentifiers.md">here</a> They are a record that contains three numbers that, together, uniquely identify an entity in the world. The firingEntityID identifies the shooter, and the targetEntityID is the ID of the target.

Remember that this is the Open-DIS implementation of the DIS protocol we are discussing. Other implementations can and will have different class names and variable names. The KDIS C++ implementation calls this class <a href="http://kdis.sourceforge.net/classdoc/class_k_d_i_s_1_1_p_d_u_1_1_warfare___header.html">Fire\_PDU</a>, which inherits from a class called Warfare\_Header with attributes m\_FiringEntityID and m\_TargetEntityID. The person who implemented that class library simply chose different names for the classes. This is perfectly legal in DIS, where standardization occurs in the format of messages, not the programming language API.

### Direct Fire
In DIS the protocol's rules for shooting have some special cases. The primary case, or at least the one everyone thinks of first, is direct fire. An entity has an opponent in view, and shoots.  An element of the simulation issues a Fire PDU, and the simulation models the shot as a ballistic event. The round(s) impact, and the simulation issues a detonation PDU. The targeted entity and any other entities that may be interested examine the detonation PDU and assess damage to themselves. 








