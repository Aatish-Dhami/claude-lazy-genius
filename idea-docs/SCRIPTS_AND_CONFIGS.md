# 📦 Scripts and Configurations - Complete Code Repository

## Table of Contents
1. [Core Configuration Files](#core-configuration-files)
2. [Shell Scripts](#shell-scripts)
3. [Template Files](#template-files)
4. [Git Configuration](#git-configuration)
5. [Quick Setup Script](#quick-setup-script)
6. [Advanced Scripts](#advanced-scripts)

---

## Core Configuration Files

### 📄 `.claude/hooks.json` - Complete Hook Configuration

```json
{
  "description": "Lazy Genius 2.0 - Automatic Knowledge Management",
  "version": "2.0.0",
  "author": "Your Team",
  "hooks": {
    "SessionStart": [
      {
        "description": "Initialize session with team context",
        "hooks": [
          {
            "type": "command",
            "command": "mkdir -p .claude-team/daily .claude-team/memory/context && echo \"Session Started: $(date +'%Y-%m-%d %H:%M:%S')\" > .claude/session.md && echo \"Developer: $(git config user.name || echo 'unknown')\" >> .claude/session.md && echo \"Branch: $(git branch --show-current 2>/dev/null || echo 'main')\" >> .claude/session.md && [ -f .claude-team/SESSION.md ] && cat .claude-team/SESSION.md >> .claude/session.md || echo 'No team session found' >> .claude/session.md && [ -f .claude-team/memory/context/current.md ] && echo '\\n--- Predicted Work ---' >> .claude/session.md && cat .claude-team/memory/context/current.md >> .claude/session.md || true"
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
            "command": "DEV=$(git config user.name | tr ' ' '-' | tr '[:upper:]' '[:lower:]' || echo 'unknown'); FILE=$(echo $CLAUDE_TOOL_INPUT | jq -r '.file_path // .file_path // \"unknown\"' 2>/dev/null || echo 'unknown'); echo \"$(date +%H:%M:%S) [$DEV] $CLAUDE_TOOL_NAME: $FILE\" >> \".claude-team/daily/$(date +%Y-%m-%d)-$DEV.md\" && echo \"$FILE\" >> \".claude/session-files.tmp\""
          }
        ]
      },
      {
        "matcher": "Bash",
        "description": "Track command execution",
        "hooks": [
          {
            "type": "command",
            "command": "DEV=$(git config user.name | tr ' ' '-' | tr '[:upper:]' '[:lower:]' || echo 'unknown'); CMD=$(echo $CLAUDE_TOOL_INPUT | jq -r '.command' 2>/dev/null | head -c 100); echo \"$(date +%H:%M:%S) [$DEV] Command: $CMD\" >> \".claude-team/daily/$(date +%Y-%m-%d)-$DEV.md\""
          }
        ]
      }
    ],
    "Stop": [
      {
        "description": "Finalize session and analyze patterns",
        "hooks": [
          {
            "type": "command",
            "command": "DEV=$(git config user.name | tr ' ' '-' | tr '[:upper:]' '[:lower:]' || echo 'unknown'); echo \"\\n## Session End: $(date +'%H:%M:%S')\\nDuration: $(($(date +%s) - $(stat -f %B .claude/session.md 2>/dev/null || echo $(date +%s))))s\\n---\\n\" >> \".claude-team/daily/$(date +%Y-%m-%d)-$DEV.md\" && [ -f .claude/session-files.tmp ] && echo '\\n### Files Modified This Session:' >> \".claude-team/daily/$(date +%Y-%m-%d)-$DEV.md\" && sort -u .claude/session-files.tmp | sed 's/^/- /' >> \".claude-team/daily/$(date +%Y-%m-%d)-$DEV.md\" && rm .claude/session-files.tmp || true"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "description": "Log user intentions",
        "hooks": [
          {
            "type": "command",
            "command": "INTENT=$(echo \"$CLAUDE_USER_PROMPT\" | head -c 200 | tr '\\n' ' '); echo \"$(date +%H:%M:%S) Intent: $INTENT\" >> .claude/intentions.log"
          }
        ]
      }
    ]
  }
}
```

### 📄 `CLAUDE.md` - Root Instructions

```markdown
# Claude Instructions - Lazy Genius 2.0

## 🎯 MANDATORY STARTUP SEQUENCE
1. Read `.claude-team/SESSION.md` for current sprint focus
2. Check `.claude-team/daily/$(date +%Y-%m-%d)*.md` for today's work
3. Review `.claude-team/ANTIPATTERNS.md` for known issues
4. Check `.claude-team/memory/decisions.md` for architectural decisions

## 🧠 ADAPTIVE BEHAVIOR RULES

### Context Detection
Automatically adapt based on the files being edited:
- `**/test/*` or `*.test.*` → Testing mode: Ensure comprehensive coverage
- `**/api/*` → API mode: Follow REST conventions, check endpoints
- `**/components/*` → Component mode: Check reusability, props validation
- `**/docs/*` → Documentation mode: Clear, concise, examples

### Pattern Matching
Before implementing anything:
1. Search for similar patterns: `grep -r "pattern" .claude-team/patterns/`
2. Check if solution exists: Review `.claude-team/SOLUTIONS.md`
3. Verify not an anti-pattern: Check `.claude-team/ANTIPATTERNS.md`

## 📝 CONTINUOUS DOCUMENTATION

### After Major Changes
- Architectural decision → Update `.claude-team/memory/decisions.md`
- New pattern discovered → Add to `.claude-team/memory/patterns.md`  
- Performance optimization → Document in `.claude-team/SOLUTIONS.md`
- Failed approach → Record in `.claude-team/ANTIPATTERNS.md`

### Session Tracking
- Beginning: Note focus area in `.claude/session.md`
- During: Changes auto-tracked by hooks
- End: Review session summary in daily log

## 🚨 PROBLEM DETECTION

### Rabbit Hole Indicators
- Editing same file >5 times → Step back, review approach
- Multiple failed attempts → Check ANTIPATTERNS.md
- Circular dependencies → Review architecture

### Recovery Protocol
1. Stop current approach
2. Document failure in ANTIPATTERNS.md
3. Search team solutions
4. Try alternative approach

## ⚡ PERFORMANCE GUIDELINES
- Hook overhead: <1ms per operation
- Knowledge lookup: Use grep for instant search
- Memory files: Kept under 1MB each
- Archive after 30 days automatically

## 🔄 KNOWLEDGE SHARING
- Every session contributes to team knowledge
- Patterns emerge from collective work
- Solutions are preserved and reused
- Failures prevent repeated mistakes
```

---

## Shell Scripts

### 🔧 `analyze.sh` - Pattern Detection and Analysis

```bash
#!/bin/bash
# Intelligent Pattern Analysis System
# Detects hot spots, rabbit holes, and team velocity

set -euo pipefail

TEAM_DIR=".claude-team"
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d)
OUTPUT_DIR="$TEAM_DIR/memory"
REPORT="$OUTPUT_DIR/analysis-$TODAY.md"

mkdir -p "$OUTPUT_DIR"

# Header
cat > "$REPORT" << EOF
# 📊 Pattern Analysis Report
**Date**: $TODAY  
**Generated**: $(date +'%H:%M:%S')

---

EOF

# Function to detect hot files
detect_hot_files() {
  echo "## 🔥 Hot Files (Potential Issues)" >> "$REPORT"
  echo "" >> "$REPORT"
  
  if ls "$TEAM_DIR"/daily/*.md 1> /dev/null 2>&1; then
    grep -h "Edit:\|MultiEdit:\|Write:" "$TEAM_DIR"/daily/*.md 2>/dev/null | \
      sed 's/.*\(Edit\|MultiEdit\|Write\): //' | \
      sort | uniq -c | sort -rn | head -15 | \
      while read count file; do
        if [ "$count" -gt 10 ]; then
          echo "- 🚨 **$file**: $count edits (critical - needs refactoring?)" >> "$REPORT"
        elif [ "$count" -gt 5 ]; then
          echo "- ⚠️ **$file**: $count edits (warning - complex area)" >> "$REPORT"
        else
          echo "- $file: $count edits" >> "$REPORT"
        fi
      done
  else
    echo "*No activity data found*" >> "$REPORT"
  fi
  echo "" >> "$REPORT"
}

# Function to detect rabbit holes
detect_rabbit_holes() {
  echo "## 🕳️ Rabbit Hole Detection" >> "$REPORT"
  echo "" >> "$REPORT"
  
  for daily in "$TEAM_DIR"/daily/"$TODAY"*.md; do
    [ -f "$daily" ] || continue
    
    dev=$(basename "$daily" .md | sed "s/$TODAY-//")
    echo "### Developer: $dev" >> "$REPORT"
    
    # Files edited multiple times in same session
    grep -o "Edit: [^\"]*" "$daily" 2>/dev/null | \
      sed 's/Edit: //' | sort | uniq -c | sort -rn | \
      while read count file; do
        if [ "$count" -gt 3 ]; then
          echo "- ⚠️ $file: edited $count times in one session" >> "$REPORT"
        fi
      done
    echo "" >> "$REPORT"
  done
}

# Function to calculate velocity
calculate_velocity() {
  echo "## 📈 Team Velocity Metrics" >> "$REPORT"
  echo "" >> "$REPORT"
  
  total_changes=0
  active_devs=0
  
  echo "### Today's Activity" >> "$REPORT"
  for daily in "$TEAM_DIR"/daily/"$TODAY"*.md; do
    [ -f "$daily" ] || continue
    
    dev=$(basename "$daily" .md | sed "s/$TODAY-//")
    changes=$(grep -c "$(date +%H):" "$daily" 2>/dev/null || echo 0)
    sessions=$(grep -c "Session End:" "$daily" 2>/dev/null || echo 0)
    
    echo "- **$dev**: $changes changes in $sessions sessions" >> "$REPORT"
    total_changes=$((total_changes + changes))
    active_devs=$((active_devs + 1))
  done
  
  echo "" >> "$REPORT"
  echo "**Total**: $total_changes changes by $active_devs developers" >> "$REPORT"
  echo "" >> "$REPORT"
}

# Function to find patterns
find_patterns() {
  echo "## 🔍 Discovered Patterns" >> "$REPORT"
  echo "" >> "$REPORT"
  
  # Files often edited together
  echo "### Files Often Modified Together" >> "$REPORT"
  temp_file="/tmp/claude-patterns-$$"
  
  for daily in "$TEAM_DIR"/daily/*.md; do
    [ -f "$daily" ] || continue
    grep "Edit:" "$daily" 2>/dev/null | sed 's/.*Edit: //' >> "$temp_file"
  done
  
  if [ -f "$temp_file" ] && [ -s "$temp_file" ]; then
    # Simple correlation: files appearing in same session
    sort "$temp_file" | uniq -c | sort -rn | head -5 | \
      while read count file; do
        echo "- $file (appears in $count sessions)" >> "$REPORT"
      done
  else
    echo "*No patterns detected yet*" >> "$REPORT"
  fi
  
  rm -f "$temp_file"
  echo "" >> "$REPORT"
}

# Function to detect success indicators
detect_success() {
  echo "## ✅ Success Indicators" >> "$REPORT"
  echo "" >> "$REPORT"
  
  success_count=$(grep -i "fixed\|completed\|success\|works\|done" "$TEAM_DIR"/daily/"$TODAY"*.md 2>/dev/null | wc -l || echo 0)
  error_count=$(grep -i "error\|failed\|broken\|bug" "$TEAM_DIR"/daily/"$TODAY"*.md 2>/dev/null | wc -l || echo 0)
  
  echo "- Success mentions: $success_count" >> "$REPORT"
  echo "- Error mentions: $error_count" >> "$REPORT"
  
  if [ "$success_count" -gt "$error_count" ]; then
    echo "- **Status**: 🟢 Productive day!" >> "$REPORT"
  else
    echo "- **Status**: 🔴 Challenging day - check ANTIPATTERNS.md" >> "$REPORT"
  fi
  echo "" >> "$REPORT"
}

# Main execution
echo "🔍 Starting pattern analysis..."

detect_hot_files
detect_rabbit_holes
calculate_velocity
find_patterns
detect_success

# Summary
cat >> "$REPORT" << EOF
## 📋 Recommendations

Based on today's analysis:
EOF

# Generate recommendations
if grep -q "🚨" "$REPORT"; then
  echo "1. **Critical**: Review files marked with 🚨 for refactoring" >> "$REPORT"
fi

if grep -q "rabbit" "$REPORT"; then
  echo "2. **Attention**: Potential rabbit holes detected - review approach" >> "$REPORT"
fi

echo "3. **Action**: Update ANTIPATTERNS.md with any failed approaches" >> "$REPORT"
echo "4. **Share**: Commit and push team knowledge at end of day" >> "$REPORT"

echo "" >> "$REPORT"
echo "---" >> "$REPORT"
echo "*Generated by Lazy Genius 2.0*" >> "$REPORT"

echo "✅ Analysis complete: $REPORT"
echo ""
echo "Key findings:"
grep "🚨\|⚠️\|🟢\|🔴" "$REPORT" | head -5
```

### 🔮 `predict.sh` - Work Prediction

```bash
#!/bin/bash
# Predictive Work Analysis
# Anticipates today's work based on patterns

set -euo pipefail

TEAM_DIR=".claude-team"
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d)
TODAY=$(date +%Y-%m-%d)
OUTPUT="$TEAM_DIR/memory/context/current.md"

mkdir -p "$TEAM_DIR/memory/context"

cat > "$OUTPUT" << EOF
# 🔮 Predicted Work Context
**Date**: $TODAY  
**Based on**: Previous patterns

---

## 📋 Likely Continuations

EOF

# Analyze yesterday's work
for daily in "$TEAM_DIR"/daily/"$YESTERDAY"*.md; do
  [ -f "$daily" ] || continue
  
  dev=$(basename "$daily" .md | sed "s/$YESTERDAY-//")
  
  # Get last 5 edited files (likely to continue)
  last_files=$(grep "Edit:\|Write:" "$daily" 2>/dev/null | tail -5 | sed 's/.*\(Edit\|Write\): //' | sort -u)
  
  if [ -n "$last_files" ]; then
    echo "### $dev will likely work on:" >> "$OUTPUT"
    echo "$last_files" | while IFS= read -r file; do
      echo "- $file" >> "$OUTPUT"
    done
    echo "" >> "$OUTPUT"
  fi
done

# Find incomplete patterns
echo "## 🔄 Potentially Incomplete Work" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Look for TODOs and FIXMEs
if ls "$TEAM_DIR"/daily/"$YESTERDAY"*.md 1> /dev/null 2>&1; then
  grep -h "TODO\|FIXME\|WIP\|PENDING" "$TEAM_DIR"/daily/"$YESTERDAY"*.md 2>/dev/null | head -5 | \
    while IFS= read -r line; do
      echo "- $line" >> "$OUTPUT"
    done
fi

echo "" >> "$OUTPUT"

# Suggest focus areas
echo "## 🎯 Suggested Focus Areas" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Files with most edits recently (need attention)
if ls "$TEAM_DIR"/daily/*.md 1> /dev/null 2>&1; then
  grep -h "Edit:" "$TEAM_DIR"/daily/*.md 2>/dev/null | \
    sed 's/.*Edit: //' | sort | uniq -c | sort -rn | head -3 | \
    while read count file; do
      echo "- **$file**: High activity ($count edits) - may need refactoring" >> "$OUTPUT"
    done
fi

echo "" >> "$OUTPUT"
echo "---" >> "$OUTPUT"
echo "*Use this context to continue where the team left off*" >> "$OUTPUT"

echo "✅ Prediction ready: $OUTPUT"
```

### 🧹 `cleanup.sh` - Maintenance Script

```bash
#!/bin/bash
# System Maintenance and Cleanup
# Archives old logs and optimizes storage

set -euo pipefail

TEAM_DIR=".claude-team"
ARCHIVE_AFTER_DAYS=30
MAX_PATTERN_LINES=500
MAX_MEMORY_SIZE_KB=1024

echo "🧹 Starting cleanup and maintenance..."

# Function to archive old daily logs
archive_old_logs() {
  echo "📦 Archiving logs older than $ARCHIVE_AFTER_DAYS days..."
  
  find "$TEAM_DIR/daily" -name "*.md" -mtime +$ARCHIVE_AFTER_DAYS 2>/dev/null | \
    while IFS= read -r file; do
      date_str=$(basename "$file" .md | cut -d'-' -f1-3)
      week=$(date -d "$date_str" +%Y-W%V 2>/dev/null || echo "archived")
      archive_file="$TEAM_DIR/archive/$week.md"
      
      mkdir -p "$TEAM_DIR/archive"
      
      echo "## Archived: $(basename $file)" >> "$archive_file"
      echo "Date: $date_str" >> "$archive_file"
      cat "$file" >> "$archive_file"
      echo -e "\\n---\\n" >> "$archive_file"
      
      rm "$file"
      echo "  Archived: $(basename $file) → $week.md"
    done
}

# Function to optimize pattern files
optimize_patterns() {
  echo "📊 Optimizing pattern files..."
  
  for pattern_file in "$TEAM_DIR"/memory/*.md; do
    [ -f "$pattern_file" ] || continue
    
    lines=$(wc -l < "$pattern_file" 2>/dev/null || echo 0)
    if [ "$lines" -gt "$MAX_PATTERN_LINES" ]; then
      temp_file="/tmp/pattern-optimize-$$"
      echo "# Pattern History (Optimized on $TODAY)" > "$temp_file"
      echo "" >> "$temp_file"
      tail -n $((MAX_PATTERN_LINES - 100)) "$pattern_file" >> "$temp_file"
      mv "$temp_file" "$pattern_file"
      echo "  Optimized: $(basename $pattern_file) ($lines → $MAX_PATTERN_LINES lines)"
    fi
  done
}

# Function to clean temporary files
clean_temp_files() {
  echo "🗑️ Cleaning temporary files..."
  
  # Remove old session files
  find .claude -name "*.tmp" -mtime +1 -delete 2>/dev/null || true
  find .claude -name "session-*.md" -mtime +7 -delete 2>/dev/null || true
  
  # Clean empty daily logs
  find "$TEAM_DIR/daily" -name "*.md" -size 0 -delete 2>/dev/null || true
  
  echo "  Temporary files cleaned"
}

# Function to generate summary
generate_summary() {
  echo "📝 Generating archive summary..."
  
  summary="$TEAM_DIR/archive/SUMMARY.md"
  
  cat > "$summary" << EOF
# Archive Summary
**Generated**: $(date +'%Y-%m-%d %H:%M:%S')

## Archived Weeks
EOF
  
  ls "$TEAM_DIR/archive" | grep -E "^[0-9]{4}-W[0-9]{2}\.md$" | while read week; do
    size=$(du -h "$TEAM_DIR/archive/$week" | cut -f1)
    echo "- $week ($size)" >> "$summary"
  done
  
  echo "" >> "$summary"
  echo "Total archived: $(ls "$TEAM_DIR/archive" | grep -E "^[0-9]{4}-W[0-9]{2}\.md$" | wc -l) weeks" >> "$summary"
}

# Function to check system health
check_health() {
  echo "🏥 Checking system health..."
  
  # Check directory sizes
  team_size=$(du -sh "$TEAM_DIR" 2>/dev/null | cut -f1)
  daily_count=$(ls "$TEAM_DIR/daily" 2>/dev/null | wc -l)
  
  echo "  Team knowledge size: $team_size"
  echo "  Active daily logs: $daily_count"
  
  # Warn if growing too large
  size_kb=$(du -sk "$TEAM_DIR" 2>/dev/null | cut -f1)
  if [ "$size_kb" -gt 10240 ]; then
    echo "  ⚠️ Warning: Team knowledge exceeds 10MB - consider more aggressive archiving"
  fi
}

# Main execution
archive_old_logs
optimize_patterns
clean_temp_files
generate_summary
check_health

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "Tips:"
echo "  - Run weekly for optimal performance"
echo "  - Check $TEAM_DIR/archive/ for historical data"
echo "  - Commit changes after cleanup"
```

### 🔄 `sync.sh` - Team Synchronization

```bash
#!/bin/bash
# Team Knowledge Synchronization
# Handles git operations and conflict resolution

set -euo pipefail

TEAM_DIR=".claude-team"
BRANCH=$(git branch --show-current 2>/dev/null || echo "main")

# Colors for output
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
NC='\\033[0m' # No Color

# Function to sync with team
sync_team() {
  echo -e "${GREEN}🔄 Synchronizing team knowledge...${NC}"
  
  # Stash any local changes
  echo "  Stashing local changes..."
  git stash push -q -m "Claude sync stash $(date +%Y-%m-%d_%H:%M:%S)" || true
  
  # Pull latest team knowledge
  echo "  Pulling latest team knowledge..."
  if git pull --rebase origin "$BRANCH" 2>/dev/null; then
    echo -e "${GREEN}  ✓ Successfully pulled latest changes${NC}"
  else
    echo -e "${YELLOW}  ⚠️ Pull failed, attempting merge...${NC}"
    git pull origin "$BRANCH" --no-rebase
  fi
  
  # Pop stash if exists
  if git stash list | grep -q "Claude sync stash"; then
    echo "  Restoring local changes..."
    git stash pop -q || echo -e "${YELLOW}  ⚠️ Stash pop failed - manual intervention needed${NC}"
  fi
  
  # Stage team knowledge changes
  echo "  Staging team knowledge..."
  git add "$TEAM_DIR" 2>/dev/null || true
  
  # Commit if there are changes
  if ! git diff --cached --quiet 2>/dev/null; then
    echo "  Creating commit..."
    commit_msg="Knowledge sync: $(date +%Y-%m-%d) - $(git config user.name || echo 'unknown')"
    git commit -m "$commit_msg" -q
    echo -e "${GREEN}  ✓ Changes committed${NC}"
  else
    echo "  No local changes to commit"
  fi
  
  # Push changes
  echo "  Pushing to remote..."
  if git push origin "$BRANCH" 2>/dev/null; then
    echo -e "${GREEN}  ✓ Successfully pushed changes${NC}"
  else
    echo -e "${YELLOW}  ⚠️ Push failed - pull and retry${NC}"
    git pull --rebase origin "$BRANCH"
    git push origin "$BRANCH"
  fi
  
  echo -e "${GREEN}✅ Synchronization complete!${NC}"
}

# Function to resolve conflicts
resolve_conflicts() {
  echo -e "${YELLOW}🔧 Resolving conflicts...${NC}"
  
  # Find conflicted files
  conflicted=$(git diff --name-only --diff-filter=U)
  
  if [ -z "$conflicted" ]; then
    echo "  No conflicts found"
    return 0
  fi
  
  echo "$conflicted" | while IFS= read -r file; do
    if [[ "$file" == *.md ]] && [[ "$file" == *"$TEAM_DIR"* ]]; then
      echo "  Resolving: $file"
      
      # For append-only files (daily logs, antipatterns), keep both versions
      if [[ "$file" == */daily/*.md ]] || [[ "$file" == */ANTIPATTERNS.md ]]; then
        # Remove conflict markers, keep all content
        sed -i.backup '/<<<<<<<.*\|=======\|>>>>>>>.*/d' "$file"
        rm "${file}.backup" 2>/dev/null || true
        git add "$file"
        echo "    ✓ Merged both versions"
      else
        echo "    ⚠️ Manual resolution needed"
      fi
    fi
  done
  
  # Check if all conflicts resolved
  if git diff --name-only --diff-filter=U | grep -q .; then
    echo -e "${RED}  Some conflicts remain - manual intervention required${NC}"
    return 1
  else
    echo -e "${GREEN}  ✓ All conflicts resolved${NC}"
    return 0
  fi
}

# Function to show status
show_status() {
  echo -e "${GREEN}📊 Knowledge Base Status${NC}"
  echo ""
  
  # Today's activity
  today=$(date +%Y-%m-%d)
  today_files=$(ls "$TEAM_DIR/daily/$today"*.md 2>/dev/null | wc -l)
  echo "  Today's logs: $today_files developers active"
  
  # Knowledge size
  if [ -d "$TEAM_DIR" ]; then
    size=$(du -sh "$TEAM_DIR" | cut -f1)
    echo "  Knowledge size: $size"
  fi
  
  # Git status
  ahead=$(git rev-list --count origin/"$BRANCH".."$BRANCH" 2>/dev/null || echo 0)
  behind=$(git rev-list --count "$BRANCH"..origin/"$BRANCH" 2>/dev/null || echo 0)
  
  if [ "$ahead" -gt 0 ]; then
    echo -e "  Git: ${YELLOW}$ahead commits ahead${NC}"
  fi
  if [ "$behind" -gt 0 ]; then
    echo -e "  Git: ${YELLOW}$behind commits behind${NC}"
  fi
  if [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ]; then
    echo -e "  Git: ${GREEN}Up to date${NC}"
  fi
}

# Main menu
case "${1:-sync}" in
  sync)
    sync_team
    ;;
  resolve)
    resolve_conflicts
    ;;
  status)
    show_status
    ;;
  full)
    show_status
    echo ""
    sync_team
    ;;
  *)
    echo "Usage: $0 {sync|resolve|status|full}"
    echo ""
    echo "Commands:"
    echo "  sync    - Synchronize with team (default)"
    echo "  resolve - Resolve merge conflicts"
    echo "  status  - Show knowledge base status"
    echo "  full    - Show status then sync"
    exit 1
    ;;
