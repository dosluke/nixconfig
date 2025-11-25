#declare packages and their options

{ config, pkgs, ... }:

{
	# Allow unfree packages
	nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [

#Browser
      vivaldi
      librewolf

#Terminal/Utils
      git
      lsd
      pls
      btop
      micro
      zsh
      kitty
      fzf
      tldr
      psmisc #provides killall command

#Plasma6
      plasma-applet-commandoutput
      kdePackages.kdeplasma-addons
      
#Other
      spice-vdagent #for host/vm clipboard
      refind
      plymouth-proxzima-theme
    ];



    environment.plasma6.excludePackages = with pkgs.kdePackages; [
    	konsole
    	kate
    	elisa
    	gwenview
    	okular
    ];


  programs.kdeconnect.enable = false;


  programs.zsh = {
  	enable = true;
  	enableCompletion = true;
  	autosuggestions.enable = true;

  shellInit = ''
    #disable zsh-newuser-install
    ZDOTDIR=$HOME
  '';

  interactiveShellInit = ''
#shell functions here
c() {
	cd "$1" && pls -g true
}
  '';

  loginShellInit = ''
    [[ ! -f ~/.zshrc ]] && echo "# Managed by NixOS" > ~/.zshrc
  '';

  	shellAliases = {
  	    m = "sudo micro";
  		cls = "clear";
        nx = "sudo source /etc/nixos/nx.sh";
  		restart = "killall vivaldi-bin || sudo reboot now";
  	};
  };

  	

}
