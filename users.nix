
{ config, pkgs, ... } : {
	  users.users.me = {
	    isNormalUser = true;
	    description = "me";
	    extraGroups = [ "networkmanager" "wheel" ];
	    shell = pkgs.zsh;
	    packages = with pkgs; [
	    ];
	  };
}
