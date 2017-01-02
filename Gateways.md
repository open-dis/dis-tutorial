## Gateways
To address the issues that were identified in the "entity type" secion in a practical way, "gateways" have become a popular tool. A gateway sits between simulations, reading PDUs from one, examines the entity type records, and changes them on the fly before forwarding them to another simulation. Suppose simulation A is generating M1A1 Abrams tanks, but simulation B was written in such a way that it only handles M1A2 tanks. Can we make the two simulations interoperate?

It depends. If simulation B is only worried about the visual appearance of the tanks it displays, we can insert a gateway between the two simulations. This gateway will read PDUs from simulation A, and examine them for fields that contain references to M1A1 tanks. Whenever it finds such a value, it will change it to an M1A2 tank and forward it on to simulationi B, where it will appear as an M1A2. No changes to the source code of the simulations is needed, and in fact we don't need the source code or need to change any configuration files of the two simulations at all. The gateway acts as a shim between the two simulations.

On the other hand if the simulations depend on some intrinsic value of the tanks--such as the power of the M1A1's gun, or the effectiveness of its armor--we have other problems.

(Pedants will at this point dispute the use of the term "gateway" for this application, and instead claim that what is being described here is a "bridge." Academics insist that gateways translate between protocols, while bridges translate within protocols, and DIS is being used by both simulations. The term "gateway" is embedded in practice, so stop trying to fight that battle in this problem domain.)

Considerable work has been done on gateways. See Lutz & Co.  Some popular gateways include Joint Simulation Bus (JBUS) and AIME from NAVAIR. AIME is only somewhat incidentally a gateway. It's intent is to be a common API that hides the type of protocol being used, be it DIS or HLA. It just happens that it can be repurposed into a gateway.

###Further Reading

The John Hopkins site with an archive of gateway papers: <a href="https://msenterprise.jhuapl.edu/drupal/?q=node/39">JHU</a>

Joint Simulation Bus:<a href="http://www.alionscience.com/Technologies/Simulation-and-Training/JBUS">JBUS</a>. Free for government use, once you sign some papers and jump through some minimal hoops.

AIME:<a href="http://www.navair.navy.mil/nawctsd/Programs/Files/3-2015-AMIE.pdf">Slick on AIMIE</a>