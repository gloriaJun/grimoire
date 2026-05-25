#!/bin/bash
name=$(python3 -c "
import json, sys, re
d = json.load(sys.stdin)
cwd = d.get('cwd', '')
m = re.search(r'\.claude/worktrees/([^/]+)', cwd)
print(m.group(1) if m else '')
" 2>/dev/null)
[ -n "$name" ] && echo "🪴 $name"
exit 0
