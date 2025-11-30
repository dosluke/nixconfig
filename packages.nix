
{ config, pkgs, ... } : {
	nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [
#Browser
      vivaldi
#      librewolf #takes freakin forever to build
#Terminal/Utils
      jq
      git
      lsd
      pls
      btop
      micro
      zsh
      kitty
      fzf
      tldr
      bat
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
restart() {
	sudo killall vivaldi-bin || true
	sudo reboot now
}
new() {
	touch "$1" >/dev/null 2>&1 || sudo touch "$1"
}
  '';

  loginShellInit = ''
    [[ ! -f ~/.zshrc ]] && echo "# Managed by NixOS" > ~/.zshrc
  '';

  	shellAliases = {
  	    m = "sudo micro";
  		cls = "clear";
        nx = "cd /etc/nixos/ && sudo ./nx.sh";
        del = "sudo rm -rf";
  	};
  };
}
