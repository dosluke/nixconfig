#!/usr/bin/env bash
set -e

set-git-info() {
    git config user.name "$(get-var gitUserName)"
    git config user.email "$(get-var gitUserEmail)"
    git remote set-url origin "$(get-var repoUrl)"
}

commit-local() {
	    warn "Committing local changes..."
	    DATESTAMP=$(date '+%Y-%m-%d')
	    TIMESTAMP=$(date '+%H:%M:%S')
	    HOSTNAME=$(hostname)
	    git add -A
	    git commit -m "sync | $HOSTNAME | $DATESTAMP | $TIMESTAMP"
}


sync() {

info SYNCING NIXOS CONFIGURATION

    set-git-info
    
    info "Fetching from remote..."
    git fetch origin
    
    # Check if there are local changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null || [ -n "$(git status --porcelain)" ]; then
        warn Local changes detected
        
        # Stage all changes
        git add -A
        
        # Check if there are staged changes
        if ! git diff-index --quiet --cached HEAD -- 2>/dev/null; then
          commit-local
        fi
    fi
        
    # Check if remote has changes
	BRANCH=$(get-var gitBranch)
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse origin/$BRANCH)

    info LOCAL : $LOCAL
    info REMOTE: $REMOTE
    
    if [ "$LOCAL" != "$REMOTE" ]; then
        warn "LOCAL != REMOTE, merging..."
        
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

      # Push changes to remote
      warn "Pushing changes to remote..."
      if git push origin $BRANCH; then
          info "Successfully pushed to remote"
      else
          error Failed to push to remote. You may need to pull and merge manually.
          exit 1
      fi

        
    else
        info Repository is up to date with remote
    fi
    
info SYNC COMPLETE

# Show current status
git status --short


}
