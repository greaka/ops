{ ... }:
{
	imports = [
		../acme
	];

	users.users.plikd = {
		isSystemUser = true;
		extraGroups = ["acme"];
	};

	services.plikd = {
		enable = true;
		openFirewall = true;
		settings = {
			ListenAddress = "0.0.0.0";
			ListenPort = 8080;
			SslEnabled = true;
			SslCert = "/var/lib/acme/greaka.de/fullchain.pem";
			SslKey = "/var/lib/acme/greaka.de/key.pem";
			DownloadDomain = "https://dl.greaka.de";
			EnhancedWebSecurity = true;
			Authentication = true;
			NoAnonymousUploads = true;
		};
	};

	services.nginx.virtualHosts."dl.greaka.de" = {
		forceSSL = true;
		locations."/".proxyPass = "https://localhost:" ++ services.plikd.settings.ListenPort;
        useACMEHost = "greaka.de";
	};
}