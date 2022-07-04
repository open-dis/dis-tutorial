# Distributed Interactive Simulation: The Missing Handbook

## Disclaimers

1. Work in progress (active someday again, we hope). Everything is uncertain at this point. I'm not sure what will work and what will not. Full of typos, not yet to first draft status, footnotes are a mess, prose is lousy, etc. 
1. The objective is to get content that can be updated by many experts, and a document structure that can help pull that off.
1. Note that we are comparing the use of GitHub Wiki and GitHub Pages technologies for this tutorial. Both are in use and not in sync.
	1. The tutorial pages kept in the Wiki can be checked out with git (do a checkout on https://github.com/open-dis/DISTutorial.wiki.git) or to just read it, click on the "Wiki" link at the top of this project.
	1. The tutorial pages kept in the code repository are published with GitHub Pages and available to read at this address: https://open-dis.github.io/dis-tutorial/

## Contents

1. <a href="DIS_Background">Intro</a>
	- DIS Background
	- DIS History
1. <a href="DoDModelingAndSimulationStandards">DOD Modeling and Simulation Standards</a>
	- DIS
	- HLA
	- TENA
	- What is standardized?
	- Philosophy: partial implementations of DIS abound
1. <a href="LiveVirtualConstructive">Live, Virtual, Constructive (LVC)</a>
	- Example DIS applications
   		- Situational awareness: maps
		- Simulation interoperability
		- Virtual Worlds
		- Analysis: Recording and Playback
1. <a href="VirtualWorldIssues">Virtual World Issues</a>
	- <a href="CoordinateSystems">Coordinate Systems</a>
	- <A href="EntityIdentifiers">Identifiers</a>
	- <a href="Networks">Networks</a>
	- <a href="Timestamps">Timestamps</a>
	- <A href="DeadReckoningStateUpdate">Dead Reckoning: State Update Frequency</a>
	- <a href="DeadReckoningLatency">Dead Reckoning: Latency</a>
	- <A href="EntityType">Semantics (Entity Type, etc)</a>
	- <a href="EntityDiscovery">Entity Discovery</a>
	- <a href="Scalability.">Scalablity</a>  
	- <A href="Gateways">Gateways</a>
1. <a href="DISImplementations">DIS Implementations</a>
1. <a href="ExchangingStateInformation">PDUs: Exchanging State Information</a>
	- <A href="UDPSockets">UDP Socket Programming</a>
	- <a href="EntityStatePDUs">Sending State Updates with Entity State PDUs</a>
	- <a href="ReceivingPDUs">Receiving PDUs</a>
	- <a href="Combat">Combat: Fire and Detonation PDUs</a>
	- Intercom: Voice Communications
	- Electronic Warfare
	- <a ref="PDUBundling">Bundled PDUs</a>
1. A Minimal DIS Networking Example
1. Technology
	- Web
	- Websockets
	- X3D
	- Unity
	- WebRTC
1. TODO
1. Credits
	- Initially authored Don McGregor
