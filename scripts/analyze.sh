#!/bin/bash
# Claude Lazy Genius - Pattern Analysis
# Find hot spots, rabbit holes, and team patterns

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
TEAM_DIR=".claude-team"
TODAY=$(date +%Y-%m-%d)

echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}     📊 Claude Lazy Genius Analysis        ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo ""

# Check if knowledge directory exists
if [ ! -d "$TEAM_DIR/daily" ]; then
    echo -e "${YELLOW}No knowledge data found. Start using Claude to generate data!${NC}"
    exit 0
fi

# Hot files analysis
echo -e "${RED}🔥 Hot Files (Most Edited)${NC}"
echo "Files edited frequently might need refactoring:"
echo ""

if ls "$TEAM_DIR"/daily/*.md 1> /dev/null 2>&1; then
    grep -h "Edit:" "$TEAM_DIR"/daily/*.md 2>/dev/null | \
        sed 's/.*Edit: //' | sort | uniq -c | sort -rn | head -10 | \
        while read count file; do
            if [ "$count" -gt 10 ]; then
                echo -e "  ${RED}⚠️  $file: $count edits (needs attention!)${NC}"
            elif [ "$count" -gt 5 ]; then
                echo -e "  ${YELLOW}📝 $file: $count edits${NC}"
            else
                echo -e "  ${GREEN}✓ $file: $count edits${NC}"
            fi
        done
else
    echo "  No activity data yet"
fi

echo ""

# Today's activity
echo -e "${BLUE}📅 Today's Activity (${TODAY})${NC}"
echo ""

active_devs=0
total_changes=0

for daily in "$TEAM_DIR"/daily/"$TODAY"*.md; do
    if [ -f "$daily" ]; then
        dev=$(basename "$daily" .md | sed "s/$TODAY-//")
        changes=$(grep -c ":" "$daily" 2>/dev/null || echo 0)
        sessions=$(grep -c "Session end" "$daily" 2>/dev/null || echo 1)
        
        echo -e "  ${GREEN}👤 $dev${NC}: $changes changes in $sessions session(s)"
        
        total_changes=$((total_changes + changes))
        active_devs=$((active_devs + 1))
    fi
done

if [ "$active_devs" -eq 0 ]; then
    echo "  No activity today yet"
else
    echo ""
    echo -e "  ${BLUE}Total: $total_changes changes by $active_devs developer(s)${NC}"
fi

echo ""

# Patterns detected
echo -e "${GREEN}🔍 Patterns Detected${NC}"
echo ""

# Files often edited together
temp_file="/tmp/claude-pattern-$$"
if ls "$TEAM_DIR"/daily/*.md 1> /dev/null 2>&1; then
    for file in "$TEAM_DIR"/daily/*.md; do
        if [ -f "$file" ]; then
            # Get unique files per session
            grep "Edit:" "$file" 2>/dev/null | sed 's/.*Edit: //' | sort -u >> "$temp_file.session"
            # If session has multiple files, they're related
            if [ $(wc -l < "$temp_file.session") -gt 1 ]; then
                cat "$temp_file.session" >> "$temp_file"
            fi
            rm -f "$temp_file.session"
        fi
    done
    
    if [ -f "$temp_file" ] && [ -s "$temp_file" ]; then
        echo "Files often edited together:"
        sort "$temp_file" | uniq -c | sort -rn | head -5 | \
            while read count file; do
                if [ "$count" -gt 2 ]; then
                    echo -e "  ${GREEN}↔${NC} $file (${count}x)"
                fi
            done
    fi
    rm -f "$temp_file"
fi

echo ""

# Success indicators
echo -e "${GREEN}✅ Success Metrics${NC}"
echo ""

if ls "$TEAM_DIR"/daily/*.md 1> /dev/null 2>&1; then
    solutions=$(grep -i "fixed\|solved\|works\|success" "$TEAM_DIR"/daily/*.md 2>/dev/null | wc -l)
    problems=$(grep -i "error\|bug\|fail\|issue" "$TEAM_DIR"/daily/*.md 2>/dev/null | wc -l)
    
    echo -e "  Solutions found: ${GREEN}$solutions${NC}"
    echo -e "  Problems encountered: ${YELLOW}$problems${NC}"
    
    if [ "$solutions" -gt "$problems" ]; then
        echo -e "  Status: ${GREEN}🎉 Productive!${NC}"
    elif [ "$problems" -gt "$((solutions * 2))" ]; then
        echo -e "  Status: ${RED}🚧 Challenging - check ANTIPATTERNS.md${NC}"
    else
        echo -e "  Status: ${BLUE}🔄 Normal development${NC}"
    fi
fi

echo ""

# Recommendations
echo -e "${YELLOW}💡 Recommendations${NC}"
echo ""

# Check for hot files
if grep -h "Edit:" "$TEAM_DIR"/daily/*.md 2>/dev/null | \
   sed 's/.*Edit: //' | sort | uniq -c | sort -rn | head -1 | \
   awk '$1 > 10 {exit 0} {exit 1}'; then
    echo "  1. Review frequently edited files for refactoring opportunities"
fi

# Check for old unsynced data
old_files=$(find "$TEAM_DIR/daily" -name "*.md" -mtime +7 2>/dev/null | wc -l)
if [ "$old_files" -gt 0 ]; then
    echo "  2. Archive old logs: Run cleanup.sh"
fi

# Check for team sync
if [ -d ".git" ]; then
    unpushed=$(git cherry -v 2>/dev/null | wc -l)
    if [ "$unpushed" -gt 0 ]; then
        echo "  3. Share knowledge: You have $unpushed unpushed commits"
    fi
fi

echo "  4. Document patterns in .claude-team/SOLUTIONS.md"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "Run ${GREEN}./scripts/sync.sh${NC} to share insights with team"