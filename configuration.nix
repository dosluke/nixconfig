# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).


{ config, pkgs, ... }:

#let
#  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
#in
{

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

#relative paths work for files tracked by git
#absolute paths otherwise
  imports =
    [ 
      /etc/nixos/hardware-configuration.nix
      ./boot.nix
      ./packages.nix
      ./services.nix
      ./users.nix
      ./plasma.nix
    ];

#some basics not worth moving to their own file yet  

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };



  # Enable sound with pipewire.
  security.rtkit.enable = true;

	home-manager.backupFileExtension = "backup";

	home-manager.users.me = { pkgs, ... }: {
	    home.stateVersion = "25.05";


	    home.file.".config/autostart/kitty.desktop".text = ''
	          [Desktop Entry]
	          Type=Application
	          Exec=kitty
	          Name=Kitty
	          X-KDE-autostart-phase=2
	        '';
	        
	  };


}
