#!/bin/bash
# PR 리뷰 댓글을 수집하여 원문 그대로 PR에 포함하는 스크립트
# GitHub Action에서 호출됨. 규칙 추상화는 사람 또는 스킬이 수행.

set -euo pipefail

COMMENTS_FILE="${1:-/tmp/review-comments.json}"
OUTPUT_FILE=".claude/review-candidates.md"
PR_NUMBER="${PR_NUMBER:-unknown}"

# 리뷰 댓글이 없으면 스킵
if [ ! -f "$COMMENTS_FILE" ] || [ "$(jq 'length' "$COMMENTS_FILE")" -eq 0 ]; then
  echo "리뷰 댓글이 없습니다. 스킵합니다."
  exit 0
fi

COMMENT_COUNT=$(jq 'length' "$COMMENTS_FILE")
echo "수집된 Copilot 리뷰 댓글: ${COMMENT_COUNT}개"

# 댓글을 마크다운으로 변환
{
  echo "# PR #${PR_NUMBER} 리뷰 댓글"
  echo ""
  echo "> 자동 수집된 Copilot 리뷰 댓글입니다."
  echo "> \`/review-learnings ${PR_NUMBER}\` 스킬로 규칙 추상화 및 적절성 판단을 수행하세요."
  echo ""
  echo "## 수집된 댓글 (${COMMENT_COUNT}개)"
  echo ""

  jq -r '.[] | "### \(.path):\(.line // "N/A")\n\n\(.body)\n\n---\n"' "$COMMENTS_FILE"
} > "$OUTPUT_FILE"

echo "댓글이 수집되었습니다: ${OUTPUT_FILE}"
