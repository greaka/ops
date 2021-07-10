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
			Listenaddress = "0.0.0.0";
			SslEnabled = true;
			SslCert = "/var/lib/acme/greaka.de/fullchain.pem";
			SslKey = "/var/lib/acme/greaka.de/key.pem";
			DownloadDomain = "https://dl.greaka.de";
			EnhancedWebSecurity = true;
			Authentication = true;
			NoAnonymousUploads = true;
		};
	};
}
