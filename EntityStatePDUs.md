###Entity State PDUs

An entity state PDU (ESPDU) represents the state of an object at one point in time. It includes its position, orientation, speed, and entity type. Refer to the earlier sections of this handbook for more information on these concepts.

I'll use Java in these examples, and try to keep them as stripped down as possible.

#### Sending ESPDUs

First of all, a complete program that sends DIS entity state PDUs.
Look it over, and I'll discuss some of the details below.

~~~~
package edu.nps.moves.examples;

import java.io.*;
import java.net.*;
import java.util.*;

// These are open-dis classes
import edu.nps.moves.dis.*;                         // All PDUs, and records within PDUs
import edu.nps.moves.disutil.CoordinateConversions; // Coordinate system utilities
import edu.nps.moves.disutil.DisTime;               // Timestamp utility

/**
 * Creates and sends ESPDUs in IEEE binary format. Tried to make
 * it as simple as possible for something semi-real.
 *
 * @author DMcG
 */
public class SimpleSender 
{
    /** How many espdus to send */
    public static final int NUMBER_TO_SEND = 5000;

    /** Port we send to */
    public static final int DIS_DESTINATION_PORT = 3000;
    
/** Entry point */
public static void main(String args[])
{
    /** an entity state pdu */
    EntityStatePdu espdu = new EntityStatePdu();
    // mcast sockets are subclasses of datagram sockets
    MulticastSocket socket = null;
    
    // Utility class for working with DIS concepts of timestamps
    DisTime disTime = DisTime.getInstance();
    
    // ICBM coordinates for my office
    double lat = 36.595517; 
    double lon = -121.877000;
    
    // All system properties, passed in on the command line via -Dattribute=value
    Properties systemProperties = System.getProperties();
    
    // Set up a socket to send information
    try
    {           
        socket = new MulticastSocket(DIS_DESTINATION_PORT);
    }
    catch(Exception e)
    {
        System.out.println("Unable to initialize networking. Exiting.");
        System.out.println(e);
        System.exit(-1);
    }
    
    // Initialize values in the Entity State PDU object. The exercise ID is 
    // a way to differentiate between different virtual worlds on one network.
    // Note that some values (such as the PDU type and PDU family) are set
    // automatically when you create the ESPDU.
    espdu.setExerciseID((short)1);
    
    // The EID is the unique identifier for objects in the world. This 
    // EID should match up with the ID for the object specified in the 
    // world.
    EntityID eid = espdu.getEntityID();
    eid.setSite(1);        // 0 is not a valid site number, per the spec
    eid.setApplication(1); 
    eid.setEntity(2); 
    
    // Set the entity type. SISO has a big list of enumerations, so that by
    // specifying various numbers we can say this is an M1A2 American tank,
    // the USS Enterprise, and so on. We'll make this a tank. There is a 
    // separate project elsehwhere in this project that implements DIS 
    // enumerations in C++ and Java, but to keep things simple we just use
    // numbers here.
    EntityType entityType = espdu.getEntityType();
    entityType.setEntityKind((short)1);      // Platform (vs lifeform, munition, sensor, etc.)
    entityType.setCountry(225);              // USA
    entityType.setDomain((short)1);          // Land (vs air, surface, subsurface, space)
    entityType.setCategory((short)1);        // Tank
    entityType.setSubcategory((short)1);     // M1 Abrams
    entityType.setSpec((short)3);            // M1A2 Abrams
   
    // Loop through sending N ESPDUs
    try
    {
        for(int idx = 0; idx < NUMBER_TO_SEND; idx++)
        {
            // DIS time is a pain in the ass. DIS time units are 2^31-1 units per
            // hour, and time is set to DIS time units from the top of the hour. 
            // This means that if you start sending just before the top of the hour
            // the time units can roll over to zero as you are sending. The receivers
            // (especially homegrown ones) are often not able to detect rollover
            // and may start discarding packets as dupes or out of order. 
            // The DIS standard for time is often ignored in the wild; I've seen
            // people use Unix time (seconds since 1970) and more. Or you can
            // just stuff idx into the timestamp field to get something that is monotonically
            // increasing.
            
            // Note that timestamp is used to detect duplicate and out of order packets. 
            // That means if you DON'T change the timestamp, many implementations will simply
            // discard subsequent packets that have an identical timestamp. Also, if they
            // receive a PDU with an timestamp lower than the last one they received, they
            // may discard it as an earlier, out-of-order PDU. So you should 
            // update the timestamp on ALL packets sent.
            
            // An alterative approach: actually follow the standard. It's a crazy concept,
            // but it might just work.
            int timestamp = disTime.getDisAbsoluteTimestamp();
            espdu.setTimestamp(timestamp);
            
            // Set the position of the entity in the world. DIS uses a cartesian 
            // coordinate system with the origin at the center of the earth, the x
            // axis out at the equator and prime meridian, y out at the equator and
            // 90 deg east, and z up and out the north pole. To place an object on
            // the earth's surface you also need a model for the shape of the earth
            // (it's not a sphere.) All the fancy math necessary to do this is in
            // the SEDRIS SRM package. There are also some one-off formulas for 
            // doing conversions from, for example, lat/lon/altitude to DIS coordinates.
            // Here we use those one-off formulas, in the CoordinateConversions class.

            // Convert lat/lon/alt to DIS coordinates using a class I wrote
                        
            double disCoordinates[] = CoordinateConversions.getXYZfromLatLonDegrees(lat, lon, 1.0);
            Vector3Double location = espdu.getEntityLocation();
            location.setX(disCoordinates[0]);
            location.setY(disCoordinates[1]);
            location.setZ(disCoordinates[2]);
            
            System.out.println("lat, lon:" + lat + ", " + lon);
            System.out.println("DIS coord:" + disCoordinates[0] + ", " + disCoordinates[1] + ", " + disCoordinates[2]);
            
            // You can set other ESPDU values here, such as the velocity, acceleration,
            // and so on.

            // Marshal out the espdu object to a byte array, then send a datagram
            // packet with that data in it.
            
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            DataOutputStream dos = new DataOutputStream(baos);
            espdu.marshal(dos);
            
            // The byte array here is the packet in DIS format. We put that into a 
            // datagram and send it.
            byte[] data = baos.toByteArray();
            DatagramPacket packet = new DatagramPacket(data, data.length, InetAddress.getByName("255.255.255.255"), 3000);
            socket.send(packet);
            
            // Send every 1 sec. Otherwise this will be all over in a fraction of a second.
            Thread.sleep(1000);

         }
    }
    catch(Exception e)
    {
        System.out.println(e);
    }
        
}

}
~~~~

