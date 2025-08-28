#!/bin/bash
# Claude Lazy Genius - Cleanup & Maintenance
# Archive old logs and optimize storage

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
TEAM_DIR=".claude-team"
ARCHIVE_AFTER_DAYS=30
MAX_PATTERN_LINES=500

echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}     🧹 Claude Lazy Genius Cleanup         ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo ""

# Check if knowledge directory exists
if [ ! -d "$TEAM_DIR" ]; then
    echo -e "${YELLOW}No knowledge directory found. Nothing to clean.${NC}"
    exit 0
fi

# Archive old daily logs
echo -e "${BLUE}📦 Archiving old logs (>${ARCHIVE_AFTER_DAYS} days)...${NC}"

archived_count=0
if [ -d "$TEAM_DIR/daily" ]; then
    find "$TEAM_DIR/daily" -name "*.md" -mtime +$ARCHIVE_AFTER_DAYS 2>/dev/null | \
        while IFS= read -r file; do
            date_str=$(basename "$file" .md | cut -d'-' -f1-3)
            year=$(echo "$date_str" | cut -d'-' -f1)
            month=$(echo "$date_str" | cut -d'-' -f2)
            
            archive_dir="$TEAM_DIR/archive/$year/$month"
            mkdir -p "$archive_dir"
            
            mv "$file" "$archive_dir/"
            echo -e "  ${GREEN}✓${NC} Archived: $(basename $file)"
            archived_count=$((archived_count + 1))
        done
fi

if [ "$archived_count" -eq 0 ]; then
    echo -e "  ${GREEN}✓ No old logs to archive${NC}"
fi

echo ""

# Optimize pattern files
echo -e "${BLUE}📊 Optimizing pattern files...${NC}"

optimized=0
for pattern_file in "$TEAM_DIR"/memory/*.md "$TEAM_DIR"/patterns/*.md; do
    if [ -f "$pattern_file" ]; then
        lines=$(wc -l < "$pattern_file" 2>/dev/null || echo 0)
        if [ "$lines" -gt "$MAX_PATTERN_LINES" ]; then
            temp_file="/tmp/pattern-optimize-$$"
            echo "# Optimized on $(date +%Y-%m-%d)" > "$temp_file"
            echo "" >> "$temp_file"
            tail -n $((MAX_PATTERN_LINES - 50)) "$pattern_file" >> "$temp_file"
            mv "$temp_file" "$pattern_file"
            echo -e "  ${GREEN}✓${NC} Optimized: $(basename $pattern_file) ($lines → $MAX_PATTERN_LINES lines)"
            optimized=$((optimized + 1))
        fi
    fi
done

if [ "$optimized" -eq 0 ]; then
    echo -e "  ${GREEN}✓ All pattern files are optimal size${NC}"
fi

echo ""

# Clean temporary files
echo -e "${BLUE}🗑️ Cleaning temporary files...${NC}"

cleaned=0
# Remove old session files
find .claude -name "*.tmp" -mtime +1 -delete 2>/dev/null && cleaned=$((cleaned + $(find .claude -name "*.tmp" -mtime +1 2>/dev/null | wc -l)))
find .claude -name "session-*.md" -mtime +7 -delete 2>/dev/null && cleaned=$((cleaned + $(find .claude -name "session-*.md" -mtime +7 2>/dev/null | wc -l)))

# Remove empty daily logs
find "$TEAM_DIR/daily" -name "*.md" -size 0 -delete 2>/dev/null && cleaned=$((cleaned + $(find "$TEAM_DIR/daily" -name "*.md" -size 0 2>/dev/null | wc -l)))

echo -e "  ${GREEN}✓ Cleaned $cleaned temporary files${NC}"

echo ""

# Storage report
echo -e "${BLUE}💾 Storage Report${NC}"
echo ""

if [ -d "$TEAM_DIR" ]; then
    total_size=$(du -sh "$TEAM_DIR" 2>/dev/null | cut -f1)
    daily_count=$(find "$TEAM_DIR/daily" -name "*.md" 2>/dev/null | wc -l)
    archive_count=$(find "$TEAM_DIR/archive" -name "*.md" 2>/dev/null | wc -l)
    
    echo -e "  Total knowledge size: ${GREEN}$total_size${NC}"
    echo -e "  Active daily logs: ${BLUE}$daily_count files${NC}"
    echo -e "  Archived logs: ${BLUE}$archive_count files${NC}"
    
    # Warn if growing large
    size_kb=$(du -sk "$TEAM_DIR" 2>/dev/null | cut -f1)
    if [ "$size_kb" -gt 10240 ]; then
        echo -e "  ${YELLOW}⚠️  Knowledge base over 10MB - consider more aggressive archiving${NC}"
    fi
fi

echo ""

# Generate summary
echo -e "${BLUE}📝 Generating archive summary...${NC}"

if [ -d "$TEAM_DIR/archive" ]; then
    summary="$TEAM_DIR/archive/SUMMARY.md"
    
    cat > "$summary" << EOF
# Archive Summary
**Generated**: $(date +'%Y-%m-%d %H:%M')

## Archive Structure
EOF
    
    for year_dir in "$TEAM_DIR"/archive/*/; do
        if [ -d "$year_dir" ]; then
            year=$(basename "$year_dir")
            echo "### Year $year" >> "$summary"
            for month_dir in "$year_dir"*/; do
                if [ -d "$month_dir" ]; then
                    month=$(basename "$month_dir")
                    count=$(ls "$month_dir"*.md 2>/dev/null | wc -l)
                    echo "- Month $month: $count files" >> "$summary"
                fi
            done
            echo "" >> "$summary"
        fi
    done
    
    echo -e "  ${GREEN}✓ Summary generated${NC}"
fi

echo ""
echo -e "${GREEN}✅ Cleanup complete!${NC}"
echo ""

# Recommendations
if [ "$archived_count" -gt 0 ] || [ "$optimized" -gt 0 ]; then
    echo -e "${YELLOW}💡 Next steps:${NC}"
    echo "  1. Review archive at: $TEAM_DIR/archive/"
    echo "  2. Commit changes: git add $TEAM_DIR && git commit -m 'Archive old knowledge'"
    echo "  3. Share with team: ./scripts/sync.sh"
fi