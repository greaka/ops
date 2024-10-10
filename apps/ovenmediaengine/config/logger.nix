{ pkgs, logDir, ... }:
pkgs.writeText "Logger.xml" ''
  <?xml version="1.0" encoding="UTF-8"?>

  <Logger version="2">
  	<!-- Log file location -->
  	<Path>${logDir}</Path>

  	<!-- Disable some SRT internal logs -->
  	<Tag name="SRT" level="critical" />
  	<Tag name="HttpServer" level="warn" />
  	<Tag name=".*\.Stat" level="warn" />

  	<!-- Log level: [debug, info, warn, error, critical] -->
  	<Tag name=".*" level="info" />
  </Logger>
''
