# ❓ FAQ & Troubleshooting Guide

## Table of Contents
1. [Frequently Asked Questions](#frequently-asked-questions)
2. [Common Issues & Solutions](#common-issues--solutions)
3. [Hook Troubleshooting](#hook-troubleshooting)
4. [Git & Sync Issues](#git--sync-issues)
5. [Performance Problems](#performance-problems)
6. [Claude Behavior Issues](#claude-behavior-issues)
7. [Team Collaboration Issues](#team-collaboration-issues)
8. [Advanced Debugging](#advanced-debugging)
9. [Recovery Procedures](#recovery-procedures)
10. [Getting Help](#getting-help)

---

## Frequently Asked Questions

### General Questions

#### Q: What is Lazy Genius 2.0?
**A:** It's a zero-dependency, Git-native knowledge management system that automatically tracks your coding sessions with Claude, shares knowledge with your team, and helps Claude learn from past experiences.

#### Q: How is this different from Claude-Flow?
**A:** Lazy Genius is 10x simpler - no database, no Node.js, no servers. Just Git and markdown files. Setup in 2 minutes vs 30+.

#### Q: Does it work with regular Claude or only Claude Code?
**A:** Designed specifically for Claude Code's hook system. Won't work with regular Claude chat.

#### Q: What are the system requirements?
**A:** Just Git and Claude Code. That's it. Works on Mac, Linux, and Windows (with WSL).

#### Q: How much disk space does it use?
**A:** Typically under 5MB even after months of use. Old logs auto-archive after 30 days.

#### Q: Is my code or data sent anywhere?
**A:** No! Everything stays local in your Git repository. You control what gets shared via normal Git push/pull.

### Setup Questions

#### Q: How long does setup really take?
**A:** First-time setup: 2 minutes. New team member joining: 30 seconds.

#### Q: Can I use this in an existing project?
**A:** Yes! It adds only a few files/directories and doesn't interfere with your code.

#### Q: What if I already have a CLAUDE.md file?
**A:** The system will append to it. Back it up first if you want: `cp CLAUDE.md CLAUDE.md.backup`

#### Q: Do all team members need to use it?
**A:** No, it's optional. Those who use it benefit from shared knowledge; others aren't affected.

#### Q: Can I customize the hook behaviors?
**A:** Yes! Edit `.claude/hooks.json`. The format is documented in SCRIPTS_AND_CONFIGS.md.

### Usage Questions

#### Q: Do I need to manually trigger anything?
**A:** No! Once set up, everything is automatic. Just `git pull` in the morning and `git push` in the evening.

#### Q: How do I know it's working?
**A:** Check `.claude-team/daily/` for today's log file. Should see entries after editing files.

#### Q: Will it slow down my Claude sessions?
**A:** No. Hooks add <1ms overhead. You won't notice any performance impact.

#### Q: Can I disable it temporarily?
**A:** Yes. Rename `.claude/hooks.json` to `.claude/hooks.json.disabled`.

#### Q: What happens if I forget to sync?
**A:** No problem! Your local logs accumulate. Sync when convenient. Knowledge is never lost.

---

## Common Issues & Solutions

### 🚫 Issue: No daily logs are being created

**Symptoms:**
- `.claude-team/daily/` is empty
- No tracking despite editing files

**Solutions:**

1. **Check Git username:**
```bash
git config user.name
# If empty, set it:
git config --global user.name "Your Name"
```

2. **Verify hooks.json exists:**
```bash
ls -la .claude/hooks.json
# If missing, copy from team:
cp .claude-team/templates/hooks.json .claude/hooks.json
```

3. **Check JSON validity:**
```bash
jq '.' .claude/hooks.json
# If error, fix JSON syntax or restore from template
```

4. **Ensure Claude Code sees hooks:**
```bash
# Restart Claude Code
# Make a test edit
echo "test" > test.txt && rm test.txt
# Check for log
ls -la .claude-team/daily/
```

### 🚫 Issue: Hooks not triggering

**Symptoms:**
- Claude works but no logs created
- hooks.json exists but seems ignored

**Solutions:**

1. **Check Claude Code version:**
```bash
claude --version
# Update if needed
```

2. **Verify hook format:**
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|MultiEdit|Write",
      "hooks": [{
        "type": "command",
        "command": "echo test >> test.log"
      }]
    }]
  }
}
```

3. **Test with simple hook:**
```bash
# Create minimal test hook
cat > .claude/hooks.json << 'EOF'
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "echo 'Session started' > /tmp/claude-test.log"
      }]
    }]
  }
}
EOF

