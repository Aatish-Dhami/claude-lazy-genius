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
