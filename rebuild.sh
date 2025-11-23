#!/usr/bin/env bash
set -e

source ./shared.sh

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  error Please run as root 
  exit 1
fi


mkdir -p "$NIXOS_DIR"
cd "$NIXOS_DIR"

#check that this will build before syncing to github
if ! sudo nix flake check /etc/nixos --impure --show-trace; then
  error ABORTED
  exit 1
fi


./sync.sh



echo ""
info REBUILDING
echo ""

#without flakes: sudo nixos-rebuild switch --show-trace \

sudo nixos-rebuild switch --impure --show-trace --flake /etc/nixos#default \
&& info "INSTALLING REFIND" \
&& sudo refind-install --yes \
&& info "COPYING CUSTOM REFIND CONFIG. THIS IS MANAGED FROM NIXOS CONFIGURATUION" \
&& sudo cp /etc/nixos/refind.conf /boot/EFI/refind/refind.conf

info installing packages manually until they are added to nix pkgs or alternates are found:
info nix-search-cli
nix profile add github:peterldowns/nix-search-cli --refresh



install_plasmoid() {
	local pkg_name="$1"
	local sub_folder="$2" #depends on the github structure, some in root, some in subfolder
	local git_url="$3"
	local location="/tmp/$pkg_name"

sudo rm -rf "$location"
sudo git clone "$git_url" "$location"
#running this as sudo without -u results in it not being available for the user account
sudo -u "$LOCAL_USER" kpackagetool6 -t Plasma/Applet -i "$location$sub_folder" || \
sudo -u "$LOCAL_USER" kpackagetool6 -t Plasma/Applet -u "$location$sub_folder"
sudo rm -rf "$location"


}



info Shutdown or Switch plasmoid

install_plasmoid shutdown_or_switch /package https://github.com/Davide-sd/shutdown_or_switch

#sudo rm -rf /tmp/shutdown_or_switch
#sudo git clone https://github.com/Davide-sd/shutdown_or_switch /tmp/shutdown_or_switch
#running this as sudo without -u results in it not being available for the user account
#sudo -u "$LOCAL_USER" kpackagetool6 -t Plasma/Applet -i /tmp/shutdown_or_switch/package || \
#sudo -u "$LOCAL_USER" kpackagetool6 -t Plasma/Applet -u /tmp/shutdown_or_switch/package
#sudo rm -rf /tmp/shutdown_or_switch


info Tahoe Launcher plasmoid
install_plasmoid tahoelauncher "" "https://github.com/EliverLara/TahoeLauncher"






info DONE