# Restart Claude Code and check /tmp/claude-test.log
```

### 🚫 Issue: "command not found" errors

**Symptoms:**
- Errors like `jq: command not found`
- Scripts fail with missing commands

**Solutions:**

1. **Install missing tools:**
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# Windows (WSL)
sudo apt-get install jq
```

2. **Use fallback commands:**
```bash
# If jq not available, modify hooks to use simpler commands
# Instead of: jq -r '.file_path'
# Use: grep -o '"file_path":"[^"]*"' | cut -d'"' -f4
```

---

## Hook Troubleshooting

### Debugging Hooks

#### Enable verbose logging:
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit",
      "hooks": [{
        "type": "command",
        "command": "echo 'HOOK TRIGGERED: '$CLAUDE_TOOL_NAME' at '$(date) >> /tmp/hook-debug.log 2>&1"
      }]
    }]
  }
}
```

#### Check hook environment variables:
```bash
# Add this to any hook command to see available variables
env | grep CLAUDE >> /tmp/claude-env.log
```

### Common Hook Problems

#### Problem: Hooks work on Mac but not Linux
**Solution:** Date command syntax differs:
```bash
# Mac
date -v-1d +%Y-%m-%d

# Linux
date -d "yesterday" +%Y-%m-%d

# Universal solution
date +%Y-%m-%d  # Just use today
```

#### Problem: Special characters in filenames break hooks
**Solution:** Quote properly:
```bash
# Bad
echo $CLAUDE_TOOL_INPUT | jq -r .file_path

# Good
echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path'
```

#### Problem: Hooks timeout or hang
**Solution:** Add timeout and background execution:
```bash
# Add timeout
timeout 1s your-command || true

# Run in background
(your-command &) 2>/dev/null
```

---

## Git & Sync Issues

### 🔄 Issue: Merge conflicts in team files

**Symptoms:**
- Git pull fails with conflicts
- Can't push changes

**Solutions:**

1. **Auto-resolve most conflicts:**
```bash
# Run sync resolver
./claude-team/scripts/sync.sh resolve

# Or manually for append-only files
git checkout --theirs .claude-team/daily/
git checkout --theirs .claude-team/ANTIPATTERNS.md
git add .claude-team/
git commit -m "Resolved conflicts"
```

2. **Prevent future conflicts:**
```bash
# Add to .gitattributes
echo ".claude-team/daily/*.md merge=union" >> .gitattributes
echo ".claude-team/ANTIPATTERNS.md merge=union" >> .gitattributes
```

### 🔄 Issue: "Permission denied" when pushing

**Solutions:**

1. **Check repository permissions:**
```bash
git remote -v
# Ensure you have push access to the repository
```

2. **Use correct authentication:**
```bash
# SSH
git remote set-url origin git@github.com:user/repo.git

# HTTPS with token
git remote set-url origin https://token@github.com/user/repo.git
```

### 🔄 Issue: Large repository size

**Symptoms:**
- Git operations slow
- Repository over 100MB

**Solutions:**

1. **Run cleanup:**
```bash
./claude-team/scripts/cleanup.sh
```

2. **Archive old logs:**
```bash
# Archive logs older than 30 days
find .claude-team/daily -name "*.md" -mtime +30 -exec mv {} .claude-team/archive/ \;
```

3. **Git cleanup:**
```bash
git gc --prune=now --aggressive
```

---

## Performance Problems

### 🐌 Issue: Claude Code becomes slow

**Symptoms:**
- Delays when editing files
- Claude responses lag

**Solutions:**

1. **Simplify hooks:**
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit",
      "hooks": [{
        "type": "command",
        "command": "echo $(date +%H:%M) >> .log"
      }]
    }]
  }
}
```

