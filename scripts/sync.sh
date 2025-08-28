#!/bin/bash
# Claude Lazy Genius - Team Knowledge Sync
# Share and receive team knowledge via Git

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
TEAM_DIR=".claude-team"
BRANCH=$(git branch --show-current 2>/dev/null || echo "main")

echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}     🔄 Claude Lazy Genius Sync            ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo ""

# Check if Git is available
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git not found. Please install Git first.${NC}"
    exit 1
fi

# Check if in Git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Not in a Git repository${NC}"
    echo "Initialize with: git init"
    exit 1
fi

# Function to show status
show_status() {
    echo -e "${BLUE}📊 Current Status${NC}"
    echo ""
    
    # Check for local changes
    if [ -d "$TEAM_DIR" ]; then
        local_changes=$(git status --porcelain "$TEAM_DIR" 2>/dev/null | wc -l)
        echo -e "  Local changes: ${YELLOW}$local_changes files${NC}"
    fi
    
    # Check sync status with remote
    if git remote get-url origin &>/dev/null; then
        git fetch origin --quiet 2>/dev/null
        
        ahead=$(git rev-list --count origin/"$BRANCH".."$BRANCH" 2>/dev/null || echo 0)
        behind=$(git rev-list --count "$BRANCH"..origin/"$BRANCH" 2>/dev/null || echo 0)
        
        if [ "$ahead" -gt 0 ]; then
            echo -e "  Remote status: ${YELLOW}$ahead commits ahead${NC}"
        fi
        if [ "$behind" -gt 0 ]; then
            echo -e "  Remote status: ${YELLOW}$behind commits behind${NC}"
        fi
        if [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ]; then
            echo -e "  Remote status: ${GREEN}✓ In sync${NC}"
        fi
    else
        echo -e "  Remote status: ${YELLOW}No remote configured${NC}"
    fi
    echo ""
}

# Function to pull team knowledge
pull_knowledge() {
    echo -e "${BLUE}📥 Pulling team knowledge...${NC}"
    
    if ! git remote get-url origin &>/dev/null; then
        echo -e "${YELLOW}No remote repository configured${NC}"
        echo "Add remote with: git remote add origin <repository-url>"
        return 1
    fi
    
    # Stash local changes if needed
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo "  Stashing local changes..."
        git stash push -q -m "Lazy Genius sync $(date +%Y-%m-%d_%H:%M)"
        stashed=1
    fi
    
    # Pull latest changes
    if git pull --rebase origin "$BRANCH" 2>/dev/null; then
        echo -e "${GREEN}  ✓ Successfully pulled latest knowledge${NC}"
    else
        echo -e "${YELLOW}  ⚠️ Pull failed, trying merge strategy...${NC}"
        git pull origin "$BRANCH" --no-rebase 2>/dev/null || {
            echo -e "${RED}  ❌ Failed to pull. Check your connection and branch.${NC}"
            return 1
        }
    fi
    
    # Restore stashed changes
    if [ "${stashed:-0}" -eq 1 ]; then
        echo "  Restoring local changes..."
        git stash pop -q || echo -e "${YELLOW}  ⚠️ Some stashed changes couldn't be restored${NC}"
    fi
    
    echo -e "${GREEN}✓ Team knowledge updated${NC}"
}

# Function to push knowledge
push_knowledge() {
    echo -e "${BLUE}📤 Sharing your knowledge...${NC}"
    
    if [ ! -d "$TEAM_DIR" ]; then
        echo -e "${YELLOW}No knowledge to share yet${NC}"
        return 0
    fi
    
    # Add team knowledge files
    git add "$TEAM_DIR" 2>/dev/null
    
    # Check if there are changes to commit
    if git diff --cached --quiet; then
        echo -e "${YELLOW}  No new knowledge to share${NC}"
    else
        # Create commit
        commit_msg="Knowledge update: $(date +%Y-%m-%d) - $(git config user.name || echo 'unknown')"
        git commit -m "$commit_msg" -q
        echo -e "${GREEN}  ✓ Knowledge committed${NC}"
    fi
    
    # Push to remote if configured
    if git remote get-url origin &>/dev/null; then
        if git push origin "$BRANCH" 2>/dev/null; then
            echo -e "${GREEN}  ✓ Knowledge shared with team${NC}"
        else
            echo -e "${YELLOW}  ⚠️ Push failed - pull first then retry${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}  No remote configured - knowledge saved locally${NC}"
    fi
}

# Function for full sync
full_sync() {
    show_status
    pull_knowledge
    push_knowledge
    echo ""
    echo -e "${GREEN}✅ Synchronization complete!${NC}"
}

# Function to resolve conflicts
resolve_conflicts() {
    echo -e "${BLUE}🔧 Checking for conflicts...${NC}"
    
    conflicted=$(git diff --name-only --diff-filter=U 2>/dev/null)
    
    if [ -z "$conflicted" ]; then
        echo -e "${GREEN}  ✓ No conflicts found${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Resolving conflicts automatically...${NC}"
    
    echo "$conflicted" | while IFS= read -r file; do
        if [[ "$file" == *.md ]] && [[ "$file" == *"$TEAM_DIR"* ]]; then
            echo "  Resolving: $file"
            
            # For daily logs and append-only files, keep both versions
            if [[ "$file" == */daily/*.md ]] || [[ "$file" == */ANTIPATTERNS.md ]] || [[ "$file" == */SOLUTIONS.md ]]; then
                # Remove conflict markers, keep all content
                sed -i.backup '/<<<<<<<.*\|=======\|>>>>>>>.*/d' "$file"
                rm "${file}.backup" 2>/dev/null
                git add "$file"
                echo -e "${GREEN}    ✓ Merged both versions${NC}"
            else
                echo -e "${YELLOW}    ⚠️ Manual resolution needed${NC}"
            fi
        fi
    done
    
    # Check if all resolved
    if git diff --name-only --diff-filter=U | grep -q .; then
        echo -e "${RED}Some conflicts remain - please resolve manually${NC}"
        return 1
    else
        echo -e "${GREEN}✓ All conflicts resolved${NC}"
        return 0
    fi
}

# Main menu
case "${1:-sync}" in
    sync|"")
        full_sync
        ;;
    pull)
        pull_knowledge
        ;;
    push)
        push_knowledge
        ;;
    status)
        show_status
        ;;
    resolve)
        resolve_conflicts
        ;;
    help)
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  sync    - Full sync (pull then push) [default]"
        echo "  pull    - Only pull team knowledge"
        echo "  push    - Only push your knowledge"
        echo "  status  - Show sync status"
        echo "  resolve - Resolve merge conflicts"
        echo "  help    - Show this help"
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo "Run '$0 help' for usage"
        exit 1
        ;;
esac