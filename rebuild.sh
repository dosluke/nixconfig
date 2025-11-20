#!/usr/bin/env bash
set -e

NIXOS_DIR="/etc/nixos"
REPO_URL="git@github.com:dosluke/nixconfig.git"
GIT_USER_NAME="dosluke"
GIT_USER_EMAIL="dosluke@gmail.com"
TEMP_HARDWARE_CONFIG="/tmp/hardware-configuration.nix.backup"
BRANCH="main"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
  echo -e "${RED}Error: Please run as root${NC}"
  exit 1
fi

mkdir -p "$NIXOS_DIR"
cd "$NIXOS_DIR"

echo ""
echo -e "${GREEN}==> SYNCING NIXOS CONFIGURATION${NC}"
echo ""

# Backup hardware-configuration.nix if it exists
if [ -f "hardware-configuration.nix" ]; then
    echo -e "${GREEN}Backing up hardware-configuration.nix${NC}"
    cp hardware-configuration.nix "$TEMP_HARDWARE_CONFIG"
fi

# Check if this is already a git repository
if [ -d ".git" ]; then
    echo -e "Git repository detected"
    
    git config user.name "$GIT_USER_NAME"
    git config user.email "$GIT_USER_EMAIL"
    
    echo "Fetching from remote..."
    git fetch origin
    
    # Check if there are local changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null || [ -n "$(git status --porcelain)" ]; then
        echo -e "${YELLOW}Local changes detected${NC}"
        
        # Stage all changes
        git add -A
        
        # Check if there are staged changes
        if ! git diff-index --quiet --cached HEAD -- 2>/dev/null; then
            echo "Committing local changes..."
            DATESTAMP=$(date '+%Y-%m-%d')
            TIMESTAMP=$(date '+%H:%M:%S')
            HOSTNAME=$(hostname)
            git commit -m "sync | $HOSTNAME | $DATESTAMP | $TIMESTAMP"
        fi
    fi
    
    # Check if remote has changes we don't have
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse origin/$BRANCH)
    
    if [ "$LOCAL" != "$REMOTE" ]; then
        echo -e "Remote changes detected, merging..."
        
        # Try to rebase local commits on top of remote
        if git rebase origin/$BRANCH; then
            echo -e "${GREEN}Successfully merged remote changes${NC}"
        else
            echo -e "${RED}Merge conflict detected!${NC}"
            echo "Aborting rebase and trying merge..."
            git rebase --abort
            
            # Fallback to merge
            if git merge origin/$BRANCH -m "Auto-merge from remote"; then
                echo -e "${GREEN}Merge completed${NC}"
            else
                echo -e "${RED}Automatic merge failed. Manual intervention required.${NC}"
                echo "Conflict files:"
                git diff --name-only --diff-filter=U
                exit 1
            fi
        fi
    else
        echo -e "${GREEN}Repository is up to date with remote${NC}"
    fi
    
    # Push changes to remote
    echo "Pushing changes to remote..."
    if git push origin $BRANCH; then
        echo -e "Successfully pushed to remote"
    else
        echo -e "${RED}Failed to push to remote. You may need to pull and merge manually.${NC}"
        exit 1
    fi

else
    echo -e "${YELLOW}No git repository found${NC}"
    
    # Check if directory has files (excluding hardware-configuration.nix)
    if [ -n "$(ls -A | grep -v '^hardware-configuration.nix$')" ]; then
        echo -e "${YELLOW}Directory contains files. Moving them to temporary location...${NC}"
        TEMP_DIR="/tmp/nixos_backup_$(date +%s)"
        mkdir -p "$TEMP_DIR"
        
        # Move all files except hardware-configuration.nix
        for item in *; do
            if [ "$item" != "hardware-configuration.nix" ]; then
                mv "$item" "$TEMP_DIR/"
            fi
        done
        
        echo -e "${YELLOW}Files backed up to: $TEMP_DIR${NC}"
    fi
    
    # Clone the repository
    echo "Cloning repository..."
    
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
    
    echo -e "${GREEN}Repository cloned successfully${NC}"
fi

# Restore hardware-configuration.nix if it was backed up
if [ -f "$TEMP_HARDWARE_CONFIG" ]; then
    echo -e "${YELLOW}Restoring hardware-configuration.nix${NC}"
    cp "$TEMP_HARDWARE_CONFIG" hardware-configuration.nix
    rm "$TEMP_HARDWARE_CONFIG"
fi

echo ""
echo -e "${GREEN}==> SYNC COMPLETE${NC}"
echo ""

# Show current status
git status --short




echo ""
echo -e "${GREEN}==> REBUILDING${NC}"
echo ""

#without flakes: sudo nixos-rebuild switch --show-trace \

sudo nixos-rebuild switch --impure --show-trace --flake /etc/nixos#default \
&& sudo refind-install --yes \
&& echo -e "${GREEN}COPYING CUSTOM REFIND CONFIG. THIS IS MANAGED FROM NIXOS CONFIGURATUION${NC}" \
&& sudo cp /etc/nixos/refind.conf /boot/EFI/refind/refind.conf


nix profile add github:peterldowns/nix-search-cli --refresh