2. **Reduce file sizes:**
```bash
# Truncate large logs
tail -1000 .claude-team/memory/patterns.md > temp.md
mv temp.md .claude-team/memory/patterns.md
```

3. **Disable complex hooks temporarily:**
```bash
mv .claude/hooks.json .claude/hooks.json.complex
cp .claude-team/templates/minimal-hooks.json .claude/hooks.json
```

### 🐌 Issue: Git operations are slow

**Solutions:**

1. **Use shallow clone:**
```bash
git clone --depth 1 repository-url
```

2. **Exclude large files:**
```bash
echo "*.log" >> .gitignore
echo ".claude-team/archive/*" >> .gitignore
```

3. **Optimize repository:**
```bash
git repack -a -d --depth=250 --window=250
```

---

## Claude Behavior Issues

### 🤖 Issue: Claude not reading team knowledge

**Symptoms:**
- Claude makes same mistakes
- Doesn't reference patterns

**Solutions:**

1. **Check CLAUDE.md instructions:**
```markdown
# Add to CLAUDE.md
## MANDATORY: Read these files first
1. .claude-team/SESSION.md
2. .claude-team/ANTIPATTERNS.md
3. .claude-team/memory/patterns.md
```

2. **Make instructions more explicit:**
```markdown
## BEFORE ANY TASK
You MUST read `.claude-team/SESSION.md` to understand current focus.
NEVER proceed without checking `.claude-team/ANTIPATTERNS.md`.
```

3. **Test Claude's awareness:**
```
You: What's in .claude-team/SESSION.md?
Claude: [Should describe current session focus]
```

### 🤖 Issue: Claude creates duplicate solutions

**Solutions:**

1. **Add search instruction to CLAUDE.md:**
```markdown
## Before implementing anything
ALWAYS search for existing solutions:
grep -r "keyword" .claude-team/
```

2. **Make patterns more discoverable:**
```bash
# Create index file
find .claude-team -name "*.md" -exec grep -l "pattern" {} \; > .claude-team/INDEX.md
```

---

## Team Collaboration Issues

### 👥 Issue: Team members' work not visible

**Solutions:**

1. **Ensure everyone syncs:**
```bash
# Add to team README
## Daily Routine
Morning: git pull
Evening: ./claude-team/scripts/sync.sh
```

2. **Check naming consistency:**
```bash
# Logs should be: YYYY-MM-DD-developername.md
ls -la .claude-team/daily/
# Fix naming if needed
```

3. **Automate sync reminders:**
```bash
# Add to shell profile
alias claude-start='git pull && echo "Knowledge synced!"'
alias claude-end='./claude-team/scripts/sync.sh && echo "Knowledge shared!"'
```

### 👥 Issue: Knowledge fragmentation

**Symptoms:**
- Different team members solving same problems
- Patterns not being shared

**Solutions:**

1. **Weekly consolidation:**
```bash
# Run weekly
./claude-team/scripts/analyze.sh
./claude-team/scripts/report.sh

# Update shared patterns
cat .claude-team/daily/*.md | grep "Solution:" >> .claude-team/SOLUTIONS.md
```

2. **Create pattern templates:**
```bash
# When finding a solution
echo "## Pattern: $(date)" >> .claude-team/memory/patterns.md
echo "Problem: [describe]" >> .claude-team/memory/patterns.md
echo "Solution: [describe]" >> .claude-team/memory/patterns.md
echo "Code: [file references]" >> .claude-team/memory/patterns.md
```

---

## Advanced Debugging

### Enable Debug Mode

Create `.claude/debug-hooks.json`:
```json
{
  "hooks": {
    "PreToolUse": [{
      "hooks": [{
        "type": "command",
        "command": "echo 'PRE: Tool='$CLAUDE_TOOL_NAME' Time='$(date +'%H:%M:%S.%N') >> /tmp/claude-debug.log"
      }]
    }],
    "PostToolUse": [{
      "hooks": [{
        "type": "command",
        "command": "echo 'POST: Tool='$CLAUDE_TOOL_NAME' Time='$(date +'%H:%M:%S.%N') >> /tmp/claude-debug.log"
      }]
    }],
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "echo 'SESSION START: '$(date) >> /tmp/claude-debug.log"
      }]
    }],
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "echo 'SESSION STOP: '$(date) >> /tmp/claude-debug.log"
      }]
    }]
  }
}
```

