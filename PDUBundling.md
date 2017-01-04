##PDU Bundling

In the examples used so far, exactly one PDU has been placed in each UDP datagram. For high performance applications this is not always the best choice. DIS simulations may receive a lot of PDUs. A large constructive simulation can easily publish thousands of entities, and each may be updated many times per second. A simulation host receiving the PDUs has to process the incoming UDP packet, which can be somewhat expensive. 

The concept of "bundling" is that by placing several PDUs in a single UDP datagram message this overhead can be reduced. We can, for example, put ten different entity state PDUs in a single UDP datagram by simply concatenating the messages, one after the other, in one datagram. The receiver can parse the PDUs and turn them into ten different PDU programming language objects. This means the receiving host has to only handle the receipt of one UDP datagram rather than ten. 

This becomes important at high PDU receiving rates. (Sending usually isn't a problem.) The host operating system receives a hardware interrupt and processes the packet. If interrupts are raised at too high of a rate the operating system chokes and gets very little network processing done; it's too busy handling interrupts to actually do anything. As a result the UDP receive buffer fills with incoming data, and then UDP packets start to be dropped by the host. (Which is allowed, because UDP is unreliable.) The number of UDP datagrams the operating system actually hands off to the simulation process drops off a cliff. When the scenario described happens it is not unusual to see 99%+ of the UDP packets dropped. Sending more packets just increases the number dropped.

Bundling reduces the number of hardware interrupts the operating system must handle and increases the number of PDUs the simulation can process. This is not a cost free solution. The sender has to wait for some period of time for enough PDUs to be put into a datagram, and this can increase latency. An ESPDU, for example, may not be immediately sent when the entity publishes it. It is instead placed into a buffer until either there are enough PDUs to make it worthwile, or a timer expires and the datagram is sent regardless of how many PDUs are ready to be transmitted.

There's no requirement that the PDUs in the UDP datagram be all of the same type. It's perfectly valid to put an entity state PDU, fire PDU, and detonation PDU in the same UDP datagram. 

It's somewhat tricker to parse the concatenated PDUs. If anything goes wrong in one of the PDUs at the start of the bundle it's likely the PDUs later in the bundle will have to be discarded.

[insert example here]