esac
```

---

## Template Files

### 📋 `feature.md` - Feature Development Template

```markdown
# Feature: [Feature Name]

## 📋 Pre-Development Checklist
- [ ] Requirements clear and documented
- [ ] Check `.claude-team/patterns/` for similar implementations
- [ ] Review `.claude-team/ANTIPATTERNS.md` for pitfalls
- [ ] Identify affected components
- [ ] Plan testing strategy

## 🎯 Implementation Plan

### Phase 1: Foundation
- [ ] Create feature branch: `git checkout -b feature/[name]`
- [ ] Set up basic structure
- [ ] Write interface/API contracts
- [ ] Create stub implementations

### Phase 2: Core Development
- [ ] Implement business logic
- [ ] Add error handling
- [ ] Write unit tests
- [ ] Implement data persistence

### Phase 3: Integration
- [ ] Connect to existing systems
- [ ] Update API documentation
- [ ] Add integration tests
- [ ] Handle edge cases

### Phase 4: Polish
- [ ] Optimize performance
- [ ] Add logging/monitoring
- [ ] Review code quality
- [ ] Update documentation

## ✅ Acceptance Criteria
- [ ] All tests passing
- [ ] No performance degradation
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] Deployed to staging

## 📝 Lessons Learned
<!-- Document what worked and what didn't -->

