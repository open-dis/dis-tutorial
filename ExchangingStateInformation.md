## Exchanging State Information

Finally, after all that throat-clearing we can examine the programming required to send DIS PDUs.

Remember that DIS has no official API, and every implementation of DIS will have code that looks different. What counts is the format of the messages on the network, and any means that get the information into that format are fair game. The examples in this document will use open-dis, available at <a href="http://github.com/open-dis">http://github.com/open-dis</a>. Other implementations will have a different API.

### Examining DIS Messages

You can examine the format of packets after they have been sent by your program with a tool called WireShark, available at <a href="https://www.wireshark.org/">https://www.wireshark.org/</a>.

Wireshark is an invaluable tool, and not just for DIS. Your DIS program will send PDUs, but how do you know if they've been placed on the network correctly? For example, what if you incorrectly set an entity location to the local coordinate system instead of DIS's geocentric coordinate system?  Wireshark captures traffic, decodes it, and displays it in a human-readable format.

DIS is often sent on UDP broadcast port 3000, mostly for reasons relating to the historial installed base. DIS was approved and in use as a standard before IPv4 multicast was created, and as a result most early DIS simulations used broadcast. The practical reality is that DIS applications _should_ use multicast, but compatibility with existing applications often means they actually use broadcast.

When each of the example programs below is run, they will put DIS PDUs on UDP port 3000. After running a program that sends DIS you should start Wireshark and confirm that the traffic is correctly being sent to the network.

An example of Wireshark in action is shown below in figure x:

<img src="images/exchangingStateInformation/wireshark.jpeg"/>
Figure x

You can see the fields displayed by wireshark and their relevance to the theory discussed earlier: the entity location, in geocentric coordinates; the entity type; the timestamp field; and more.
