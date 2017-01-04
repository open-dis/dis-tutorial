##PDU Bundling

In the examples used so far, exactly one PDU has been placed in each UDP datagram. For high performance applications this is not always the best choice. DIS simulations may receive a lot of PDUs. A large constructive simulation can easily publish thousands of entities, and each may be updated many times per second. A simulation host receiving the PDUs has to process the incoming UDP packet, which can be somewhat expensive. 

The concept of "bundling" is that by placing several PDUs in a single UDP datagram message this overhead can be reduced. We can, for example, put ten different entity state PDUs in a single UDP datagram by simply concatenating the messages, one after the other, in one datagram. The receiver can parse the PDUs and turn them into ten different PDU programming language objects. This means the receiving host has to only handle the receipt of one UDP datagram rather than ten, but still has ten separate PDUs delivered to it.

This becomes important at high UDP datagram receipt rates. (Sending usually isn't a problem.) When a UDP datagram is received by the NIC the host operating system receives a hardware interrupt and processes the UDP packet. If interrupts are raised at too high of a rate the operating system chokes and gets very little network processing done; it's too busy handling interrupts to actually do anything. As a result the UDP receive buffer fills with incoming data, and then UDP packets start to be dropped by the host. (Which is allowed, because UDP is unreliable.) The number of UDP datagrams the operating system actually hands off to the simulation process drops off a cliff. When the scenario described happens it is not unusual to see 99%+ of the UDP packets dropped. Sending more packets just increases the number dropped.

Bundling reduces the number of hardware interrupts the operating system must handle and increases the number of PDUs the simulation can process. This is not a cost free solution. The sender has to wait for some period of time for enough PDUs to be put into a datagram, and this can increase latency. An ESPDU, for example, may not be immediately sent when the entity publishes it. It is instead placed into a buffer until either there are enough PDUs to make it worthwile, or a timer expires and the datagram is sent regardless of how many PDUs are ready to be transmitted. 

Also, there are some practical limits on the number of PDUs that can be placed in a single datagram that range from "a good idea" to "hard limit." It's a good idea to keep the UDP datagram size under the network's Maximum Transmission Unit (MTU) size. That's usually 1500 bytes for most ethernet networks, unless some special configuration to support "jumbo frames" has been done. The UDP packet header overhead also has to be accounted for, which reduces the space for actual PDUs to 1472 bytes. It's a good idea to leave some room for error here as well, unless you know what your network is doing in gory detail. 

Typical ESPDU size is 144 bytes per PDU. The maximum size any PDU can be is 8K.

Another "good idea" limit is 8K per UDP datagram. Very often sockets created by default have an 8K receive buffer. Unless the programmer is alert enough to change this it can result in more dropped datagrams. UDP datagrams that large risk packet fragmentation as well. 

A hard limit is 64K, the maximum size of a UDP datagram. 

There's no requirement that the PDUs in the UDP datagram be all of the same type. It's perfectly valid to put an entity state PDU, fire PDU, and detonation PDU in the same UDP datagram. 

It's somewhat tricker to parse the concatenated PDUs. If anything goes wrong parsing one of the PDUs at the start of the bundle it's likely the PDUs later in the bundle will have to be discarded.

[insert example here]

###Further Reading

A discussion of how the Linux kernel handles incoming UDP packets, including interrupt handling: <a href="https://access.redhat.com/sites/default/files/attachments/20150325_network_performance_tuning.pdf">https://access.redhat.com/sites/default/files/attachments/20150325_network_performance_tuning.pdf</a><br>

MTU: <a href="https://en.wikipedia.org/wiki/Maximum_transmission_unit">https://en.wikipedia.org/wiki/Maximum_transmission_unit</a>

Guessing the max practical UDP datagram size in complex networks. This is a bit pessimistic in that it assumes the packets are traveling across a fairly diverse network. DIS simulations often run in a lab with a more homogeneous network design: <a href="http://stackoverflow.com/questions/1098897/what-is-the-largest-safe-udp-packet-size-on-the-internet">http://stackoverflow.com/questions/1098897/what-is-the-largest-safe-udp-packet-size-on-the-internet</a>
