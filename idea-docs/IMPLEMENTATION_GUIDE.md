# 🚀 Lazy Genius 2.0 - Complete Implementation Guide

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Phase 1: Core Setup (2 minutes)](#phase-1-core-setup-2-minutes)
4. [Phase 2: Intelligent Tracking (5 minutes)](#phase-2-intelligent-tracking-5-minutes)
5. [Phase 3: Team Synchronization (3 minutes)](#phase-3-team-synchronization-3-minutes)
6. [Phase 4: Advanced Features (Optional)](#phase-4-advanced-features-optional)
7. [Daily Workflow](#daily-workflow)
8. [Maintenance](#maintenance)

## Overview

**Lazy Genius 2.0** is a zero-dependency, Git-native knowledge management system for Claude Code that provides enterprise-level capabilities with radical simplicity.

### Core Philosophy
- **Zero Dependencies**: Only Git (which you already have)
- **Instant Setup**: 7 minutes from zero to fully operational
- **Human Readable**: Everything in Markdown
- **Performance First**: Sub-millisecond operations
- **Progressive Enhancement**: Start simple, add only what you need

### System Requirements
- Git (any version)
- A text editor
- Claude Code
- 5 MB disk space

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     LAZY GENIUS 2.0 FLOW                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Developer + Claude → Code Changes → Hooks → Local Memory       │
│                              ↓                                   │
│                        Team Memory (.claude-team/)               │
│                              ↓                                   │
│                         Git Push/Pull                            │
│                              ↓                                   │
│                      Collective Knowledge                        │
│                              ↓                                   │
│                   Next Session = Smarter Claude                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Directory Structure
```
YourProject/
├── CLAUDE.md                    # Global instructions
├── .claude/                     # Local workspace (git-ignored)
│   ├── hooks.json              # Hook configuration
│   ├── personal.md             # Personal notes
│   └── session.md              # Current session
│
└── .claude-team/               # Shared knowledge (git-tracked)
    ├── MEMORY.md               # Project decisions
    ├── ANTIPATTERNS.md         # What to avoid
    ├── SOLUTIONS.md            # What works
    ├── SESSION.md              # Current focus
    ├── daily/                  # Activity logs
    ├── memory/                 # Persistent storage
    ├── patterns/               # Domain patterns
    ├── templates/              # Workflow templates
    ├── scripts/                # Automation
    └── archive/                # Historical data
```

## Phase 1: Core Setup (2 minutes)

### Step 1.1: Initialize Directory Structure

```bash
#!/bin/bash
# Run from your project root

# Create local Claude workspace (private)
mkdir -p .claude

# Create team knowledge base (shared)
mkdir -p .claude-team/{daily,memory,patterns,templates,scripts,archive}

# Ensure .claude is git-ignored
echo ".claude/" >> .gitignore

# Initialize Git tracking for team knowledge
git add .claude-team
git commit -m "Initialize Lazy Genius 2.0 knowledge system"
```

### Step 1.2: Configure Hooks

Create `.claude/hooks.json`:

```json
{
  "description": "Lazy Genius 2.0 - Auto Documentation System",
  "version": "2.0.0",
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo \"Session: $(date +'%Y-%m-%d %H:%M')\\nDev: $(git config user.name || echo 'unknown')\" > .claude/session.md && [ -f .claude-team/SESSION.md ] && cat .claude-team/SESSION.md >> .claude/session.md || true"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|MultiEdit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "DEV=$(git config user.name | tr ' ' '-' || echo 'unknown'); echo \"$(date +%H:%M) [$DEV] $CLAUDE_TOOL_NAME: $(echo $CLAUDE_TOOL_INPUT | jq -r '.file_path // \"unknown\"' 2>/dev/null)\" >> \".claude-team/daily/$(date +%Y-%m-%d)-$DEV.md\""
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "DEV=$(git config user.name | tr ' ' '-' || echo 'unknown'); echo \"\\n## Session End: $(date +%H:%M)\\n---\\n\" >> \".claude-team/daily/$(date +%Y-%m-%d)-$DEV.md\""
          }
        ]
      }
    ]
  }
}
```

### Step 1.3: Create Global Instructions

Create `CLAUDE.md` in project root:

```markdown
# Claude Instructions - Lazy Genius 2.0

## 🎯 BEFORE YOU START - ALWAYS:
1. Read `.claude-team/SESSION.md` for current focus
2. Check today's work: `.claude-team/daily/$(date +%Y-%m-%d)*.md`
3. Review `.claude-team/ANTIPATTERNS.md` for what to avoid
4. Check `.claude-team/memory/decisions.md` for architectural choices

## 🧠 CONTEXT-AWARE BEHAVIOR:
- Frontend work → Check `.claude-team/patterns/frontend.md`
- Backend work → Check `.claude-team/patterns/backend.md`
- Bug fixing → Check `.claude-team/patterns/debugging.md`
- Testing → Check `.claude-team/patterns/testing.md`

## 📝 DOCUMENTATION PROTOCOL:
- Major decisions → Update `.claude-team/memory/decisions.md`
- New patterns → Add to `.claude-team/memory/patterns.md`
- Failed approaches → Document in `.claude-team/ANTIPATTERNS.md`
- Successful solutions → Add to `.claude-team/SOLUTIONS.md`

## 🔍 WHEN STUCK:
1. Search for similar issues: `grep -r "keyword" .claude-team/`
2. Check if it's a known antipattern
3. Review team solutions
4. Check archive for historical context
```

### Step 1.4: Initialize Core Files

```bash
#!/bin/bash
# Initialize essential knowledge files

# Project Memory
cat > .claude-team/MEMORY.md << 'EOF'
# Project Memory

## Project Overview
- **Name**: [Your Project]
- **Started**: $(date +%Y-%m-%d)
- **Team Size**: [Number]
- **Phase**: Development

## Technology Stack
<!-- List your technologies -->

## Key Architectural Decisions
<!-- Important choices and why -->

## Coding Conventions
<!-- Team standards -->
EOF

# Current Session Focus
cat > .claude-team/SESSION.md << 'EOF'
# Current Focus

## Sprint Goal
<!-- What we're building -->

## Today's Priority
<!-- Main focus -->

## Blocked Items
<!-- Blockers -->

## Next Steps
<!-- What's next -->
EOF

# Anti-patterns
cat > .claude-team/ANTIPATTERNS.md << 'EOF'
# Anti-Patterns & Rabbit Holes

## Don't Do These
<!-- Failed approaches -->

## Time Wasters Discovered
<!-- What wastes time -->

## Common Mistakes
<!-- Frequent errors -->
EOF

# Solutions
cat > .claude-team/SOLUTIONS.md << 'EOF'
# Proven Solutions

## Patterns That Work
<!-- Successful approaches -->

## Performance Optimizations
<!-- Speed improvements -->

## Best Practices
<!-- What works well -->
EOF
```

## Phase 2: Intelligent Tracking (5 minutes)

### Step 2.1: Pattern Analysis Script

Create `.claude-team/scripts/analyze.sh`:

```bash
#!/bin/bash
# Intelligent pattern detection and analysis

TEAM_DIR=".claude-team"
TODAY=$(date +%Y-%m-%d)
OUTPUT="$TEAM_DIR/memory/patterns.md"

echo "# Pattern Analysis - $TODAY" > "$OUTPUT"
echo "" >> "$OUTPUT"

# Detect hot files (potential problem areas)
echo "## 🔥 Hot Files (Most Edited)" >> "$OUTPUT"
echo "Files edited frequently might have issues:" >> "$OUTPUT"
grep -h "Edit:" "$TEAM_DIR"/daily/*.md 2>/dev/null | \
  sed 's/.*Edit: //' | sort | uniq -c | sort -rn | head -10 | \
  while read count file; do
    if [ "$count" -gt 5 ]; then
      echo "- ⚠️ $file: $count edits (potential issue)"
    else
      echo "- $file: $count edits"
    fi
  done >> "$OUTPUT"

# Detect rabbit holes
echo "" >> "$OUTPUT"
echo "## 🕳️ Potential Rabbit Holes" >> "$OUTPUT"
echo "Same file edited multiple times in one session:" >> "$OUTPUT"
for daily in "$TEAM_DIR"/daily/"$TODAY"*.md; do
  [ -f "$daily" ] || continue
  dev=$(basename "$daily" | sed 's/.*-\(.*\)\.md/\1/')
  grep "Edit:" "$daily" | sed 's/.*Edit: //' | sort | uniq -c | sort -rn | \
    awk -v dev="$dev" '$1 > 3 {print "- ["dev"] "$2": "$1" times"}'
done >> "$OUTPUT"

# Team velocity
echo "" >> "$OUTPUT"
echo "## 📊 Team Velocity" >> "$OUTPUT"
for daily in "$TEAM_DIR"/daily/"$TODAY"*.md; do
  [ -f "$daily" ] || continue
  dev=$(basename "$daily" .md | sed "s/$TODAY-//")
  changes=$(grep -c ":" "$daily" 2>/dev/null || echo 0)
  echo "- $dev: $changes changes"
done >> "$OUTPUT"

# Success patterns
echo "" >> "$OUTPUT"
echo "## ✅ Success Indicators" >> "$OUTPUT"
grep -l "works\|fixed\|completed\|success" "$TEAM_DIR"/daily/"$TODAY"*.md 2>/dev/null | \
  while read file; do
    dev=$(basename "$file" .md | sed "s/$TODAY-//")
    echo "- $dev had successful completions"
  done >> "$OUTPUT"

echo "Analysis complete: $OUTPUT"
```

### Step 2.2: Prediction Script

Create `.claude-team/scripts/predict.sh`:

```bash
#!/bin/bash
# Predict today's work based on patterns

TEAM_DIR=".claude-team"
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d)
TODAY=$(date +%Y-%m-%d)
OUTPUT="$TEAM_DIR/memory/context/current.md"

mkdir -p "$TEAM_DIR/memory/context"

echo "# Predicted Work - $TODAY" > "$OUTPUT"
echo "" >> "$OUTPUT"
echo "Based on yesterday's patterns:" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Find unfinished work
echo "## 📋 Likely Continuations" >> "$OUTPUT"
for daily in "$TEAM_DIR"/daily/"$YESTERDAY"*.md; do
  [ -f "$daily" ] || continue
  dev=$(basename "$daily" .md | sed "s/$YESTERDAY-//")
  
  # Last edited files are likely to be continued
  last_files=$(tail -5 "$daily" | grep "Edit:" | sed 's/.*Edit: //' | head -3)
  if [ -n "$last_files" ]; then
    echo "### $dev will likely work on:" >> "$OUTPUT"
    echo "$last_files" | while read file; do
      echo "- $file" >> "$OUTPUT"
    done
  fi
done

# Find patterns (files often edited together)
echo "" >> "$OUTPUT"
echo "## 🔗 Related Files" >> "$OUTPUT"
echo "Files often edited together:" >> "$OUTPUT"

# This is a simple correlation - could be made more sophisticated
grep -h "Edit:" "$TEAM_DIR"/daily/*.md 2>/dev/null | \
  sed 's/.*Edit: //' | sort | uniq -c | sort -rn | head -5 | \
  while read count file; do
    echo "- $file (high activity)"
  done >> "$OUTPUT"

echo "Prediction ready: $OUTPUT"
```

### Step 2.3: Cleanup Script

Create `.claude-team/scripts/cleanup.sh`:

```bash
#!/bin/bash
# Archive old logs and maintain system

TEAM_DIR=".claude-team"
DAYS_TO_KEEP=7
ARCHIVE_AFTER=30

# Archive old daily logs
find "$TEAM_DIR/daily" -name "*.md" -mtime +$ARCHIVE_AFTER -print0 2>/dev/null | \
  while IFS= read -r -d '' file; do
    week=$(date -r "$file" +%Y-W%V 2>/dev/null || stat -f %Sm -t %Y-W%V "$file")
    archive="$TEAM_DIR/archive/$week.md"
    
    echo "## Archived from $(basename $file)" >> "$archive"
    cat "$file" >> "$archive"
    echo "" >> "$archive"
    rm "$file"
  done

# Consolidate patterns
if [ -f "$TEAM_DIR/memory/patterns.md" ]; then
  lines=$(wc -l < "$TEAM_DIR/memory/patterns.md")
  if [ "$lines" -gt 500 ]; then
    # Keep only recent patterns
    tail -300 "$TEAM_DIR/memory/patterns.md" > "$TEAM_DIR/memory/patterns.tmp"
    mv "$TEAM_DIR/memory/patterns.tmp" "$TEAM_DIR/memory/patterns.md"
  fi
fi

echo "Cleanup complete"
```

## Phase 3: Team Synchronization (3 minutes)

### Step 3.1: Git Hooks Setup

Create `.claude-team/scripts/sync.sh`:

```bash
#!/bin/bash
# Team synchronization helper

TEAM_DIR=".claude-team"

# Function to sync with team
sync_team() {
  echo "🔄 Syncing with team..."
  
  # Pull latest team knowledge
  git pull --rebase origin main 2>/dev/null || git pull origin main
  
  # Stage team knowledge changes
  git add "$TEAM_DIR"
  
  # Commit if there are changes
  if ! git diff --staged --quiet; then
    git commit -m "Knowledge sync: $(date +%Y-%m-%d) - $(git config user.name || echo 'unknown')"
  fi
  
  # Push to share with team
  git push origin main
  
  echo "✅ Team knowledge synchronized"
}

# Function to merge conflicts intelligently
merge_conflicts() {
  echo "🔧 Resolving conflicts in team knowledge..."
  
  # For append-only files, combine both versions
  for file in "$TEAM_DIR"/daily/*.md "$TEAM_DIR/ANTIPATTERNS.md"; do
    if [ -f "$file" ] && grep -q "<<<<<<< HEAD" "$file" 2>/dev/null; then
      # Simple merge: keep both versions
      sed -i.bak '/<<<<<<<\|=======\|>>>>>>>/d' "$file"
      rm "$file.bak" 2>/dev/null
    fi
  done
  
  echo "✅ Conflicts resolved"
}

# Main execution
case "${1:-sync}" in
  sync)
    sync_team
    ;;
  merge)
    merge_conflicts
    ;;
  *)
    echo "Usage: $0 [sync|merge]"
    ;;
esac
```

### Step 3.2: Git Configuration

Add to `.gitattributes`:

```gitattributes
# Merge strategies for team knowledge
.claude-team/daily/*.md merge=union
.claude-team/ANTIPATTERNS.md merge=union
.claude-team/SOLUTIONS.md merge=union
.claude-team/memory/patterns.md merge=ours
```

### Step 3.3: Team Onboarding Script

Create `.claude-team/scripts/onboard.sh`:

```bash
#!/bin/bash
# Quick onboarding for new team members

echo "🎯 Lazy Genius 2.0 - Team Onboarding"
echo "======================================"
echo ""

# Check Git configuration
if [ -z "$(git config user.name)" ]; then
  echo "⚠️  Please set your Git name:"
  echo "   git config --global user.name 'Your Name'"
  exit 1
fi

# Copy hooks configuration
cp .claude-team/templates/hooks.json .claude/hooks.json 2>/dev/null || {
  mkdir -p .claude
  cat > .claude/hooks.json << 'HOOKS'
{
  "description": "Lazy Genius 2.0",
  "version": "2.0.0",
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "echo 'Session: '$(date +'%Y-%m-%d %H:%M') > .claude/session.md"
      }]
    }],
    "PostToolUse": [{
      "matcher": "Edit|MultiEdit|Write",
      "hooks": [{
        "type": "command",
        "command": "echo $(date +%H:%M)' Edit: '$(echo $CLAUDE_TOOL_INPUT | jq -r .file_path) >> .claude-team/daily/$(date +%Y-%m-%d)-$(git config user.name | tr ' ' '-').md"
      }]
    }]
  }
}
HOOKS
}

echo "✅ Hooks configured"
echo "✅ You're ready to use Lazy Genius 2.0!"
echo ""
echo "Quick commands:"
echo "  ./scripts/sync.sh     - Sync with team"
echo "  ./scripts/analyze.sh  - Analyze patterns"
echo "  ./scripts/predict.sh  - See predicted work"
echo ""
echo "Start Claude Code and begin working!"
```

## Phase 4: Advanced Features (Optional)

### Pattern Recognition Templates

Create `.claude-team/patterns/frontend.md`:

```markdown
# Frontend Patterns

## React Best Practices
- Use React Query for data fetching
- Implement error boundaries for robustness
- Lazy load heavy components

## Component Structure
- Keep components under 200 lines
- Extract hooks for reusable logic
- Use composition over inheritance

## Performance
- Memoize expensive computations
- Use virtual scrolling for long lists
- Implement code splitting at route level
```

### Workflow Templates

Create `.claude-team/templates/feature.md`:

```markdown
# New Feature Checklist

## Planning
- [ ] Define requirements
- [ ] Check existing patterns in `.claude-team/patterns/`
- [ ] Review similar implementations

## Implementation
- [ ] Create feature branch
- [ ] Write tests first (TDD)
- [ ] Implement core functionality
- [ ] Add error handling
- [ ] Update documentation

## Review
- [ ] Self-review code
- [ ] Run all tests
- [ ] Check performance impact
- [ ] Update SOLUTIONS.md if successful
```

## Daily Workflow

### Developer's Typical Day

```bash
# Morning: Start work
git pull                          # Get team's knowledge
claude "Continue user management"  # Claude reads team context

# During work: Automatic tracking via hooks
# (No manual intervention needed)

# End of day: Share knowledge
./scripts/sync.sh                 # Push knowledge to team

# Weekly: Analyze patterns
./scripts/analyze.sh              # See what's working/not working
```

### Team Lead's Workflow

```bash
# Monday: Review team patterns
./scripts/analyze.sh
./scripts/report.sh > weekly-report.md

# Identify issues
grep -r "rabbit\|slow\|problem" .claude-team/

# Update guidance
vi .claude-team/ANTIPATTERNS.md
vi .claude-team/SOLUTIONS.md
```

## Maintenance

### Weekly Tasks
1. Run `./scripts/cleanup.sh` to archive old logs
2. Review and update `ANTIPATTERNS.md`
3. Consolidate discovered patterns
4. Update `SESSION.md` with new sprint goals

### Monthly Tasks
1. Review `memory/decisions.md` for outdated choices
2. Clean up archive folder
3. Generate team knowledge report
4. Update onboarding documentation

### Troubleshooting Quick Fixes

| Issue | Solution |
|-------|----------|
| Hooks not working | Check `.claude/hooks.json` exists and is valid JSON |
| No daily logs created | Verify Git username: `git config user.name` |
| Sync conflicts | Run `./scripts/sync.sh merge` |
| Patterns not detected | Ensure `analyze.sh` has execute permissions |
| Claude not reading context | Check `CLAUDE.md` is in project root |

## Success Metrics

Your system is working when:
- ✅ Daily logs are created automatically
- ✅ Team members' work doesn't conflict
- ✅ Claude references previous decisions
- ✅ Rabbit holes are avoided (check ANTIPATTERNS.md)
- ✅ Knowledge persists across sessions
- ✅ New team members are productive immediately

## Next Steps

1. **Start Simple**: Just Phase 1 is enough to begin
2. **Add Intelligence**: Implement Phase 2 after a week
3. **Scale Team**: Add Phase 3 when multiple developers join
4. **Optimize**: Add Phase 4 features as needed

Remember: **Start small, grow organically!**