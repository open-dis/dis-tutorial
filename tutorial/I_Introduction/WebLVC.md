## WebLVC

Web-based technology has become highly compelling in the last few years. Readers can confirm this by noting the degree to which the applications they use themselves today are web-based rather than compiled desktop applications. Vendors often make services available via the web rather than compiled, downloaded applications. Web applications often work across multiple operating systems and hosts with little extra work.

SISO runs a [WebLVC development group](https://www.sisostds.org/StandardsActivities/DevelopmentGroups/WebLVCPDG.aspx).

As the SISO group mentions, the WebLVC effort includes

>• An object-model independent section, which defines the common message headers and object-model-independent administrative messages, and defines a template for the kinds of messages that express object-model-specific data.

>• A Standard WebLVC Object Model section, which defines specific AttributeUpdate and Interaction messages (expressed in the JSON format), based on the semantics of the DIS protocol and the Real-time Platform Reference (RPR) FOM.  The Standard WebLVC Object Model is designed to allow a-priori interoperability between web applications, and federates that are built on these common, existing simulation standards.

>• A section describing the process and rules for hand-authoring new WebLVC messages based on extended or alternative object models.

>• A section describing rules for automatically generating WebLVC messages directly from an HLA FOM.

In the end, WebLVC helps define the network messages normally sent by HLA or DIS in JSON terms. This makes network simulation network messages easy to interpret in Javascript.

WebLVC is interesting, but remember that it also possible to send standard DIS messages to Javascript running inside the web page. The open-dis implementation of Javascript DIS can decode the binary PDU and turn it into a Javascript object. WebLVC in some ways resembles HLA messages, however, and can send out only the attributes of objects that have changed. This means that it can often use less bandwidth in a simulation, despite using text for the message format. JSON is also highly optimized; a lot of attention is paid to it.

See [jsperf](https://jsperf.com/javascript-dis-native-vs-json/2) for an interesting comparison in performance between binary messages and JSON. Still, on a laptop running a web browser it is claimed that over 50K messages per second can be decoded. That's more than can be used in a simulation. Also, note the extend to which different webbrowsers achieve different results.

