### Coordinate Systems

#### Location
DIS is mostly about the position of physical entities in the world. This brings up an obvious but important question: what coordinate system do we use to describe an entity's location?

First person shooter games like Call of Duty or World of Warcraft move enties in 3D worlds, but the positions of entities in games like this do not correspond to real positions on earth. Game developers can use a coordinate system that assumes the world is infinitely flat in all directions, for example. We also don't have to match the position of entities published by a virtual or constructive simulation to a real position on earth. Imagine a live ship position feed like Automatic Information System (AIS) that transmits the locations of commercial vessels. We want to fly a virtual aircraft over San Francisco bay and view, from the cockpit, live shipping in the bay. The virtual aircraft and the live ship feed need a common coordinate system. What's more, if the area in which the simulation operates is large enough we need to account for things like the curvature of the earth. 

So what coordinate system should be used? DIS has been used in many domains, including sea, subsurface, air, land, and space.  If the simulation's geographic extent is large enough the curvature of the earth can't be ignored. Also, for reasons of convienence we want to use a coordinate system that makes local physics calculations easy. We should also settle on either metric or English units. These goals are in conflict with each other, and some tradeoffs need to be made.

A simulation limted to land operations might choose MGRS. This does not work well for aircraft simulations, where the altitude of an entity is not restricted to the surface of the earth. Naval operations might choose latitude/longitude, but this also does not work well for air operations or space operations. Expressing velocity or doing other physics calculations in either of these coordinate systems is a mess.

DIS chose to use a Cartesian coordinate system with its origin at the center of the earth, and to use meters as the unit of measurement *for positions put out on the network*. The X-axis of this coordinate system points out from the center of the earth and intersects the surface of the earth at the equator and prime meridian. The Y-axis likewise intersects the earth at the equator, but at 90 degrees east longitude. The Z-axis points up through the north pole.

<img src="images/DISCoordinateSystem.jpg"/>

This seems like an odd choice at first glance, but a key caveat is that the position of entities are described in this coordinate system in DIS PDUs *sent on the network*. Simulations can use any coordinate system they like internally. The geocentric coordinate system is in isolation not very convenient, but other coordinate systems can be converted to and from it via some math. Most simulations use a local rectilinear coordinate system for physics, then, before sending the position of the entity to the network, convert it from the local coordinate system to the global, geocentric coordinate system. The math to do these operations is well-understood and efficient.

For example, a simulation might find it convenient to set up a local, rectilinear coordinate system at a given latitude, longitude, and altitude, tangent to the surface of the earth.

<img src="images/LocalCoordinateSystem.jpg"/>

This coordinate system is rectilinear and doesn't take into account the curvature of the earth, but for most simulation purposes it works when entities are within a few kilometers of each other. More importantly, it's mathematically tractable, and easy to work with in the context of most graphics packages. We can make the local simulation's coordinate system co-extensive with the graphics package coordinate system. If we're using a 3D graphics system like Unity or X3D we can make the graphics package coordinate system exactly match that of the tangent plane we set up.  We can easily move an entity one meter along the X-axis in the local coordinate system.  When we describe the position of the entity to other simulations by sending an entity state PDU we convert the position of the entity from the local coordinate system to the global, geocentric coordinate system, and place that in the ESPDU when we send it. 

Many simulations use a North, East, Up (NEU) mapping for the local coordinate  system axes, with north along the X-axis, east along the Y-axis, and Z pointing up from the surface of the earth. There's not much agreement on which way the coordinate axes point, though. Aircraft often use a local coordinate system that puts the origin at the CG of the aircraft, with the X-axis pointing out the nose, the Y-axis out the right wing, and the Z-axis pointing down, for example. These conventions can be accomodated with enough math.

<img src="images/CoordinateSystemTransformation.jpg"/>

In this example the position of a tank entity is described in several different coordinate systems. In the local coordinate system--the coordinate system used for most physics and graphics--it's at (10, 10, 4). In geodetic coordinates it's at latitude 43.21, longitude 78.12, and altitude 124. In UTM it's zone 44N, 266061E, 44788172N, 124m. In DIS coordinates it's at (958506, 455637, 4344627). Each of the positions describes the same point in space using different coordinate systems, and we can (with enough math) translate between them.

