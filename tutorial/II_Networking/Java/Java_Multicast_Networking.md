# Java Multicast Networking

This is an example of using Java at a lower API level to send and receive
binary data. The example code presented here uses NetBeans, a free development system available at http://netbeans.org.

The source code does not transmit actual DIS PDUs. Instead, only simple binary data is transmitted. The objective to to demonstrate the use of multicast sockets to transmit data, not specifically DIS. Adding DIS was thought to increase the source code used and obscure the use of sockets. Instead, only 355 lines of source are used, which makes the code purpose more understandable.

A single run of the application has two threads active: one thread sends data every ten seconds, and the other thread reads from the multicast socket. The sending thread writes to the socket on multicast address "239.1.2.3" and the receiver reads any messages sent to that address. One message is sent every ten seconds.

If the same application is run on two different hosts each will receive the messages of the other. Running on a single host the host will receive all the messages sent by that host.

The multicast socket can subscribe to more than one multicast address. As it stands now, it will not read messages sent to the destination address "239.1.2.100". It could if the multicast socket performed a "joinGroup" for that address.

Download source code from this URL:

[Source Code for Java Multicast Example](https://github.com/mcgredonps/DIS_Tutorial_Multicast_Example)