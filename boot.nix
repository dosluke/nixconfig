# Bootloader.

{ config, pkgs, lib, ... }:


{

#boot needs to be systemdboot to handle generations correctly, but the rebuild shell func defined in zsh config will install refind which chain loads systemdboot

	boot = {
	  # Use latest kernel.
	  kernelPackages = pkgs.linuxPackages_latest;
	
      loader = {
        efi.canTouchEfiVariables = true;

        systemd-boot.enable = true;
        grub.enable = false;
      };
#original boot config
		#loader = {
		  #grub = {
		  	#enable = true;
		  	#device = "/dev/vda";
		  	#useOSProber = true;
		  #}	;
	    #};
	 };
	
}
