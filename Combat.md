## Combat

DIS was designed for use in the military, and one of the military's core competencies is shooting at people. DIS has to enable training for combat operations to be useful to the military.

Shooting is tricky in part because of the latency inherent in a distributed real time simulation. See the <a href="Latency.md">latency</a> section for more detail on why networked virtual environments (NVEs) are usually out of sync with each other to one extent or another. Each participant in the simulation may have a different idea about where an entity "really" is. This can be mitigated but not entirely eliminated.

There are other challenges with shooting related to interoperability. We want simulations from different vendors to work together. The applications may be written decades apart; the lifecycle for military software is very long. We also want the simulations to interoperate as painlessly as possible. To accomplish this the simulations need to be _loosely coupled_, a term used to describe software that depends as little as possible and has as little knowledge about other modules as possible. DIS is effectively a message-passing system, an architecture that is usually conducive to loosely coupled systems. Every application involved--there may be several--should know as little as possible about the other particpants, and the information about the combat should be contained in the messages being exchanged rather than in the participants, so far as is possible.

Shooting in DIS is represented by a sequence of a fire PDU and a detonation PDU. The fire PDU carries the information associated with a weapon firing. DIS is typically broadcast-oriented, and every other simulation participant will receive the fire PDU. They can use this to model visual effects associated with the weapon discharging, such as muzzle flash, dust clouds, or smoke. The detonation PDU is tied to a particular fire PDU that preceded it. It contains information about the munition that is used in the engagement. Like the fire PDU, the detonation PDU is typicially received by all simulation particpants. Any participant, including both the specifically targeted participant and any other entity, can assess damage to itself that results from the detonation.

Note the "to itself." Usually the effects of the detonation are determined by the receiving entity, not the shooter. Damage assessed on the honor system, which means that cheating by the person "shot" is possible. Cheating is a problem in the commercial gaming world, but typically not in the military, despite Captain Kirk's Kobayashi Maru exploits.

That is because (note, using worst possible insult here) cheating is BORING! Military operators usually want to learn what works, what doesn't work, and what might work.

The details of the interaction and how the fire and detonation fields are filled out vary depending on the type of combat, for example direct vs indirect fire. There is considerable room for language lawyering in the DIS standard. The mechanics of shooting are discussed in more detail below.

### The PDUs involved

The Fire PDU Javadoc documentation for Open-DIS is <a href="javadoc/edu/nps/moves/dis/FirePdu.html">here</a>. It inherits from the WarfareFamily PDU, which has two fields: a firingEntityID and a targetEntityID. Entity IDs have been discussed earlier <a href="EntityIdentifiers.md">here</a> They are a record that contains three numbers that, together, uniquely identify an entity in the world. The firingEntityID identifies the shooter, and the targetEntityID is the ID of the target.

Remember that this is the Open-DIS implementation of the DIS protocol we are discussing. Other implementations can and will have different class names and variable names. The KDIS C++ implementation calls this class <a href="http://kdis.sourceforge.net/classdoc/class_k_d_i_s_1_1_p_d_u_1_1_warfare___header.html">Fire\_PDU</a>, which inherits from a class called Warfare\_Header with attributes m\_FiringEntityID and m\_TargetEntityID. The person who implemented that class library simply chose different names for the classes. This is perfectly legal in DIS, where standardization occurs in the format of messages, not the programming language API. This also means that when moving from one DIS vendor library to another the code that depends on it may need to be rewritten.

The <a href="javadoc/edu/nps/moves/dis/DetonationPdu.html">detonation PDU</a> represents a munition impact event. It includes the location at which the detonation ocurred and the type of muniton used in the shot. The fire and detonation PDUs are linked via a eventID field. Each fire PDU should have a detonation PDU.

### Types of Combat Interactions

There are several types of combat we can engage in, including direct fire and indirect fire missions. The PDUs are filled out differenty depending on the type of combat.

#### Direct Fire with Ballistic Weapons
In DIS the protocol's rules for shooting have several scenarios. The primary case, or at least the one everyone thinks of first, is direct fire using ballistic weapons, such as a tank gun or a rifle. A virtual simulation participant has an opponent in view, and shoots. The shooter's simulation issues a fire PDU, and the simulation models the shot as a ballistic event. The round(s) impact according to the simulation, and the simulation issues a detonation PDU. The targeted entity and any other entities that may be interested examine the detonation PDU and assess damage to themselves.

The fire PDU contains:

 * The entityID of the entity that is firing
 * The entityID of the intended target
 * An event identifier. This will eventually tie the fire PDU to a subsequent detonation PDU
 * The location at which the firing occurs
 * An entity type for the munition used
 * The warhead and fuse used
 * Quantity and rate at which the munition is fired
 * Intial velocity of the munition
 * Assumed range to the target

