##Entity Type and Semantics

### Entity Type
When we receive an entity state PDU, how do we know what type of entity is being described? Is it a tank? An aircraft? How should we render it on the screen?

In DIS this problem was solved by using a record that contains a number of numeric fields. The values of the fields are arbitrary, but all simulations need to agree on their meaning. SISO maintains a document, the Enumerated and Bit-Encoded Values (EBV) document that maps these arbitrary numbers to semantic meanings.

Below is an entity type record that semanticaly describes a US M1A2 tank. Whenever this collection of values is encountered, we know that the entity being referred to is an M1A2 tank.

| Field Name | Value |
|--------|-----------|
| Entity Kind | 1 |
| Entity Domain | 1 |
| Country | 225 |
| Category | 1 |
| Subcategory | 1 |
| Specific | 6 |
| Extra | 0 |

<img src="images/EntityTypeEquivalency.jpg"/>

The entity kind refers to what type of entity this is. This document has been assuming that DIS entities are vehicles. DIS can describe more than vehicles, including munitions, life forms (such as whales, which are a problem in maritime sonar exercises), buildings, and minefields. In this case an M1A2 tank is a vehicle, which as a value of 1.

The entity domain refers to whether the entity is a land, air, surface (naval), subsurface, or space vehicle. Since an M1A2 tank is a land vehicle, and the SISO EBV document specifies this to be a value of 1, that is the value set in the field.

Every country (and most obscure dependencies) has a country code assigned to it. The US is country code 225, Hungary is 97, and Russia is 222. This particular M1A2 tank is a US vehicle, so the value of the field is set to 225.

The category is 1, which the EBV document specifies as a tank for this platform.

The subcategory is 1, an M1 Abrams.

The specific value is 6, an M1A2 tank.

The extra field is unused in this example.

The EBV document has a long listing of all the types of vehicles in all the militaries of the world, at least in theory. SISO actively maintains this list and change requests can be submitted for new equipment.

### Munitions

Just as the EBV document lists all the possible types of vehicles (in principle), it also lists all possible types of munitions (in principle). For example the munition record for a ballistic 155mm M485 illumination round is

| Field Name | Value |
|--------|-----------|
| Entity Kind | 2 |
| Entity Domain | 9 |
| Country | 225 |
| Category | 2 |
| Subcategory | 14 |
| Specific | 4 |
| Extra | 0 |

Other muntions have records with analogous values. When we encounter a munition type to assess the results of combat, we can use damage tables (defined outside of DIS--that's the responsiblity of the simulator) to determine the results.

### EBV Document

SISO maintains the EBV document in an XML format. Programmers can download it, then transform it to create programming language-friendly enumerations.

### Problems

In theory, all simulations respect the values listed in the EBV document. Reality falls short of theory.

No simulation implements all the entity types and munitions listed in the EBV document. It is simply impractical for a simulation to implement every one of the thousands of vehicles and munitions listed, so application authors write code to handle only the weapons they are likely to encounter. So what should happen if an ESPDU arrives, and has an entity type field that we do not recognize?

It's possible that the receiving application will simply discard the ESPDU for an entity that it does not recognize. If the simulation models tanks and we receive an ESPDU that describes a ship, it may be reasonable to simply discard the ESPDU; the authors make no attempt to display ships.

For other types of applications we may use a gateway. If we receive an ESPDU for a Russian BMP-3 IFV but can only display BMP-1 vehicles, it may make sense to set up a gateway that isolates the application from the direct network traffic of most other simulations, but also converts BMP-3 to BMP-1 ESPDUs before forwarding them to us. Obviously, this will not work unless we recognize the problem exists beforehand and configure the gateway accordingly. This may well be rational and reasonable. There are other potential problems such as when we are puzzled that the weapon we fire at the BMP-1 with has no effect. But it may still be a reasonable solution.

The EBV document has also evolved over time, and military simulations have very long product life cycles. This means that a simulation written in 1998 may interact with a simulation written in 2015, and in the intervening years new weapons have been added to the EBV document. The SISO group responsible for the EBV document tries hard for backwards compatibility, but a 1998 simulation handling 2015 weapons that the newer simulation is referring to is a different matter.

Sometimes simulation authors simply make up the enumerated values for entity and munition types. They expect to work only with their own simulation, and this approach works well enough at the time. A few years down the road it is discovered that they need to work with other simulations, and suddenly the semantic meaning of entity type records is no longer certain. Does the entity type that comes from a simulation with a made-up enumeration values represent an entity from the EBV document, or some private semantic meaning known only to the simulation author?

### Gateways

To address these issues in a practical way "gateways" have become a popular tool. See the "Gateways" section of this document.


Further Reading

SISO EBV document: <a href="https://www.sisostds.org/DesktopModules/Bring2mind/DMX/Download.aspx?Command=Core_Download&EntryId=42916&PortalId=0&TabId=105">EBV Document</a>. You can also retrieve the XML document.