### Analyze Hook Performance

```bash
#!/bin/bash
# Check hook execution time

# Add timing to hooks
cat > .claude/timing-hooks.json << 'EOF'
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit",
      "hooks": [{
        "type": "command",
        "command": "START=$(date +%s%N); your-command-here; END=$(date +%s%N); echo $((($END-$START)/1000000))ms >> /tmp/hook-timing.log"
      }]
    }]
  }
}
EOF

# Analyze timings
awk '{sum+=$1; count++} END {print "Average: "sum/count"ms"}' /tmp/hook-timing.log
```

### System Health Check

```bash
#!/bin/bash
# comprehensive-health-check.sh

echo "🏥 Comprehensive System Health Check"
echo "====================================="

# Check file structure
echo "📁 Directory Structure:"
for dir in .claude .claude-team/daily .claude-team/memory .claude-team/patterns; do
  if [ -d "$dir" ]; then
    echo "  ✅ $dir exists"
  else
    echo "  ❌ $dir missing"
  fi
done

# Check permissions
echo ""
echo "🔒 File Permissions:"
if [ -w ".claude-team" ]; then
  echo "  ✅ Can write to .claude-team"
else
  echo "  ❌ Cannot write to .claude-team"
fi

# Check Git configuration
echo ""
echo "🔧 Git Configuration:"
echo "  User: $(git config user.name || echo '❌ Not set')"
echo "  Email: $(git config user.email || echo '❌ Not set')"
echo "  Remote: $(git remote get-url origin 2>/dev/null || echo '❌ No remote')"

# Check hooks
echo ""
echo "🪝 Hooks Configuration:"
if [ -f ".claude/hooks.json" ]; then
  if jq '.' .claude/hooks.json > /dev/null 2>&1; then
    echo "  ✅ hooks.json is valid JSON"
    echo "  Hooks configured: $(jq '.hooks | keys[]' .claude/hooks.json 2>/dev/null | wc -l)"
  else
    echo "  ❌ hooks.json has invalid JSON"
  fi
else
  echo "  ❌ hooks.json not found"
fi

# Check recent activity
echo ""
echo "📊 Recent Activity:"
TODAY=$(date +%Y-%m-%d)
if ls .claude-team/daily/"$TODAY"*.md > /dev/null 2>&1; then
  echo "  ✅ Logs exist for today"
  echo "  Files edited today: $(grep -h "Edit:" .claude-team/daily/"$TODAY"*.md 2>/dev/null | wc -l)"
else
  echo "  ⚠️ No logs for today yet"
fi

# Check knowledge base size
echo ""
echo "💾 Storage Usage:"
if [ -d ".claude-team" ]; then
  echo "  Total size: $(du -sh .claude-team | cut -f1)"
  echo "  Daily logs: $(find .claude-team/daily -name "*.md" | wc -l) files"
  echo "  Patterns: $(grep -c "^#" .claude-team/memory/patterns.md 2>/dev/null || echo 0) sections"
fi

# Check for common issues
echo ""
echo "⚠️ Potential Issues:"
issues=0

# Large files
large_files=$(find .claude-team -type f -size +1M 2>/dev/null)
if [ -n "$large_files" ]; then
  echo "  ⚠️ Large files detected:"
  echo "$large_files" | head -3
  issues=$((issues + 1))
fi

# Old logs
old_logs=$(find .claude-team/daily -name "*.md" -mtime +30 2>/dev/null | wc -l)
if [ "$old_logs" -gt 0 ]; then
  echo "  ⚠️ $old_logs logs older than 30 days (run cleanup.sh)"
  issues=$((issues + 1))
fi

# Merge conflicts
if git status --porcelain | grep -q "^UU"; then
  echo "  ❌ Unresolved merge conflicts detected"
  issues=$((issues + 1))
fi

if [ "$issues" -eq 0 ]; then
  echo "  ✅ No issues detected"
fi

echo ""
echo "====================================="
echo "Overall Status: $([ "$issues" -eq 0 ] && echo '✅ Healthy' || echo '⚠️ Needs attention')"
```