The usefulness of these fields should be apparent. The entityID gives us a way to know who the shooter is. The intended target's entityID is a very strong hint; if an entity sees a fire PDU that lists it as the target, it's a good sign that it specifically is being shot at and should pay attention. Munitions have entity types, just as vehicles do, so we can for example have 155mm howitzer shells as well as 25mm autocannon shells. In addition, we can have 120mm tank rounds with HEAT or sabot warheads, and various types of fuses, such as point impact or armor piercing. If the weapon is an autocannon, such as the Bushmaster on an Bradley IFV, it may fire a burst. The initial velocity is useful for modeling the ballistic flight characteristics.

Any simulation that receives a fire PDU can model the effects of the weapon's discharge. This need not be limited to the shooter and target. For example if a tank is firing machine gun tracer rounds at a target a third party may choose to model the sound of the weapon discharging, or model the flight of tracer rounds. Or in a virtual world an infantry man standing next to you and firing at an enemy should be modeled aurally.

After issuing a fire PDU a detonation PDU should be issued. It contains

  * An event identifier tying it to a specific fire PDU issued earlier
  * The entityID of the intended target
  * The munition type
  * Warhead and fuse type
  * Quantity of munition fired
  * Rate if fire
  * Location of the detonation in world coordinates
  * The velocity of the munition just before impact
  * Location of the detonation in local entity coordinates
  * Detonation result

We want to tie detonations to earlier fire events; this is done with the eventID. The intended target entityID is notification that if a simulation owns that the entity with that entityID, it should do a damage assessment. The munition type, warhead, fuse, quantity, and rate are used to calculate the effects of the detonation, as is the location in world coordinates.

The local coordinate system is the entity's coordinate system. (See the <a href="CoordinateSystems.md">coordinate system</a> section.) This coordinate system has its origin at the center of the entity's bounding volume, with the x-axis pointing forward, the y-axis out the right-hand side, and the z-axis pointing down. This allows the modeling of the weapon's effects based on where the munition hit. A 25mm cannon may have one effect if it hits the frontal armor of at T-55 tank, and a different effect if it hits the thinner rear armor.

The detonation result is an enumeration that describes how the warhead behaved. The possible behaviors are shown in the table below.

| Value                 | Result                            |
|-----------------------|-----------------------------------|
| Entity Impact         | Hit target, made physical contact |
| Entity Proximate      | Hit near target                   |
| Ground/Surface Impact | Hit terrain                       |
| Ground Proximate      | Exploded near terrain but not on it (eg air burst |
| Detonation            | It blew up, but no known entity or terrain affected |
| No Detonation         | A dud |

In DIS the simulation that owns the entity does damage assessment, not the shooter. If a simulation participant receives a detonation PDU that contains a target entityID owned by that participant, it must do a damage assessment. The thinking is that in the simulation modeling the target probably has a better idea of the damage that can be done to it than the shooter. Consider a simulation that has a BMP-2. The organization writing the simulation can do a respectable job of modeling the effects of 50 BMG rounds, 120mm sabot rounds, and 5.56 rifle fire because it was, evidently, interested in modeling BMP-2's. When a detonation PDU is received it can discover where it was hit and by what, do a damage lookup table operation, and assess damage to itself. If the shooter were to determine damage then it would need damage lookup tables for every possible type of entity in the world, which is obviously unworkable.

An interoperability challenge this design choice faces is that the simulation that owns the target entity needs to be able to assess the damage of all possible types of munitions with which it is being shot. This can be mitigated with the use of gateways. A gateway sitting between the simulation that owns the shooter and the simulation that owns the target can rewrite the values of the fire and detonation PDU's munition entity type fields to something known by the target. Suppose a Russian T-90 tank shoots at US M-60 tank. The simulation for the M-60 was written decades ago, before the T-90 was deployed, and the T-90 is using modern ammunition. The simulation that owns the M-60 does not recognize the type of ammunition, which hadn't even been invented at the time the simulation was written. It's often impractical to change the source code of the M-60 simulator. Instead we can use a gateway, such as JBUS, to change the fire and detonation munition type to something the M-60 simulator understands and that has a similar effect. The gateway is in effect a shim that we can insert between the simulators to patch up the interoperability problems. Note that this requires that we have a good understanding of what munitions the target simulator recognizes, and what their effects are.

Note that in this type of combat we don't have to create an entity for each bullet fired, and then have that bullet send ESPDUs while in flight. The ballistic flight of the munition can be modeled without this.

The DIS specification is intentionally vague on which simulation participants issue the fire and detonation PDUs. Almost always the simulation that owns the entity doing the shooting issues both of these PDUs. If you want to engage in specfication language lawyering a third participant could model the flight and issue the detonation PDU.

#### Shooting Missiles

Sometimes

#### Indirect Fire

#### Expendables, such as Chaff

####




