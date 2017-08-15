## Simulation Terminology

There are a number of terms floating around in the simulation world, and that's largely the result of the different purposes to which simulations are put. With DIS, the traditional use was what was called "virtual worlds." Those used 3D computer graphics to display something that resembled a live video feed as closely as possible. Ideally, a viewer of the display could not tell the difference between the 3D graphics application, which displayed a collection of entities whose position and orientation was updated by DIS, and a live video pointed at a live exercise. Of course the computer graphics feed wasn't close to solving this problem in the 1990's, but that was the ultimate goal.

Over time it was realized that DIS could be used to achieve other goals. Everything from purely analytical applications of DIS, which assume that there is no graphical result intended at all, to augmented reality, which has some mix between live video and DIS-related graphics. Furthermore the simulations could include either a single user or a great many networked application elements.

### Implementation Range

The image below shows something about how graphics are used in simulation applications, for what purpose. This primarily is related to whether 3D grahics that try to create real world appearances are generated, by how many simulation hosts.

![Problem Graphics: I_Introduction/images/VirtualGraphicsSpread.jpg](I_Introduction/images/VirtualGraphicsSpread.jpg)

This is primarily an attempt to define the terminology used (at least by some) when related to grahics.

#### Analytical, No Display, Single Host
Imagine a single host that creates a description of a combat operation. The simulation is so simple that there is no attempt to use more than one host to create the simulation, and what's more the user does not care about any graphical display of what is happening in the simulation. The traffic is instead simply saved to a database, where the combat operation is assessed after the fact, textually. There's no effort present any display to the user. What's more, because there is only one host generating simulaton traffic it is not particularly necessary to use one of the classic features of DIS, the conversational exchange of messages between hosts.

This can be thought of as the most simple simulaton example possible. The single application generates simulation operatin data, saves each message to a database, and later can play back the simulation contents. There's no attempt to show the simulation to the users in a realistic graphics display. Instead there is perhaps some classic operations research that later assesses the saved data.  

#### Anaylytical, Multiple Hosts

Very similar to a single analytical simulation generation host, but instead of one, the simulation may use several.  DIS is more valuable in this scenario; multiple applications working together was an important feature from the start. As with other analytical operations, there is no attempt to use the traffic of the multiple simulation hosts to show anything graphical to the user. The simulation generally uses data operations to write messages to a database, and later reads the data back textually to analyze the simulation.

#### Command and Control Graphics

This is where it starts to become interestng. The simulation is presenting graphical results to users, but those graphics are not an attempt to create realistic displays. Instead the simulation graphics requirements may be met through displays of object or unit locations. The simulation users are satisfied if they can know the position of objects and units. Instead of a realistic display of a tank, the simulation requirements are satisified if there is a map-based display that shows the position of all the tanks in a unit, or the positions of several units. The objective is not to convince the user he is on the battlefield, but to show what the battlefield is up to.

An very simple display of the concept that uses the web-based Open Street Maps Javascript library is shown below. DIS messages are received from the network, and the web page shows unit locations. There is no attempt to make the unit look realistic, only make its location realistic. 

![Problem Graphics: _Introduction/images/MapDisDisplay.jpg](I_Introduction/images/MapDisDisplay.jpg)

#### Virtual, Single Host

This is where the application is beginning to create graphics that are, in principle or objective, similar to a live video feed. Back in the early 90's there was an game called "DOOM"; it had a mode in which a single application showed a 3D graphics display to the user, similar to the scene shown below.

![Problem Graphics: (I_Introduction/images/doom-ii.jpg](I_Introduction/images/doom-ii.jpg)

This shows a chainsaw attack on a monster by the player. (DOOM used it's own, message format, not DIS.) There need be no other host in the simulation. How realistic is it? For the early 90's, not that bad! There are definitions of "virtual" in software development that include "not physically existing as such but made by software to appear to do so." In this case DOOM was creating, for the 90's,  virtual grahical content, generated by a single host. Users were placed in graphics environments that were emotionally realistic for the era.

#### Networked Virtual Environment

This is often the environment in which DIS use crops up. While the game DOOM was often running on a single host, DIS often runs on multiple hosts. The situation can be described by the term "Networked Virtual Environment." Any simulation may have several processes on several hosts running, some of which use 3D graphics to display a virtual world. One better than that available to DOOM in 1993. Examples of the use of Networked Virtual Environment (NVE) include the book title of Mike Zyda and Sandeep Singhal's book, "Networked Virtual Environments: Design and Implementation." The term is widely used in academic papers. 

An example of a NVE (not necessarily using DIS) is below. This is an example from VR-Engage from the company [MaK](https://www.mak.com/).

![Problem Grahics: I_Introduction/images/VREngage_mak.jpg](I_Introduction/images/VREngage_mak.jpg)

Note that the 3D display is a bit more realistic than that of DOOM.

#### Augmented Reality

Augmented Reality newly developing software, at least in the commercial implementation sense. Augmented reality started in research years ago, but is not on the verge of widespread commercial deployment. At this time the augmented reality applications may include offerings from Facebook or Microsoft's HoloLens. There is also future augmented reality technology rumored to be offered from the companies Magic Leap and Apple, as well as future advances from existing vendors. Phones and other mobile devices are likely to be the platforms addressed. 

The aspect of augmented reality that is different from virutal reality or NVEs is that it combines a live video feed with a computer-generated 3D display. A good example of the technology is, oddly enough, the game Pokemon running on an Apple iPhone. Examples are shown below:

![Problem Graphics: I_Introduction/images/pokemanCapture.jpg](I_Introduction/images/pokemanCapture.jpg)

In the Pokemon game this scene involved capture of the creature through interaction with the 3D model as it was dispalyed on the live video feed. The game proved so popular there were crowds of hundreds in popular "monster" areas.  The 3D model is used as a target for capture. 

For DoD applications one can easily imagine the 3D model of an enemy combatant that may be addressed somehow by an augmented reality application user. DoD developers are likely to supply some sort of products performing roughly this task.

#### Video

The simulation gets a live video feed. There is no input into the feed, though the source of the  feed may be selected by simulation or live data.

### Summary

The most common application term in the DIS world is "Networked Virual Environment (NVE)." The objective of DIS is very often to have a 3D display presented to the simulation user that is virtually correct; a 3D world that is in principle identical to the real world, a *virtually correct* world. But at the same time one can't assume DIS is unique to that. It can easily be used in an analytic simulation, or perhaps, not very long from now as the commercial market matures, a useful tool in an augmented reality simulation.  




