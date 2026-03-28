#!/bin/bash
# skills-lab 스킬/에이전트를 Claude Code에 심링크로 연결하는 스크립트
# 사용: bash setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"

# 심링크 대상 스킬 목록
SKILLS=(
  "skill-reviewer"
  "agent-reviewer"
  "review-learnings"
)

echo "=== skills-lab setup ==="
echo "프로젝트: $SCRIPT_DIR"
echo "대상: $SKILLS_DIR"
echo ""

mkdir -p "$SKILLS_DIR"

for skill in "${SKILLS[@]}"; do
  SOURCE="$SCRIPT_DIR/$skill"
  TARGET="$SKILLS_DIR/$skill"

  if [ ! -d "$SOURCE" ]; then
    echo "  SKIP  $skill — 디렉토리 없음"
    continue
  fi

  if [ -L "$TARGET" ]; then
    CURRENT=$(readlink "$TARGET")
    if [ "$CURRENT" = "$SOURCE" ]; then
      echo "  OK    $skill — 이미 연결됨"
      continue
    fi
    rm "$TARGET"
    echo "  UPDATE $skill — 기존 심링크 교체"
  elif [ -d "$TARGET" ]; then
    echo "  SKIP  $skill — 실제 디렉토리가 이미 존재 (수동 확인 필요)"
    continue
  fi

  ln -s "$SOURCE" "$TARGET"
  echo "  LINK  $skill → $TARGET"
done

echo ""
echo "완료. Claude Code를 재시작하면 스킬이 인식됩니다."
echo "확인: ls -la $SKILLS_DIR"
