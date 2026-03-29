#!/bin/bash
# PostToolUse hook: Write 도구로 SKILL.md 파일이 생성/수정되면 리뷰 리마인더 출력

FILE_PATH=$(jq -r '.tool_input.file_path' 2>/dev/null)

if echo "$FILE_PATH" | grep -q '\.claude/skills/.*SKILL\.md$'; then
  cat <<'HOOK_JSON'
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"스킬 파일이 생성/수정되었습니다. skill-reviewer로 리뷰를 권장합니다."}}
HOOK_JSON
fi
