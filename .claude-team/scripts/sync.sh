#!/bin/bash
# Team Knowledge Sync

echo "🔄 Syncing team knowledge..."

# Pull latest
git pull origin main 2>/dev/null || git pull

# Add team knowledge
git add .claude-team 2>/dev/null

# Commit if changes exist
if ! git diff --cached --quiet 2>/dev/null; then
    git commit -m "Knowledge sync: $(date +%Y-%m-%d) - $(git config user.name)"
fi

# Push changes
git push origin main 2>/dev/null || git push

echo "✅ Knowledge synchronized!"