## 🔄 Post-Implementation
- [ ] Update `.claude-team/SOLUTIONS.md` with successful patterns
- [ ] Document any discovered anti-patterns
- [ ] Share knowledge in team sync
```

### 🐛 `bugfix.md` - Bug Fix Template

```markdown
# Bug Fix: [Issue Title]

## 🔍 Issue Details
- **ID**: #[issue-number]
- **Reported**: [date]
- **Severity**: [Critical/High/Medium/Low]
- **Affected Users**: [scope]

## 🐛 Bug Description
<!-- Clear description of the problem -->

## 📊 Root Cause Analysis
<!-- Why did this happen? -->

## 🔧 Fix Implementation

### Approach
<!-- How will you fix it? -->

### Changes Required
- [ ] File 1: [what changes]
- [ ] File 2: [what changes]
- [ ] Tests: [what tests to add]

### Verification Steps
1. [ ] Reproduce bug in current state
2. [ ] Apply fix
3. [ ] Verify bug is resolved
4. [ ] Check for regressions
5. [ ] Test edge cases

## 🧪 Testing
- [ ] Unit tests added/updated
- [ ] Integration tests verified
- [ ] Manual testing completed
- [ ] Performance impact checked

## 📚 Documentation
- [ ] Code comments added
- [ ] ANTIPATTERNS.md updated (if applicable)
- [ ] Release notes prepared

