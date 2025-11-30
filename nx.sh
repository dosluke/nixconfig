#!/usr/bin/env bash
set -e

CMD="$1"
NIXOS_DIR="/etc/nixos"
REPO_URL="git@github.com:dosluke/nixconfig.git"
GIT_USER_NAME="dosluke"
GIT_USER_EMAIL="dosluke@gmail.com"
TEMP_HARDWARE_CONFIG="/tmp/hardware-configuration.nix.backup"
BRANCH="main"
LOCAL_USER="me"

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

ensure_root()
{
if [ "$EUID" -ne 0 ]; then
  error Please run as root 
  exit 1
fi
}

ensure_root

mkdir -p "$NIXOS_DIR"
cd "$NIXOS_DIR"


# Backup hardware-configuration.nix if it exists
if [ -f "hardware-configuration.nix" ]; then
    info Backing up hardware-configuration.nix
    cp hardware-configuration.nix "$TEMP_HARDWARE_CONFIG"
fi


if [ ! -d ".git" ]; then #first time, supposedly fresh system

    info "Cloning repository..."
    
    # Clone into a temporary directory first
    TEMP_CLONE="/tmp/nixos_clone_$$"
    git clone "$REPO_URL" "$TEMP_CLONE"
    
    # Move .git directory and contents
    mv "$TEMP_CLONE/.git" ./.git
    mv "$TEMP_CLONE/"* ./ 2>/dev/null || true
    mv "$TEMP_CLONE/".[!.]* ./ 2>/dev/null || true
    rm -rf "$TEMP_CLONE"
    
    # Configure git user
    git config user.name "$GIT_USER_NAME"
    git config user.email "$GIT_USER_EMAIL"
    
    info Repository cloned successfully

    source ./build.sh
    build
fi



NUKE_CONFIG() #used for testing initial conditions when syncing
{
	error "NUKING NIXOS CONFIG $NIXOS_DIR"
	error 5
	sleep 1
	error 4
	sleep 1
	error 3
	sleep 1
	error 2
	sleep 1
	error 1
	cd "$NIXOS_DIR"
	rm -rf ./*
	rm -rf ./.*
}


source ./build.sh
source ./sync.sh

case "$CMD" in

	"")
	pls -g true || ls -a
	;;

	"build-only")
	commit-local
	build
	;;
	
	"build")
	commit-local
	build
	sync
	;;

	"sync")
	sync
	;;

	"NUKE")
	NUKE_CONFIG
	;;

	*)
	  echo "Unknown option: $CMD"
	  exit 1
	  ;;
esac



# Restore hardware-configuration.nix if it was backed up
if [ -f "$TEMP_HARDWARE_CONFIG" ]; then
    info Restoring hardware-configuration.nix
    cp "$TEMP_HARDWARE_CONFIG" hardware-configuration.nix
    rm "$TEMP_HARDWARE_CONFIG"
fi



info DONE
