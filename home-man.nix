
{ config, pkgs, ... } : {

	home-manager.backupFileExtension = "backup";

	home-manager.users.me = { pkgs, ... } : {
	
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
