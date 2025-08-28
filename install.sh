#!/bin/bash
# Claude Lazy Genius - The 60-Second Knowledge System for Claude
# https://github.com/Aatish-Dhami/claude-lazy-genius

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://raw.githubusercontent.com/Aatish-Dhami/claude-lazy-genius/main"
VERSION="1.0.0"

# Banner
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════╗"
echo "║       🧠 Claude Lazy Genius v$VERSION      ║"
echo "║   Make Claude Remember Everything Forever  ║"
echo "╚═══════════════════════════════════════════╝"
echo -e "${NC}"

# Check prerequisites
check_prerequisites() {
    echo -e "${BLUE}📋 Checking prerequisites...${NC}"
    
    # Check for Git
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}⚠️  Git not found. Please install Git first:${NC}"
        echo "   Mac: brew install git"
        echo "   Linux: apt-get install git"
        echo "   Windows: https://git-scm.com/download/win"
        exit 1
    fi
    
    # Check Git user configuration
    if [ -z "$(git config user.name)" ]; then
        echo -e "${YELLOW}⚠️  Git user name not configured${NC}"
        read -p "Enter your name: " git_name
        git config --global user.name "$git_name"
        echo -e "${GREEN}✓ Git user name set${NC}"
    fi
    
    # Check if in Git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${YELLOW}📝 Not in a Git repository. Initializing...${NC}"
        git init
        echo -e "${GREEN}✓ Git repository initialized${NC}"
    fi
    
    echo -e "${GREEN}✓ Prerequisites satisfied${NC}"
}

# Detect setup type
detect_setup_type() {
    echo -e "${BLUE}🔍 Detecting setup type...${NC}"
    
    # Check for existing team
    if [ -d ".claude-team" ]; then
        echo -e "${YELLOW}⚠️  Existing setup detected. Upgrade? (y/n)${NC}"
        read -p "> " upgrade
        if [[ ! "$upgrade" =~ ^[Yy]$ ]]; then
            echo "Installation cancelled"
            exit 0
        fi
    fi
    
    # Detect team size
    contributors=$(git log --format='%ae' 2>/dev/null | sort -u | wc -l)
    if [ "$contributors" -gt 1 ]; then
        echo -e "${GREEN}✓ Team environment detected ($contributors contributors)${NC}"
        SETUP_TYPE="team"
    else
        echo -e "${GREEN}✓ Solo developer environment${NC}"
        SETUP_TYPE="solo"
    fi
}

# Create directory structure
create_directories() {
    echo -e "${BLUE}📁 Creating directory structure...${NC}"
    
    # Local Claude directory (git-ignored)
    mkdir -p .claude
    
    # Team knowledge directories (git-tracked)
    mkdir -p .claude-team/{daily,memory,patterns,scripts,templates,archive}
    
    echo -e "${GREEN}✓ Directories created${NC}"
}

