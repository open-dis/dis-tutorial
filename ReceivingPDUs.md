##Receiving PDUs

As with sending PDUs, receiving PDUs requires a little socket programming. Create a UDP socket, and then receive a datagram. Extract the payload, and then use the PDUFactory object to convert the DIS-formatted data into a Java object.

~~~~
import edu.nps.moves.disutil.CoordinateConversions; // Coordinate system utilities
import edu.nps.moves.disutil.*;
import edu.nps.moves.dis.*;

/**
 * Receives DIS PDUs and converts them to Java objects. 
 *
 * @author DMcG
 */
public class SimpleReceiver 
{
    
    /** Port we listen on */
    public static final int DIS_PORT = 3000;
    
    /** Broadcast Address. THIS IS SITE-SPECIFIC.  */
    public static final String BROADCAST_ADDRESS = "172.20.159.255";
    
/** Entry point */
public static void main(String args[])
{
    /** The PDUFactory object converts a binary DIS-format message to a Java object */
    PduFactory factory = new PduFactory();
    
    // mcast sockets are subclasses of datagram sockets
    MulticastSocket socket = null;
         
    // Set up a socket to receive data
    try
    {           
        socket = new MulticastSocket(DIS_PORT);
        
        while(true)
        {
           byte[] data = new byte[8000];
           packet = new DatagramPacket(data, data.length);
           
           socket.receive(packet);
           
           byte[] payload = packet.getData();
           Pdu aPdu = factory.createPdu(payload);
           
           // This could be any type of PDU, including ESPDU, fire, detonate, etc.
           System.out.println("Got PDU of type " + aPdu.getPduType());
           
           switch(aPdu.getPduType())
           {
              case 1:
                 EntityStatePdu espdu = (EntityStatePdu)aPdu;
                 break;
                 
              case 2:
                  FirePdu firePdu = (FirePdu)aPdu;
                  break;
                 
               // ... and so on for each PDU type
              default:
                 System.out.println("Unrecognized PDU type");
           }
        }
    }
    catch(Exception e)
    {
        System.out.println("Unable to initialize networking. Exiting.");
        System.out.println(e);
        System.exit(-1);
    }
    }
~~~~

The PduFactory object is responsible for parsing the binary data and converting the DIS formatted data into a Java object.

So far we have been putting one DIS PDU in one UDP datagram packet. However, it's relatively expensive to receive datagram packets. In high traffic DIS environments it makes sense to concatenate several PDUs together, and place them all in one datagram packet. This allows us to receive several PDUs for the cost of processing one datagram packet. This is called "PDU Bundling."


