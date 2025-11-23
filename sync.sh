#!/usr/bin/env bash
set -e

source ./shared.sh

ensure_root

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
