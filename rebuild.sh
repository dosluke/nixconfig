#!/usr/bin/env bash
set -e

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

info() {
	echo -e "${GREEN}[INFO] $*${NC}"
}

warn() {
	echo -e "${YELLOW}[WARN] $*${NC}"
}

error() {
	echo -e "${RED}[ERROR] $*${NC}"
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

#check that this will build before syncing to github
if ! sudo nix flake check /etc/nixos --impure --show-trace; then
  error ABORTED
  exit 1
fi


echo ""
info SYNCING NIXOS CONFIGURATION
echo ""

# Backup hardware-configuration.nix if it exists
if [ -f "hardware-configuration.nix" ]; then
    info Backing up hardware-configuration.nix
    cp hardware-configuration.nix "$TEMP_HARDWARE_CONFIG"
fi

# Check if this is already a git repository
if [ -d ".git" ]; then
    info "Git repository detected"
    
    git config user.name "$GIT_USER_NAME"
    git config user.email "$GIT_USER_EMAIL"
    
    info "Fetching from remote..."
    git fetch origin
    
    # Check if there are local changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null || [ -n "$(git status --porcelain)" ]; then
        warn Local changes detected
        
        # Stage all changes
        git add -A
        
        # Check if there are staged changes
        if ! git diff-index --quiet --cached HEAD -- 2>/dev/null; then
            warn "Committing local changes..."
            DATESTAMP=$(date '+%Y-%m-%d')
            TIMESTAMP=$(date '+%H:%M:%S')
            HOSTNAME=$(hostname)
            git commit -m "sync | $HOSTNAME | $DATESTAMP | $TIMESTAMP"
        fi
    fi
    
    # Check if remote has changes
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse origin/$BRANCH)
    
    if [ "$LOCAL" != "$REMOTE" ]; then
        warn "Remote changes detected, merging..."
        
        # Try to rebase local commits on top of remote
        if git rebase origin/$BRANCH; then
            info Successfully merged remote changes
        else
            warn GIT MERGE CONFLICT
            warn "Aborting rebase and trying merge..."
            git rebase --abort
            
            # Fallback to merge
            if git merge origin/$BRANCH -m "Auto-merge from remote"; then
                info Merge completed
            else
                error Automatic merge failed. Manual intervention required.
                error "Conflict files:"
                git diff --name-only --diff-filter=U
                exit 1
            fi
        fi
    else
        info Repository is up to date with remote
    fi
    
    # Push changes to remote
    warn "Pushing changes to remote..."
    if git push origin $BRANCH; then
        info "Successfully pushed to remote"
    else
        error Failed to push to remote. You may need to pull and merge manually.
        exit 1
    fi

else
    warn No git repository found
    
    # Check if directory has files (excluding hardware-configuration.nix)
    if [ -n "$(ls -A | grep -v '^hardware-configuration.nix$')" ]; then
        warn Directory contains files. Moving them to temporary location...
        TEMP_DIR="/tmp/nixos_backup_$(date +%s)"
        mkdir -p "$TEMP_DIR"
        
        # Move all files except hardware-configuration.nix
        for item in *; do
            if [ "$item" != "hardware-configuration.nix" ]; then
                mv "$item" "$TEMP_DIR/"
            fi
        done
        
        warn "Files backed up to: $TEMP_DIR"
    fi
    
    # Clone the repository
    info "Cloning repository..."
    
    # Clone into a temporary directory first
    TEMP_CLONE="/tmp/nixos_clone_$$"
    git clone "$REPO_URL" "$TEMP_CLONE"
    
    # Move .git directory and contents
    mv "$TEMP_CLONE/.git" ./
    mv "$TEMP_CLONE/"* ./ 2>/dev/null || true
    mv "$TEMP_CLONE/".[!.]* ./ 2>/dev/null || true
    rm -rf "$TEMP_CLONE"
    
    # Configure git user
    git config user.name "$GIT_USER_NAME"
    git config user.email "$GIT_USER_EMAIL"
    
    info Repository cloned successfully
fi

# Restore hardware-configuration.nix if it was backed up
if [ -f "$TEMP_HARDWARE_CONFIG" ]; then
    info Restoring hardware-configuration.nix
    cp "$TEMP_HARDWARE_CONFIG" hardware-configuration.nix
    rm "$TEMP_HARDWARE_CONFIG"
fi

echo ""
info SYNC COMPLETE
echo ""

# Show current status
git status --short




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
