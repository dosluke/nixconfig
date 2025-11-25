#!/usr/bin/env bash
set -e


sync() {

info SYNCING NIXOS CONFIGURATION

    
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

info SYNC COMPLETE

# Show current status
git status --short


}