# Download and install hooks
install_hooks() {
    echo -e "${BLUE}🪝 Installing hooks...${NC}"
    
    # Determine which hooks to use
    if [ "$SETUP_TYPE" == "team" ]; then
        HOOKS_FILE="team.json"
    else
        HOOKS_FILE="basic.json"
    fi
    
    # Try to download from repo, fallback to embedded version
    if curl -fsS "$REPO_URL/hooks/$HOOKS_FILE" > .claude/hooks.json 2>/dev/null; then
        echo -e "${GREEN}✓ Hooks downloaded from repository${NC}"
    else
        # Embedded basic hooks (fallback)
        cat > .claude/hooks.json << 'EOF'
{
  "description": "Claude Lazy Genius - Automatic Knowledge System",
  "version": "1.0.0",
  "hooks": {
    "SessionStart": [
      {
        "description": "Initialize session with context",
        "hooks": [
          {
            "type": "command",
            "command": "echo \"Session started: $(date +'%Y-%m-%d %H:%M:%S')\" > .claude/session.md && echo \"Developer: $(git config user.name || echo 'unknown')\" >> .claude/session.md"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|MultiEdit|Write",
        "description": "Track all file modifications",
        "hooks": [
          {
            "type": "command",
            "command": "DEV=$(git config user.name | tr ' ' '-' | tr '[:upper:]' '[:lower:]' || echo 'unknown'); echo \"$(date +%H:%M) Edit: $(echo $CLAUDE_TOOL_INPUT | grep -o '\"file_path\":[^,}]*' | cut -d'\"' -f4 || echo 'unknown')\" >> \".claude-team/daily/$(date +%Y-%m-%d)-$DEV.md\""
          }
        ]
      }
    ],
    "Stop": [
      {
        "description": "Finalize session",
        "hooks": [
          {
            "type": "command",
            "command": "DEV=$(git config user.name | tr ' ' '-' | tr '[:upper:]' '[:lower:]' || echo 'unknown'); echo \"\\nSession ended: $(date +%H:%M)\\n---\\n\" >> \".claude-team/daily/$(date +%Y-%m-%d)-$DEV.md\""
          }
        ]
      }
    ]
  }
}
EOF
        echo -e "${GREEN}✓ Hooks installed (embedded version)${NC}"
    fi
}

# Install templates
install_templates() {
    echo -e "${BLUE}📄 Installing templates...${NC}"
    
    # CLAUDE.md - Main instructions
    if [ ! -f "CLAUDE.md" ]; then
        cat > CLAUDE.md << 'EOF'
# Claude Instructions - Lazy Genius Knowledge System

## 🎯 BEFORE YOU START - ALWAYS:
1. Read `.claude-team/SESSION.md` for current focus
2. Check today's work in `.claude-team/daily/`
3. Review `.claude-team/ANTIPATTERNS.md` for what to avoid
4. Check `.claude-team/SOLUTIONS.md` for proven patterns

## 🧠 AUTOMATIC TRACKING:
Your work is automatically tracked. Focus on coding, not documentation.

## 📝 AFTER MAJOR DISCOVERIES:
- Found a solution? → Add to `.claude-team/SOLUTIONS.md`
- Hit a dead end? → Document in `.claude-team/ANTIPATTERNS.md`
- Discovered a pattern? → Add to `.claude-team/patterns/`

## 🔍 WHEN STUCK:
1. Search for similar issues: `grep -r "keyword" .claude-team/`
2. Check if it's a known antipattern
3. Review team solutions
EOF
        echo -e "${GREEN}✓ CLAUDE.md created${NC}"
    else
        echo -e "${YELLOW}⚠️  CLAUDE.md already exists, skipping${NC}"
    fi
    
    # Session focus file
    cat > .claude-team/SESSION.md << 'EOF'
# Current Session Focus

## Today's Goal
<!-- What are you working on today? -->

## Context
<!-- Any important context -->

## Blockers
<!-- Any known issues -->
EOF
    
    # Memory file
    cat > .claude-team/MEMORY.md << 'EOF'
# Project Memory

## Project Overview
- **Started**: Today
- **Team Size**: 1
- **Status**: Active

## Key Decisions
<!-- Important architectural decisions -->

## Conventions
<!-- Coding standards and patterns -->
EOF
    
    # Antipatterns file
    cat > .claude-team/ANTIPATTERNS.md << 'EOF'
# Antipatterns & Things to Avoid

## Don't Do These
<!-- Document what doesn't work -->

## Known Issues
<!-- Problems and their workarounds -->
EOF
    
    # Solutions file
    cat > .claude-team/SOLUTIONS.md << 'EOF'
# Proven Solutions

## What Works
<!-- Document successful patterns -->

## Quick Wins
<!-- Small optimizations that help -->
EOF
    
    echo -e "${GREEN}✓ Templates installed${NC}"
}

# Install scripts
install_scripts() {
    echo -e "${BLUE}🔧 Installing helper scripts...${NC}"
    
    # Analysis script
    cat > .claude-team/scripts/analyze.sh << 'SCRIPT'
#!/bin/bash
# Pattern Analysis - Find hot spots and issues

echo "📊 Pattern Analysis - $(date +%Y-%m-%d)"
echo "================================"
echo ""

echo "🔥 Most edited files (potential issues):"
grep -h "Edit:" .claude-team/daily/*.md 2>/dev/null | \
    sed 's/.*Edit: //' | sort | uniq -c | sort -rn | head -10

echo ""
echo "👥 Team activity today:"
for file in .claude-team/daily/$(date +%Y-%m-%d)*.md; do
    if [ -f "$file" ]; then
        dev=$(basename "$file" .md | sed "s/$(date +%Y-%m-%d)-//")
        lines=$(wc -l < "$file")
        echo "  - $dev: $lines actions"
    fi
done

echo ""
echo "✅ Success indicators:"
grep -l "fixed\|solved\|works" .claude-team/daily/*.md 2>/dev/null | wc -l | \
    xargs echo "  Files with solutions:"
SCRIPT
    chmod +x .claude-team/scripts/analyze.sh
    
    # Sync script
    cat > .claude-team/scripts/sync.sh << 'SCRIPT'
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
SCRIPT
    chmod +x .claude-team/scripts/sync.sh
    
    echo -e "${GREEN}✓ Scripts installed${NC}"
}

# Configure Git
configure_git() {
    echo -e "${BLUE}🔐 Configuring Git...${NC}"
    
    # Add .claude to gitignore
    if ! grep -q "^\.claude/$" .gitignore 2>/dev/null; then
        echo ".claude/" >> .gitignore
        echo -e "${GREEN}✓ Added .claude/ to .gitignore${NC}"
    fi
    
    # Create .gitattributes for merge strategies
    if [ ! -f .gitattributes ]; then
        cat > .gitattributes << 'EOF'
# Claude Lazy Genius merge strategies
.claude-team/daily/*.md merge=union
.claude-team/ANTIPATTERNS.md merge=union
.claude-team/SOLUTIONS.md merge=union
*.md text eol=lf
EOF
        echo -e "${GREEN}✓ Git attributes configured${NC}"
    fi
}

# Final setup
finalize_setup() {
    echo -e "${BLUE}🎯 Finalizing setup...${NC}"
    
    # Create initial commit
    git add .claude-team .gitignore .gitattributes CLAUDE.md 2>/dev/null
    
    if ! git diff --cached --quiet 2>/dev/null; then
        git commit -m "🧠 Initialize Claude Lazy Genius knowledge system" -q
        echo -e "${GREEN}✓ Initial commit created${NC}"
    fi
    
    # Create a test entry to verify it works
    echo "$(date +%H:%M) System: Installation completed" >> ".claude-team/daily/$(date +%Y-%m-%d)-system.md"
}

# Print success message
print_success() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           🎉 Installation Complete!                    ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Quick Start:${NC}"
    echo "  1. Open Claude Code"
    echo "  2. Start coding - everything is tracked automatically!"
    echo "  3. Run ${GREEN}git push${NC} to share knowledge with your team"
    echo ""
    echo -e "${BLUE}Useful Commands:${NC}"
    echo "  ${GREEN}.claude-team/scripts/analyze.sh${NC} - See patterns & hot spots"
    echo "  ${GREEN}.claude-team/scripts/sync.sh${NC}    - Sync with team"
    echo "  ${GREEN}cat .claude-team/daily/$(date +%Y-%m-%d)-*.md${NC} - See today's work"
    echo ""
    echo -e "${YELLOW}📚 Documentation:${NC} https://github.com/Aatish-Dhami/claude-lazy-genius"
    echo ""
}

# Main installation flow
main() {
    check_prerequisites
    detect_setup_type
    create_directories
    install_hooks
    install_templates
    install_scripts
    configure_git
    finalize_setup
    print_success
}

# Handle errors
trap 'echo -e "${RED}❌ Installation failed. Please check the error above.${NC}"; exit 1' ERR

# Run installation
main "$@"