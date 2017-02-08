##Scalablity

How many participants can we have in a DIS simulation? Two or three entities is useful for teaching applications, but as soon as we can get a small NVE to work we immediately start to think about just how many we can handle. 

Scalability can be important for some military applications, though not all. If we're trying to train for call of indirect fire then being able to handle only a few participants may be fine. Often virtual simulations such as flight simulators or vehicle trainers don't need large numbers of participants because the usefulness of the virtual aspect is limited to those entities that can be directly viewed by a person. We don't necessarily need a virtual simulation to display 10,000 entities. 

In contrast a US Army combat brigade may have thousands of vehicles, and we can usefully display their positions on a map. Scaling to such a massive size can also be done through the use of unit aggregation techniques. Instead of having 14 tanks in a tank company each sending state updates, we have a single, aggregated tank company represented in the simulation that sends updates for the unit as a whole. The lack of entity-level information can create other problems. Suppose a virtual UAV flies over a battlefield. What does the camera display show? Individual tanks or a symbol that represents a tank company?

Entity-based corps or theater level simulations can have tens or hundreds of thousands of entities. What is the practical limit for the size of an entity-based, distributed simulation?

###Massively Multiplayer Games

There are some analogs to large military simulations in the entertainment industry, namely Massively Multiplayer Online Games (MMOGs) such as World of Warcraft, EVE Online, or No Man's Sky. MMOGs and games in general use many of the same technolgies as distributed military simulations. In fact, the line between games and training simulations is blurred in the category of "serious games." The main thing that distinguishes games from simualation is the intent of the application; the technolgies used, including distributed virtual environments, use almost exactly the same underlying technologies. 

MMOGs are an interesting topic but a bit out of scope for this discussion. DoD is effectively restricted to using established military standards, and strives to _not_ use clever but non-standard approaches. Interoperability and stability of the code base over a period of decades is usually more important to us than sheer scalability. The good news is that the entertainment industry has shown NVEs can scale to large size. The bad news is that the longevity and amenability to standards work is questionable.

Still, MMOG's are clearly the technology leader in the market segment, and game companies will often spend more than a large military simulation program does to develop a class A title. Rolling out a new and large MMOG game like World of Warcraft may cost hundreds of millions of dollars in game content, programming, and servers, and they are quite good at it. 

See the "Further Reading" section for some details on the technologies the entertainment companies are using. 

####Networking

One of the central problems to solve in a large NVE is keeping state updates down to a reasonable level. If too many state updates are sent we'll either flood the network or overwhelm the ability of a host to receive, parse, and process state updates.

 




###Further Reading
EVE Online Scaling: http://www.talkunafraid.co.uk/2010/01/eve-scalability-explained/

More EVE Online scaling, from EVE engineers: http://www.ics.uci.edu/~avaladar/papers/brandt.pdf

Cambridge PhD on scalability: https://www.microsoft.com/en-us/research/publication/distributed-virtual-environment-scalability-and-security/
