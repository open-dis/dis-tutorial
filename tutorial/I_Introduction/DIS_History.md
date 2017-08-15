## DIS History

DIS arose from a Defense Advanced Research Agency (DARPA) project in the 1980's called SIMNET. At the time TCP/IP and high speed networks were just getting their legs, computers and networks were becoming powerful enough to do the computational operations needed, and 3D graphics was in its infancy. 

A screen capture from an early SIMNET application is shown below:

<img src="I_Introduction/images/SimnetDisplay.jpg"/>

Each participant is in a SIMNET application controlled a tank, and each simulator views the shared virutal battlefield. All the vehicles interacted in the same shared enviroment. If one simulator causes the tank it controls to move, the other partipants see that movement, in real time. 

The simulators of the era sometimes had displays that replicated a soldier's view of the battlefield, but the host running the simulation wasn't networked with other hosts. Each simulator worked in isolation, and an aircraft simulator couldn't see a tank controlled by another simulator. The idea of SIMNET--quite advanced for the time--was to create a virtual, shared battlefield in which all participants on multiple computers could see and interact with each other. SIMNET's major accomplishment--it was arguably one of the first large real-time distirubted virtual world--was to serve as a basis for the research that allowed DIS to happen. 

DARPA projects were intended to transition out of the incubator research phase and into useful actual implementations. The SIMNET project worked out many of the state information exchange issues that were needed. Once that was done it needed to be standardized and refined outside of DARPA. The group that would eventually do this was Simulation Interoperability Standards Group (SISO) that took over development of the network protocol portion of the project, which they renamed to DIS. SISO developed DIS in a series of workshops held from 1989 to 1996. Once the protocol was developed they took the relevant documents to the IEEE standards group and achieved DIS standard approval.

In today's commercial game world games like "Call of Duty" or "World of Tanks" do shared environments between hosts routinely. The companies that own these games make a lot of money selling such applications to the public. At the time of SIMNET the concept of a shared, networked environment was revolutionary.
