#!/bin/bash
# _scripts/bump-upstream.sh
# Automates fetching upstream tags, rebasing, handling conflicts, and pushing.

# Ensure we have the upstream remote
if ! git remote | grep -q "upstream"; then
    echo "🔗 Adding upstream remote..."
    git remote add upstream https://github.com/basecamp/omarchy.git
fi

# Fetch latest metadata
echo "📡 Fetching tags from upstream..."
git fetch upstream --tags --quiet

# Find tags
LATEST_TAG=$(git tag --list 'v*' --sort=-v:refname | head -n 1)
CURRENT_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")

echo "------------------------------------------------"
echo "📌 Current Base: $CURRENT_TAG"
echo "🚀 Latest Upstream: $LATEST_TAG"
echo "------------------------------------------------"

if [ "$LATEST_TAG" == "$CURRENT_TAG" ]; then
    echo "✅ You are already on the latest version."
    exit 0
fi

read -p "Update fork to $LATEST_TAG? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled."
    exit 0
fi

echo "🔄 Starting rebase onto $LATEST_TAG..."

# We turn off 'exit on error' because git rebase returns exit code 1 on conflict
set +e 

# Attempt the rebase
git rebase "$LATEST_TAG"
REBASE_STATUS=$?

# If rebase failed (exit code non-zero), enter interactive recovery loop
if [ $REBASE_STATUS -ne 0 ]; then
    echo ""
    echo "⚠️  CONFLICT DETECTED! ⚠️"
    echo "---------------------------------------------------"
    echo "1. Open the highlighted files in the editor."
    echo "2. Fix the conflicts and save the files."
    echo "3. Use the Source Control sidebar to 'Stage' (+) the changes."
    echo "---------------------------------------------------"
    
    # Loop until the rebase is actually finished
    while true; do
        read -p "👉 When conflicts are fixed and staged, press [Enter] to continue..."
        
        echo "Trying to continue rebase..."
        git rebase --continue
        
        # Check if rebase is done (0 means success/finished)
        if [ $? -eq 0 ]; then
            echo "✅ Rebase resolved and finished!"
            break
        fi
        
        # If we are here, git rebase --continue hit ANOTHER conflict in a subsequent commit
        echo "⚠️  Another conflict detected in the next commit. Please fix and stage again."
    done
fi

# Turn 'exit on error' back on for the push
set -e

echo "------------------------------------------------"
echo "⬆️  Pushing changes to GitHub (Force update)..."
git push --force-with-lease origin master

echo "🎉 Success! Your fork is now live on $LATEST_TAG"