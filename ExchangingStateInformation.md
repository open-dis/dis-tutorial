##Exchanging State Information

Finally, after all that throat-clearing we can write some code. 

Remember, DIS has no official API for sending and receiving PDUs. What counts is the format of the messages on the network, and any means to get data into that format are fair game. The examples in this document will use open-dis, available at <a href="http://github.com/open-dis">http://github.com/open-dis</a>. Other implementations will have a different API.

You can examine the format of packets on the wire with a tool called WireShark, available at <a href="https://www.wireshark.org/">https://www.wireshark.org/</a>. Wireshark is an invaluable tool, and not just for DIS. It can listen on all traffic on the network, and provides "dissectors" to convert from whatever format is being used to something more readable. Since DIS is a binary protocol, the dissectors in Wireshark save a lot of time that would otherwise be spent manually decoding packets. DIS typically is sent on UDP broadcast port 3000.