#### Discussion

OK, some of the details:

~~~~
 EntityStatePdu espdu = new EntityStatePdu();
~~~~

This creates a new Entity State PDU object. It includes all the default fields of an ESPDU, including the PDU header fields, entity position field, orientation field, entity type fields, and so on. It has the logic to marshal itself to IEEE 1278.1 DIS binary format, and to convert from the DIS standard array of bytes back to a Java object.

~~~~
// The EID is the unique identifier for objects in the world. This 
// EID should match up with the ID for the object specified in the 
// world.
EntityID eid = espdu.getEntityID();
eid.setSite(1);        // 0 is not a valid site number, per the spec
eid.setApplication(1); 
eid.setEntity(2); 
~~~~

This is an example of setting field values in the ESPDU. The EntityStatePdu object contains another object, named entityID. There's a getter and setter method in EntityStatePdu that retrieves this object. Once retrieved we can set it. Equivalent syntax is

~~~~
espdu.getEntityID().setSite(1);
espdu.getEntityID().setApplication(1);
espdu.getEntityID().setEntity(2);
~~~~

Whichever you prefer. 

We set the type of entity that this refers to. The ESPDU is updating the other simulation participants about the state of an object, and part of that state information is what type of object this is. The values we set this to come from the SISO EBV document, in this case for an M1A2 tank.

~~~~
EntityType entityType = espdu.getEntityType();
entityType.setEntityKind((short)1);      // Platform (vs lifeform, munition, sensor, etc.)
entityType.setCountry(225);              // USA
entityType.setDomain((short)1);          // Land (vs air, surface, subsurface, space)
entityType.setCategory((short)1);        // Tank
entityType.setSubcategory((short)1);     // M1 Abrams
entityType.setSpec((short)3);            // M1A2 Abrams
~~~~

Next we'll set the position. In this case, we'll specify that the location of the tank is just outside my office in Monterey, CA.

~~~~
 double disCoordinates[] = CoordinateConversions.getXYZfromLatLonDegrees(lat, lon, 1.0);
Vector3Double location = espdu.getEntityLocation();
location.setX(disCoordinates[0]);
location.setY(disCoordinates[1]);
location.setZ(disCoordinates[2]);
~~~~

I'm using a utility class called CoordinateConversions here. It uses the formulas discussed earlier to convert from a latitude, longitude, and altitude to the DIS geocentric coordinate system. The array returned contains the geocentric coordinate system equivalent of my office's position. We set the values as before.

Since one UDP packet may be duplicated or arrive out of order on the receiving side, DIS includes a timestamp field in the PDU. This is used to detect duplicate or out of order packets. DIS chose to use an odd system of timestamps: time since the top of the hour, in an arbitrary unit defined as 2^31-1 units per hour. Setting the timestamp is important. If you don't set it, receiviers will assume that they're getting duplicate packets, and discard them. Since DIS time is somewhat unusual, I've created a utility class that works with DIS time. In this case, it determines the DIS time (time since top of the hour) and then we set the appropriate field in the ESPDU.

~~~~
int timestamp = disTime.getDisAbsoluteTimestamp();
espdu.setTimestamp(timestamp);
~~~~

At this point we have a mostly-filled out ESPDU, but it's a Java object, while the standard demands that it be an array of bytes in a very specific format. The Java EntityStatePdu object is smart enough to convert itself into that format:

~~~~
ByteArrayOutputStream baos = new ByteArrayOutputStream();
DataOutputStream dos = new DataOutputStream(baos);
espdu.marshal(dos);
byte[] data = baos.toByteArray();
~~~~

The "data" object is an array of bytes that is in the DIS message format.

One problem with all this is that programmers never remember to set the timestamp. There's an alternative method for marhsalling with the timestamp automatically set:

~~~~
byte[] data = espdu.marshalWithDisAbsoluteTimestamp()
~~~~

This automatically sets the timestamp and converts the Java object into an IEEE DIS messaage. It replaces the two steps shown above: determining and setting the timestamp, and marshalling the ESPDU object to a byte array.

At this point we can send the message on broadcast port 3000:

~~~~
DatagramPacket packet = new DatagramPacket(data, data.length, InetAddress.getByName("255.255.255.255"), 3000);
socket.send(packet);
~~~~

We create a datagram packet that contains the DIS message, then send it on port 3000 to address "255.255.255.255". This is a somewhat dodgy network programming technique, and it may fail in some environments. The problem is that the broadcast address varies from location to location, and in fact a single host may have multiple network interfaces, each with a different broadcast address. A better way to do this is to walk the interfaces in java, and find the actual broadcast address for each interface.

