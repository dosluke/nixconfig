{ config, pkgs, inputs, ... }:
{

  imports = [
  	inputs.plasma-manager.homeManagerModules.plasma-manager
  ];


  
  programs.plasma = {
  	enable = true;

  	panels = [
  	  {
  	  	location = "bottom";
  	  	height = 48;

  	  	widgets = [
  	  	  "TahoeLauncher"
  	  	  {
  	  	  
  	  	  }
  	  	];
  	  }
  	];
  };
}
