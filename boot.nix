# Bootloader.

{ config, pkgs, lib, ... }:


{

#boot needs to be systemdboot to handle generations correctly
#rebuilding via the rebuild shell func will install refind to chainload systemdboot

	boot = {

      #thanks mipmip, your github showed this while i was exploring
	  plymouth = {
	  	enable = true;
	  	theme = "matrix";
	  	themePackages = [
	  	  pkgs.plymouth-matrix-theme
	  	];
	  };
	  
	  # Use latest kernel.
	  kernelPackages = pkgs.linuxPackages_latest;
	
      loader = {
        efi.canTouchEfiVariables = true;

        systemd-boot.enable = true;
        grub.enable = false;
      };
   	 };
	
}
