
{ config, pkgs, lib, ... } : {

  nix.gc = {
    automatic = true;
#for the VM, if it rolls over an hour, this should trigger
    dates = "hourly";
    options = "--delete-older-than 5";
  };

#boot needs to be systemdboot to handle generations correctly
#rebuilding via the rebuild shell func will install refind to chainload systemdboot
	boot = {
      #thanks mipmip, your github showed this while i was exploring
	  plymouth = {
	  	enable = true;
	  	theme = "proxzima";
	  	themePackages = [
	  	  pkgs.plymouth-proxzima-theme #must also be included in system pkgs
	  	];
	  };
	  
	  kernelPackages = pkgs.linuxPackages_latest;
	
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = true;
        grub.enable = false;
      };
   	 };
}
