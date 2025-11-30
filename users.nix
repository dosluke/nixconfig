let
  vars = builtins.fromJSON (builtins.readFile ./vars.json);
in
{ config, pkgs, ... } : {
	  users.users.${vars.localUser} = {
	    isNormalUser = true;
	    description = "Default user";
	    extraGroups = [ "networkmanager" "wheel" ];
	    shell = pkgs.zsh;
	    packages = with pkgs; [
	    ];
	  };
}
