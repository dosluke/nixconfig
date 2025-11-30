let
  vars = builtins.fromJSON (builtins.readFile ./vars.json);
in
{ config, pkgs, ... } : {
  services = {
        # Enable CUPS to print documents.
        printing.enable = true;
        #enable host and VM clipboard sharing
		spice-vdagentd.enable = true;
		qemuGuest.enable = true;

		displayManager = {
	      sddm.autoLogin.relogin = true;
		  autoLogin = {
		   enable = true;
		   user = "${vars.localUser}";
		   };
         };
         
		# Enable the KDE Plasma Desktop Environment.
        displayManager.sddm.enable = true;
		desktopManager.plasma6.enable = true;

		xserver = {
			enable = true;
			xkb = {
				layout = "us";
				variant = "";
			};
		};

		pulseaudio.enable = false;
		pipewire = {
		  enable = true;
		  alsa.enable = true;
		  alsa.support32Bit = true;
		  pulse.enable = true;
		};
	};
}
