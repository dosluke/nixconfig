#users

{ config, pkgs, ... }:

{
	  # Define a user account. Don't forget to set a password with ‘passwd’.
	  users.users.me = {
	    isNormalUser = true;
	    description = "me";
	    extraGroups = [ "networkmanager" "wheel" ];
	    shell = pkgs.zsh;
	    packages = with pkgs; [
	    ];
	  };
}
