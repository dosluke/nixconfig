{ config, pkgs, ... }:


  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


{
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
		   user = "me";
		   };
         };

    	# Enable the X11 windowing system.
    	# You can disable this if you're only using the Wayland session.
		xserver.enable = true;

		# Enable the KDE Plasma Desktop Environment.
        displayManager.sddm.enable = true;
		desktopManager.plasma6.enable = true;
		# Configure keymap in X11
		xserver.xkb = {
		  layout = "us";
		  variant = "";
		};

		pulseaudio.enable = false;
		pipewire = {
		  enable = true;
		  alsa.enable = true;
		  alsa.support32Bit = true;
		  pulse.enable = true;
		  # If you want to use JACK applications, uncomment this
		  #jack.enable = true;

		  # use the example session manager (no others are packaged yet so this is enabled by default,
		  # no need to redefine it in your config for now)
		  #media-session.enable = true;
		};

	};

}