---

## Recovery Procedures

### Corrupted hooks.json

```bash
# Backup and restore
mv .claude/hooks.json .claude/hooks.json.corrupted
cp .claude-team/templates/hooks.json .claude/hooks.json

# Or create minimal working version
cat > .claude/hooks.json << 'EOF'
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit",
      "hooks": [{
        "type": "command",
        "command": "echo 'Edit at '$(date) >> .claude-team/recovery.log"
      }]
    }]
  }
}
EOF
```

### Lost team knowledge

```bash
# Restore from Git history
git log --oneline .claude-team/
git checkout <commit-hash> -- .claude-team/

# Or restore from team member
rsync -av teammate:/path/to/project/.claude-team/ .claude-team/
```

### Complete reset

```bash
#!/bin/bash
# full-reset.sh - Complete system reset

echo "⚠️ This will reset Lazy Genius 2.0 completely"
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Backup current state
  tar czf claude-backup-$(date +%Y%m%d-%H%M%S).tar.gz .claude .claude-team
  
  # Remove current installation
  rm -rf .claude .claude-team
  
  # Reinstall
  ./setup.sh
  
  echo "✅ Reset complete. Backup saved as claude-backup-*.tar.gz"
fi
```

---

## Getting Help

### Self-Help Resources

1. **Check documentation:**
```bash
ls claude-flow-simplified/
# README.md
# IMPLEMENTATION_GUIDE.md
# SCRIPTS_AND_CONFIGS.md
# TEAM_SETUP.md
# FAQ_AND_TROUBLESHOOTING.md (this file)
# COMPARISON.md
```

2. **Search for similar issues:**
```bash
grep -r "your-error" .claude-team/
```

3. **Run diagnostics:**
```bash
./claude-team/scripts/health-check.sh
```

### Community Support

1. **GitHub Issues:**
   - Search existing issues
   - Create detailed bug report
   - Include output of health-check.sh

2. **Team Channel:**
   - #lazy-genius-help on Slack/Discord
   - Share your hooks.json (sanitized)
   - Describe expected vs actual behavior

### Bug Report Template

```markdown
## Issue Description
[Clear description of the problem]

## Environment
- OS: [Mac/Linux/Windows]
- Claude Code version: [version]
- Git version: [version]
- Team size: [number]

## Steps to Reproduce
1. [First step]
2. [Second step]
3. [Error occurs]

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Diagnostics
```
# Output of health-check.sh
[paste here]
```

## Attempted Solutions
- [What you tried]
- [What didn't work]
```

### Feature Request Template

```markdown
## Feature Description
[What you'd like to add]

## Use Case
[Why this would be helpful]

## Proposed Implementation
[How it might work]

## Alternatives Considered
[Other approaches]
```

---

## Quick Fix Cheatsheet

| Problem | Quick Fix |
|---------|-----------|
| No logs | `git config --global user.name "Your Name"` |
| Hooks not working | `jq '.' .claude/hooks.json` (check JSON) |
| Can't sync | `git pull --rebase origin main` |
| Conflicts | `./claude-team/scripts/sync.sh resolve` |
| Slow performance | `./claude-team/scripts/cleanup.sh` |
| Claude not learning | Update CLAUDE.md with explicit instructions |
| Missing commands | `brew install jq` or `apt-get install jq` |
| Permission denied | Check file ownership: `ls -la .claude-team/` |
| Large repository | Archive old logs: `cleanup.sh` |
| Lost changes | Check Git history: `git log .claude-team/` |

---

## Final Tips

1. **When in doubt, restart Claude Code** - Many issues resolve with a fresh session
2. **Keep it simple** - Don't over-complicate hooks
3. **Regular maintenance** - Run cleanup.sh weekly
4. **Document issues** - Add to ANTIPATTERNS.md
5. **Share solutions** - Update SOLUTIONS.md when you solve problems
6. **Ask for help** - The community is here to support you

Remember: The system is designed to be simple and robust. Most issues have simple solutions!