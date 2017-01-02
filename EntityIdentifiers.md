##Entity Identifiers

A simulation may have hundreds or even thousands of entities in one virtual world. As a practical matter we need a way to uniquely identify each entity in the world. Before we can inform an entity that its position has been updated we need a way to uniquely identify the entity.

When DIS was designed a goal was for it to not have a central server. Simulations had to work out identifier issues among themselves, in a distrubted way. The solution hit upon was to use a collection of three unsigned shorts that would, together, uniquely identify an entity. These three numbers are the site ID, application ID, and entity ID. 

The simulation manager can during the planning phase assign identifiers for the site and application. For example, the simulation manager can specify these values for sites:

| Site       | ID |   |   |   |
|------------|----|---|---|---|
| Norfolk    | 17 |   |   |   |
| 29 Palms   | 23 |   |   |   |
| China Lake | 42 |   |   |   |

The numbers are arbitrary, but need to be agreed upon by all simulation participants. 
Likewise, the simulation manager can define some arbitrary values for applications:

| Application | ID   |   |   |   |
|-------------|------|---|---|---|
| JCATS       | 82   |   |   |   |
| OneSAF      | 1337 |   |   |   |
| VBS3        | 101  |   |   |   |

The final value of the Entity ID triplet is the entity value.

For example, a JCATS simulation at Norfolk that creates an entity may have an entity ID of (17, 82, 4576). A VBS3 simulator at China Lake may have an entity ID of (42, 101, 8472). 

This algorithm minimizes the conflicts that may occur. Instead of selecting from a large, single ID space, simulations only need to deconflict IDs at a single site, within a single application. The final value of the triplet, the entity number, is often selected randomly within the range of 1 to the maximum unsigned short value, 65535. Often simply a random selection from such a large ID space is good enough to prevent conflicts. More careful programmers can check to see if that entity ID has already been selected by another application by looking at the IDs of messages already received and processed.

This algorithm relies in part on consistent application of site and application IDs. For a single application at a single site, such as VBS3, coordinating site and application IDs is not as important, and these numbers can be configured in the application. 

At the time DIS was designed servers were still somewhat exotic software. In this day and age it is trivially easy to set up a web server that can provide the service of handing out unique IDs. A designer replicating DIS today would almost certainly choose this technique, but the installed base is what it is. And the "no-server" philosophy of DIS does have some benefits for interoperability. For small, simple simulations the odds are that a working interoperable simulation can be created out of the box without a server are good.