## 🚀 Deployment
- [ ] Fix tested in staging
- [ ] Rollback plan prepared
- [ ] Monitoring alerts configured
```

---

## Git Configuration

### 📄 `.gitignore` - Ignore Local Files

```gitignore
# Lazy Genius 2.0 - Local files
.claude/
*.tmp
*.backup
.DS_Store

# IDE files
.vscode/
.idea/
*.swp
*.swo

# Logs (except team logs)
*.log
!.claude-team/**/*.log

# Personal notes
personal-notes/
TODO.personal.md
```

### 📄 `.gitattributes` - Merge Strategies

```gitattributes
# Lazy Genius 2.0 - Smart merge strategies

# Append-only files should merge both versions
.claude-team/daily/*.md merge=union
.claude-team/ANTIPATTERNS.md merge=union
.claude-team/SOLUTIONS.md merge=union

# Latest version wins for these
.claude-team/SESSION.md merge=ours
.claude-team/memory/patterns.md merge=ours

# Text file settings
*.md text eol=lf
*.txt text eol=lf
*.sh text eol=lf

# Binary files
*.png binary
*.jpg binary
*.pdf binary
```

---

## Quick Setup Script

### 🚀 `setup.sh` - One-Command Installation

```bash
#!/bin/bash
# Lazy Genius 2.0 - Quick Setup Script
# Run this to set up everything in under 60 seconds

set -euo pipefail

echo "🚀 Lazy Genius 2.0 - Quick Setup"
echo "================================="
echo ""

# Check prerequisites
check_prerequisites() {
  echo "📋 Checking prerequisites..."
  
  if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install git first."
    exit 1
  fi
  
  if ! command -v jq &> /dev/null; then
    echo "⚠️ jq is not installed. Some features may not work."
    echo "   Install with: brew install jq (Mac) or apt-get install jq (Linux)"
  fi
  
  if [ -z "$(git config user.name)" ]; then
    echo "⚠️ Git user name not set."
    read -p "Enter your name: " name
    git config --global user.name "$name"
  fi
  
  echo "✅ Prerequisites checked"
}

# Create directory structure
create_structure() {
  echo "📁 Creating directory structure..."
  
  # Local directories
  mkdir -p .claude
  
  # Team directories
  mkdir -p .claude-team/{daily,memory,patterns,templates,scripts,archive}
  mkdir -p .claude-team/memory/context
  
  echo "✅ Directories created"
}

# Install configuration files
install_configs() {
  echo "📄 Installing configuration files..."
  
  # Create hooks.json
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
        "command": "DEV=$(git config user.name | tr ' ' '-' || echo 'unknown'); echo $(date +%H:%M)' Edit: '$(echo $CLAUDE_TOOL_INPUT | jq -r .file_path 2>/dev/null || echo 'unknown') >> .claude-team/daily/$(date +%Y-%m-%d)-$DEV.md"
      }]
    }],
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "echo '\\nSession End: '$(date +%H:%M)'\\n---\\n' >> .claude-team/daily/$(date +%Y-%m-%d)-$(git config user.name | tr ' ' '-').md"
      }]
    }]
  }
}
HOOKS
  
  # Create CLAUDE.md if it doesn't exist
  if [ ! -f "CLAUDE.md" ]; then
    cat > CLAUDE.md << 'CLAUDE'
# Claude Instructions - Lazy Genius 2.0

## Before Starting
1. Read `.claude-team/SESSION.md`
2. Check `.claude-team/daily/*.md` for recent work
3. Review `.claude-team/ANTIPATTERNS.md`

## During Work
- Auto-tracking via hooks
- Update patterns as discovered

## After Major Changes
- Update `.claude-team/memory/decisions.md`
- Document solutions in `.claude-team/SOLUTIONS.md`
CLAUDE
  fi
  
  echo "✅ Configuration files installed"
}

# Initialize knowledge files
init_knowledge() {
  echo "📚 Initializing knowledge base..."
  
  # Create essential files if they don't exist
  [ ! -f .claude-team/MEMORY.md ] && echo "# Project Memory" > .claude-team/MEMORY.md
  [ ! -f .claude-team/SESSION.md ] && echo "# Current Session Focus" > .claude-team/SESSION.md
  [ ! -f .claude-team/ANTIPATTERNS.md ] && echo "# Anti-Patterns" > .claude-team/ANTIPATTERNS.md
  [ ! -f .claude-team/SOLUTIONS.md ] && echo "# Proven Solutions" > .claude-team/SOLUTIONS.md
  
  echo "✅ Knowledge base initialized"
}

# Install scripts
install_scripts() {
  echo "🔧 Installing helper scripts..."
  
  # Create a simple analyze script
  cat > .claude-team/scripts/analyze.sh << 'SCRIPT'
#!/bin/bash
echo "📊 Pattern Analysis - $(date)"
echo "Hot files:"
grep -h "Edit:" .claude-team/daily/*.md 2>/dev/null | sort | uniq -c | sort -rn | head -5
SCRIPT
  
  chmod +x .claude-team/scripts/*.sh 2>/dev/null || true
  
  echo "✅ Scripts installed"
}

# Configure git
configure_git() {
  echo "🔐 Configuring Git..."
  
  # Add .claude to gitignore
  if ! grep -q "^.claude/$" .gitignore 2>/dev/null; then
    echo ".claude/" >> .gitignore
  fi
  
  # Create .gitattributes
  if [ ! -f .gitattributes ]; then
    cat > .gitattributes << 'ATTRS'
# Lazy Genius merge strategies
.claude-team/daily/*.md merge=union
.claude-team/ANTIPATTERNS.md merge=union
ATTRS
  fi
  
  echo "✅ Git configured"
}

# Final setup
finalize() {
  echo "🎯 Finalizing setup..."
  
  # Initial git commit
  git add .claude-team .gitignore .gitattributes CLAUDE.md 2>/dev/null || true
  git diff --cached --quiet || git commit -m "Initialize Lazy Genius 2.0" -q
  
  echo "✅ Setup complete!"
}

# Main execution
main() {
  check_prerequisites
  create_structure
  install_configs
  init_knowledge
  install_scripts
  configure_git
  finalize
  
  echo ""
  echo "🎉 Lazy Genius 2.0 is ready!"
  echo ""
  echo "Quick start:"
  echo "  1. Start Claude Code"
  echo "  2. Your work will be automatically tracked"
  echo "  3. Run: git push (to share knowledge with team)"
  echo ""
  echo "Useful commands:"
  echo "  ./claude-team/scripts/analyze.sh - Analyze patterns"
  echo "  ./claude-team/scripts/sync.sh - Sync with team"
  echo ""
  echo "Happy coding! 🚀"
}

# Run main
main
```

---

## Advanced Scripts

### 📊 `report.sh` - Weekly Report Generator

```bash
#!/bin/bash
# Generate comprehensive weekly reports

TEAM_DIR=".claude-team"
WEEK=$(date +%Y-W%V)
OUTPUT="$TEAM_DIR/reports/weekly-$WEEK.md"

mkdir -p "$TEAM_DIR/reports"

cat > "$OUTPUT" << EOF
# Weekly Report - $WEEK
**Generated**: $(date +'%Y-%m-%d %H:%M:%S')

## Team Activity Summary

### Commits by Developer
EOF

# Analyze git commits
git log --since="1 week ago" --pretty=format:"%an" | sort | uniq -c | sort -rn | \
  while read count author; do
    echo "- **$author**: $count commits" >> "$OUTPUT"
  done

echo "" >> "$OUTPUT"
echo "## Hot Files This Week" >> "$OUTPUT"
grep -h "Edit:" "$TEAM_DIR"/daily/*.md 2>/dev/null | \
  sed 's/.*Edit: //' | sort | uniq -c | sort -rn | head -10 | \
  while read count file; do
    echo "- $file: $count edits" >> "$OUTPUT"
  done

echo "" >> "$OUTPUT"
echo "## Patterns Discovered" >> "$OUTPUT"
if [ -f "$TEAM_DIR/memory/patterns.md" ]; then
  grep "^-" "$TEAM_DIR/memory/patterns.md" | tail -10 >> "$OUTPUT"
fi

echo "" >> "$OUTPUT"
echo "## Anti-Patterns Added" >> "$OUTPUT"
if [ -f "$TEAM_DIR/ANTIPATTERNS.md" ]; then
  grep "^-" "$TEAM_DIR/ANTIPATTERNS.md" | tail -5 >> "$OUTPUT"
fi

echo "✅ Report generated: $OUTPUT"
```

### 🤖 `auto-commit.sh` - Automated Knowledge Commits

```bash
#!/bin/bash
# Auto-commit knowledge changes

TEAM_DIR=".claude-team"

# Check if there are changes
if git diff --quiet "$TEAM_DIR"; then
  echo "No knowledge changes to commit"
  exit 0
fi

# Generate commit message
msg="Knowledge update: $(date +%Y-%m-%d)"

# Add context to commit message
if [ -f "$TEAM_DIR/SESSION.md" ]; then
  focus=$(grep "^#" "$TEAM_DIR/SESSION.md" | head -1 | sed 's/# //')
  msg="$msg - $focus"
fi

# Commit and push
git add "$TEAM_DIR"
git commit -m "$msg"
git push origin $(git branch --show-current)

echo "✅ Knowledge committed and pushed"
```

---

## Installation Instructions

### Method 1: Quick Setup (Recommended)
```bash
# Download and run setup script
curl -O https://raw.githubusercontent.com/your-repo/lazy-genius/main/setup.sh
chmod +x setup.sh
./setup.sh
```

### Method 2: Manual Setup
```bash
# 1. Create directories
mkdir -p .claude .claude-team/{daily,memory,patterns,templates,scripts,archive}

# 2. Copy hooks.json to .claude/
# 3. Copy all scripts to .claude-team/scripts/
# 4. Make scripts executable
chmod +x .claude-team/scripts/*.sh

# 5. Initialize git
git add .claude-team
git commit -m "Initialize Lazy Genius 2.0"
```

### Method 3: Clone Template
```bash
# Clone template repository
git clone https://github.com/your-repo/lazy-genius-template .claude-setup
cp -r .claude-setup/.claude* .
rm -rf .claude-setup
```

---

## Verification

Run these commands to verify installation:

```bash
# Check structure
ls -la .claude/
ls -la .claude-team/

# Test hooks
echo "Test" > test.txt
rm test.txt

# Check daily log was created
ls .claude-team/daily/

# Run analysis
.claude-team/scripts/analyze.sh

# Check sync
.claude-team/scripts/sync.sh status
```

If all commands work, your Lazy Genius 2.0 system is ready!