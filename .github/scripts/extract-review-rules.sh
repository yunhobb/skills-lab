#!/bin/bash
# PR 리뷰 댓글에서 ��칙을 추출하여 review-learnings.md에 추가하는 스크립트
# GitHub Action에서 호출됨

set -euo pipefail

COMMENTS_FILE="${1:-/tmp/review-comments.json}"
LEARNINGS_FILE=".claude/review-learnings.md"
SYNC_FILE=".github/review-rules.md"
PR_NUMBER="${PR_NUMBER:-unknown}"

# 리뷰 댓글이 없으면 스킵
if [ ! -f "$COMMENTS_FILE" ] || [ "$(jq 'length' "$COMMENTS_FILE")" -eq 0 ]; then
  echo "리뷰 댓글이 없습니다. 스킵합니다."
  exit 0
fi

COMMENT_COUNT=$(jq 'length' "$COMMENTS_FILE")
echo "수집된 Copilot 리뷰 댓글: ${COMMENT_COUNT}개"

# 댓글 내용을 텍스트로 변환
COMMENTS_TEXT=$(jq -r '.[] | "파일: \(.path)\n내용: \(.body)\n---"' "$COMMENTS_FILE")

# Claude API로 규칙 추상화
PROMPT="다음은 GitHub Copilot이 PR #${PR_NUMBER}에서 남긴 코드 리뷰 댓글입니다.

${COMMENTS_TEXT}

위 댓글에서 반복 가능한 실수 패턴을 추출하여, 일반화된 규칙으��� 변환하세요.

규칙 형식:
- 규칙 내�� — PR #${PR_NUMBER}에서 발견

카테고리(보안, 코드 품질, 스타일, 아키텍처) 중 적절한 곳에 분류하세요.
프로젝트에 특화된 내용이 아니라 일반적으로 적용 가능한 규칙만 추출하세요.
댓글이 단순 제안이나 코드 스타일 취향이면 규칙으로 만들지 마세요.

JSON 형식으로 응답:
{
  \"rules\": [
    {\"category\": \"보안\", \"rule\": \"규칙 내용 — PR #${PR_NUMBER}에서 발견\"},
    ...
  ]
}"

# Claude API 호출
RESPONSE=$(curl -s https://api.anthropic.com/v1/messages \
  -H "content-type: application/json" \
  -H "x-api-key: ${ANTHROPIC_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d "$(jq -n --arg prompt "$PROMPT" '{
    model: "claude-haiku-4-5-20251001",
    max_tokens: 1024,
    messages: [{role: "user", content: $prompt}]
  }')")

# 응답에서 규칙 추출
RULES_JSON=$(echo "$RESPONSE" | jq -r '.content[0].text' | grep -o '{.*}' | head -1)

if [ -z "$RULES_JSON" ] || [ "$RULES_JSON" = "null" ]; then
  echo "규칙을 추출하지 못했습니다."
  exit 0
fi

RULE_COUNT=$(echo "$RULES_JSON" | jq '.rules | length')
echo "추출된 규칙: ${RULE_COUNT}개"

if [ "$RULE_COUNT" -eq 0 ]; then
  echo "추출된 규칙이 없습니다. 스킵합니다."
  exit 0
fi

# 카테고리별로 규칙 삽입
for CATEGORY in "보안" "코드 품질" "스타일" "아키텍처"; do
  CATEGORY_RULES=$(echo "$RULES_JSON" | jq -r --arg cat "$CATEGORY" '.rules[] | select(.category == $cat) | .rule')

  if [ -n "$CATEGORY_RULES" ]; then
    while IFS= read -r rule; do
      # 해당 카테고리 헤더 다음 줄에 규칙 추가
      sed -i.bak "/^## ${CATEGORY}$/a\\
- ${rule}" "$LEARNINGS_FILE"
    done <<< "$CATEGORY_RULES"
  fi
done

# bak 파일 정리
rm -f "${LEARNINGS_FILE}.bak"

# review-rules.md에 동기화 (헤더만 변경)
{
  echo "<!-- AUTO-SYNCED from .claude/review-learnings.md — do not edit directly -->"
  echo "<!-- GitHub Action(learn-from-review)이 자동으로 동기화합니다 -->"
  echo ""
  cat "$LEARNINGS_FILE"
} > "$SYNC_FILE"

echo "규칙이 업데이트되었습니다."
echo "- ${LEARNINGS_FILE}: 원본 업데이트"
echo "- ${SYNC_FILE}: 동기화 완료"
