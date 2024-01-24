{ hosts, pkgs, ... }:
pkgs.writeText "Server.xml" ''
  <?xml version="1.0" encoding="UTF-8" ?>

  <Server version="8">
  	<Name>OvenMediaEngine</Name>
  	<!-- Host type (origin/edge) -->
  	<Type>origin</Type>
  	<!-- Specify IP address to bind (* means all IPs) -->
  	<IP>*</IP>
  	<PrivacyProtection>false</PrivacyProtection>
  	<!-- 
  	To get the public IP address(mapped address of stun) of the local server. 
  	This is useful when OME cannot obtain a public IP from an interface, such as AWS or docker environment. 
  	If this is successful, you can use ''${PublicIP} in your settings.
  	-->
  	<StunServer>stun.l.google.com:19302</StunServer>

  	<!-- Settings for the ports to bind -->
  	<Bind>
  		<!-- Enable this configuration if you want to use API Server -->
  		<Managers>
  			<API>
  				<Port>''${env:OME_API_PORT:8081}</Port>
  				<WorkerCount>1</WorkerCount>
  			</API>
  		</Managers>
  		<Providers>
  			<!-- Push providers -->
  			<RTMP>
  				<Port>''${env:OME_RTMP_PROV_PORT:1935}</Port>
  				<WorkerCount>1</WorkerCount>
  			</RTMP>
  			<SRT>
  				<Port>''${env:OME_SRT_PROV_PORT:9999}</Port>
  				<WorkerCount>1</WorkerCount>
  			</SRT>
  			<WebRTC>
  				<Signalling>
  					<Port>3333</Port>
  					<!-- handled by nginx -->
  					<!-- <TLSPort>3334</TLSPort> -->
  					<WorkerCount>1</WorkerCount>
  				</Signalling>

  				<IceCandidates>
  					<!-- Uncomment the line below to use IPv6 ICE Candidate -->
  					<!-- <IceCandidate>[::]:10000-10004/udp</IceCandidate> -->
  					<IceCandidate>*:10000-10008/udp</IceCandidate>

  					<!-- Uncomment the line below to use a link local address when specifying an address with IPv6 wildcard (::) -->
  					<!-- <EnableLinkLocalAddress>true</EnableLinkLocalAddress> -->

  					<!-- 
  						If you want to stream WebRTC over TCP, specify IP:Port for TURN server.
  						This uses the TURN protocol, which delivers the stream from the built-in TURN server to the player's TURN client over TCP. 
  					-->
  					<TcpRelay>*:3478</TcpRelay>
  					<!-- TcpForce is an option to force the use of TCP rather than UDP in WebRTC streaming. (You can omit ?transport=tcp accordingly.) If <TcpRelay> is not set, playback may fail. -->
  					<TcpForce>false</TcpForce>
  					<TcpRelayWorkerCount>1</TcpRelayWorkerCount>
  				</IceCandidates>
  			</WebRTC>
  		</Providers>

  		<Publishers>
  			<WebRTC>
  				<Signalling>
  					<Port>''${env:OME_SIGNALLING_PORT:3333}</Port>
  					<WorkerCount>1</WorkerCount>
  				</Signalling>
  				<IceCandidates>
  					<TcpRelay>''${env:OME_TCP_RELAY_ADDRESS:*:3478}</TcpRelay>
  					<TcpForce>false</TcpForce>
  					<TcpRelayWorkerCount>1</TcpRelayWorkerCount>
  					<IceCandidate>''${env:OME_ICE_CANDIDATES:*:10016/udp}</IceCandidate>
  				</IceCandidates>
  			</WebRTC>
  			<LLHLS>
  			    <!-- 
  			    OME only supports h2, so LLHLS works over HTTP/1.1 on non-TLS ports. 
  			    LLHLS works with higher performance over HTTP/2, 
  			    so it is recommended to use a TLS port.
  			    -->
  			    <Port>8081</Port>
  			    <!-- If you want to use TLS, specify the TLS port -->
  			    <TLSPort>8082</TLSPort>
  			    <WorkerCount>1</WorkerCount>
  			</LLHLS>
  		</Publishers>
  	</Bind>

      <Managers>
          <Host>
              <Names>
                  <Name>*</Name>
              </Names>
          </Host>
          <API>
              <AccessToken>foo</AccessToken>
          </API>
      </Managers>

  	<VirtualHosts>
  		<VirtualHost>
  			<Name>default</Name>
  			<!--Distribution is a value that can be used when grouping the same vhost distributed across multiple servers. This value is output to the events log, so you can use it to aggregate statistics. -->
  			<Distribution>greaka.de</Distribution>
  			
  			<!-- Settings for multi ip/domain and TLS -->
  			<Host>
  			    <Names>
  			    	${
            builtins.concatStringsSep "\n"
            (builtins.map (x: "<Name>${x}.greaka.de</Name>") hosts)
          }
  			    </Names>
  			    <TLS>
  			        <!--<CertPath>/opt/ovenmediaengine/bin/origin_conf/stream.pem</CertPath>-->
  			        <!--<KeyPath>/opt/ovenmediaengine/bin/origin_conf/stream.key</KeyPath>-->
  			        <CertPath>''${env:CERT_FULL_CHAIN}</CertPath>
          			<KeyPath>''${env:CERT_KEY}</KeyPath>
  			    </TLS>
  			</Host>

  			<!-- Settings for applications -->
  			<Applications>
  				<Application>
  					<Name>app</Name>
  					<!-- Application type (live/vod) -->
  					<Type>live</Type>
  					<OutputProfiles>
  						<OutputProfile>
  							<Name>bypass_stream</Name>
  							<OutputStreamName>''${OriginStreamName}</OutputStreamName>
  							<Encodes>
  								<Audio>
  									<Bypass>true</Bypass>
  								</Audio>
  								<Video>
  									<Bypass>true</Bypass>
  								</Video>
                                  <Audio>
                                      <Codec>opus</Codec>
                                      <Bitrate>128000</Bitrate>
                                      <Samplerate>48000</Samplerate>
                                      <Channel>2</Channel>
                                  </Audio>
  							</Encodes>
  						</OutputProfile>
  					</OutputProfiles>
  					<Providers>
  						<RTMP />
  						<SRT />
  						<WebRTC />
  					</Providers>
  					<Publishers>
  						<AppWorkerCount>1</AppWorkerCount>
  						<StreamWorkerCount>8</StreamWorkerCount>
  						<WebRTC>
  							<Timeout>30000</Timeout>
  							<Rtx>true</Rtx>
  							<Ulpfec>true</Ulpfec>
  							<JitterBuffer>false</JitterBuffer>
  						</WebRTC>
  						<LLHLS>
  					        <ChunkDuration>0.2</ChunkDuration> <!-- 0.2 -->
  					        <SegmentDuration>6</SegmentDuration> <!-- 6 -->
  					        <SegmentCount>10</SegmentCount> <!-- 10 -->
  					        <CrossDomains>
  					            <Url>*</Url>
  					        </CrossDomains>
  					    </LLHLS>
  					</Publishers>
  				</Application>
  			</Applications>
  		</VirtualHost>
  	</VirtualHosts>
  </Server>
''
