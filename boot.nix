# Bootloader.

{ config, pkgs, lib, ... }:


{

#boot needs to be systemdboot to handle generations correctly
#rebuilding via the rebuild shell func will install refind to chainload systemdboot

	boot = {

	  plymouth {
	  	enable = true;
	  	theme = breeze;
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
