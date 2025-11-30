#!/usr/bin/env bash
set -e

CMD="$1"
# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO] $*${NC}" 
}
warn() { echo -e "${YELLOW}[WARN] $*${NC}" 
}
error() { echo -e "${RED}[ERROR] $*${NC}" 
}

ensure-root()
{
if [ "$EUID" -ne 0 ]; then
  error Please run as root 
  exit 1
fi
}

ensure-root


if [ -f "vars.json" ]; then
  NXVARSJSON=$(cat vars.json)
else
  NXVARSJSON=$(curl -s https://raw.githubusercontent.com/dosluke/nixconfig/main/vars.json)
fi

info Using vars:
echo $NXVARSJSON | jq || exit 1 #should exit if json is malformed

get-var() {
	echo "$NXVARSJSON" | jq -r ".$1"
}


show-dir()
{
	if command -v pls >/dev/null 2>&1; then
	  pls -g true
	else
	  ls -a
	fi
}


mkdir -p "$(get-var nixosDir)"
cd "$(get-var nixosDir)"


# Backup hardware-configuration.nix if it exists
if [ -f "hardware-configuration.nix" ]; then
    info Backing up hardware-configuration.nix
    cp hardware-configuration.nix "$(get-var tempHardwareConfPath)"
fi


if [ ! -d ".git" ]; then #first time, supposedly fresh system

    info "Cloning repository..."
    
    # Clone into a temporary directory first
    TEMP_CLONE="/tmp/nixos_clone_$$"
    git clone "$(get-var repoUrl)" "$TEMP_CLONE"
    
    # Move .git directory and contents
    mv "$TEMP_CLONE/.git" ./.git
    mv "$TEMP_CLONE/"* ./ 2>/dev/null || true
    mv "$TEMP_CLONE/".[!.]* ./ 2>/dev/null || true
    rm -rf "$TEMP_CLONE"
    
    # Configure git user
    git config user.name "$(get-var gitUserName)"
    git config user.email "$(get-var gitUserEmail)"
    
    info Repository cloned successfully
fi



NUKE-CONFIG() #used for testing initial conditions when syncing
{
	error "NUKING NIXOS CONFIG $(get-var nixosDir)"
	error 5
	sleep 1
	error 4
	sleep 1
	error 3
	sleep 1
	error 2
	sleep 1
	error 1
	cd "$(get-var nixosDir)"
	rm -rf ./*
	rm -rf ./.*
}


source ./build.sh
source ./sync.sh


case "$CMD" in

	"")
    show-dir
	;;

	"build-only")
	commit-local || true
	build || true
	;;
	
	"build")
	commit-local || true
	build
	sync || true
	;;

	"sync")
	sync || true
	;;

	"commit-local")
	commit-local || true
	;;

	"NUKE")
	NUKE-CONFIG || true
	;;

	"diff")
	info git diff:
	sudo git diff || true
	;;

	*)
	  echo "Unknown option: $CMD"
	  exit 1
	  ;;
esac


# Restore hardware-configuration.nix if it was backed up
if [ -f "$(get-var tempHardwareConfPath)" ]; then
    info Restoring hardware-configuration.nix
    cp "$(get-var tempHardwareConfPath)" hardware-configuration.nix
    rm "$(get-var tempHardwareConfPath)"
fi



info DONE