DIS simulations usually do all their local physics calculations and graphics displays in the local coordinate system. When the ESPDU is being prepared to be sent the position of the entity in the local coordinate system is transformed to the DIS global coordinate system, and then set in the ESPDU. When received by the simulation on the other side, that simulation translates from the global coordinate system to whatever its own local coordinate system is.

There are a few wrinkles in this. While the geocentric coordinate system origin is placed at the center of the earth, it does not by itself define where the surface of the earth is. The earth is not a sphere, but rather a somewhat flattened egg-shaped surface. There are several mathematical models used in geodesy used to describe the shape of the earth. The most popular of these is called WGS-84. It's the model used in GPS, but there are an annoying number of other models in use that may crop up. 

WGS-84 defines an oblate spheroid. The earth is not smooth, and terrain can rise above or below the geoid, as with Mount Everest or the Dead Sea or the bottom of the Atlantic Ocean.

Terrain is a tricky problem in itself and outside the scope (for now) of this document. Simulations need precise placement of objects, often to sub-meter accuracy. Getting agreement on this between simulations that use terrain information from different sources is very difficult. Most simulations hack this lack of accuracy by using *ground clamping*. If an entity such as a tank is described by a companion simulation as being a meter above the ground on the local simulation, the local simulation will simply force it to be drawn as in contact with the ground. This avoids the problem of "hover tanks" that appear to float above the terrain, an artifact that would undermine user confidence in the simulation.

There are several packages that convert between the coordinate systems discussed above--geocentric, geodetic, and MGRS. One popular package is the SEDRIS SRM package. 

<a href="http://www.sedris.org/srm_desc.htm">Sedris SRM site</a>

The SEDRIS site includes tutorials about the theory behind the process and for using the Java and C++ packages they provide.

##### Shut up and give me the equation

To convert latitude, longitude, and altitude to the DIS geocentric ("Earth-Centered, Earth Fixed") coordinate system:

<img src="images/LatLonAltToECEF.jpg">

Remember, angles are in radians here. Alpha is latitude, omega is the longitude, a is the semi-major axis of the WGS-84 specification, 6378137, and b, the semi-minor axis of WGS-84, is 6356752.3142.

Converting from DIS coordinates to latitude, longitude, and altitude is a little tricker.

First, longitude:<br>
<img src="images/LongitudeFromXYZ.jpg">

Next, latitude. This can be done iteratively for better precision but one iteration gives about five decimal places of accuracy:

<img src="images/LatitudeFromXYZ.jpg"/>

Finally, altitude:<br>
<img src="images/AltitudeFromXYZ.jpg"/>

#### Orientation
We can place an entity in the world, but how do we know which way it's facing? In the case of DIS, the convention is to express entity location in terms of sequential rotations about coordinate axes. 

The record expressing orientation has fields for psi, theta, and phi. These represent angles, expressed in radians, in the entity's coordinate system. First, rotate psi radians around the z-axis, then theta radians around the y-axis, and finally phi radians around the x-axis. The final state, after three rotations, is shown in the image below:

<img src="images/EulerAngles.jpg"/>

The Austalian Defense Force has published a fine paper on the mathemtatics involved, including the use of quaternions to aid in computation. See the Kok paper below in "further readings."

### Further Reading

Sedris SRM package: <a href="http://www.sedris.org/srm_desc.htm">Sedris SRM site</a><br>

SRM Tutorial: <a href="https://www.youtube.com/watch?v=mFFfO-NJMFI">Youtube Tutorial</a><br>

SRM Tutorial, hardcopy: <a href="http://www.sedris.org/stc/2000/tu/srm/tsld003.htm">Hardcopy slides</a><br>

DTIC manual for coordinate system transformations: <a href="http://www.dtic.mil/dtic/tr/fulltext/u2/a307127.pdf">DTIC Manaul</a><br>

Coordinate System Transformation theory: <a href="http://www.springer.com/cda/content/document/cda_downloaddocument/9780857296344-c2.pdf?SGWID=0-0-45-1143141-p174116371">Book Chapter</a>

"Using rotations to build aerospace coordinate systems", Kok: <a href="documents/UsingRotationsToBuildAerospaceCoordinateSystems.pdf">Australian Defence Force paper</a>
 