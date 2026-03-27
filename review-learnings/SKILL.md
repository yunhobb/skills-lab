---
name: review-learnings
description: |
  This skill should be used when the user asks to "analyze PR review comments", "extract review rules", "리뷰 학습", "리뷰 댓글 분석", "review-learnings", or provides a PR number for review comment analysis. Also use when the user mentions "Copilot 리뷰 정리", "리뷰에서 규칙 추출", "같은 실수 반복 방지", or wants to turn PR review feedback into reusable rules.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, WebFetch
---

# Review Learnings

PR 리뷰 댓글(주로 Copilot)을 분석하여 재사용 가능한 규칙으로 추상화하고, 적절성을 판단하는 스킬. GitHub Action이 수집한 댓글 원문(`.claude/review-candidates.md`)을 입력으로 받는다.

## 입력

유저가 PR 번호를 전달하면 두 가지 경로로 댓글을 가져온다:

- `.claude/review-candidates.md`가 있으면 그 파일을 읽는다 (Action이 이미 수집한 경우)
- 없으면 `gh api`로 직접 수집한다: `gh api repos/{owner}/{repo}/pulls/{number}/comments`

## 워크플로우

### 1단계: 댓글 수집 확인

`.claude/review-candidates.md` 또는 `gh api` 결과에서 리뷰 댓글을 읽는다. 댓글이 없으면 유저에게 알리고 종료한다.

### 2단계: 규칙 추상화

각 댓글에서 반복 가능한 실수 패턴을 추출한다.

**추상화 기준:**
- 프로젝트에 특화된 지적 → 일반적으로 적용 가능한 규칙으로 변환. "이 함수에서 null 체크 빠짐" → "외부 입력은 항상 null check"
- 단순 코드 스타일 취향이나 자동 포맷팅으로 해결되는 것은 규칙으로 만들지 않는다
- 하나의 댓글에서 여러 규칙이 나올 수 있고, 여러 댓글이 같은 규칙을 가리킬 수 있다

**규칙 형식:**
```
- 규칙 내용 — PR #번호에서 발견
```

### 3단계: 적절성 판단

추출된 각 규칙을 다음 기준으로 평가한다:

- **일반성** — 이 프로젝트 외에도 적용 가능한가? 너무 구체적이면 탈락
- **중복** — `.claude/review-learnings.md`에 이미 유사한 규칙이 있는가? 있으면 탈락
- **실행 가능성** — 규칙을 읽고 바로 코드에 적용할 수 있는가? 모호하면 수정
- **가치** — 이 규칙이 실제로 버그나 품질 문제를 방지하는가? 사소하면 탈락

각 규칙에 ACCEPT / REVISE / REJECT를 부여하고 근거를 명시한다.

### 4단계: 결과 반영

ACCEPT된 규칙을 `.claude/review-learnings.md`의 적절한 카테고리에 추가한다. REVISE 규칙은 수정 후 추가한다. `.github/review-rules.md`도 동기화한다.

동기화 형식:
```bash
# review-rules.md 상단에 자동 동기화 헤더 유지
<!-- AUTO-SYNCED from .claude/review-learnings.md — do not edit directly -->
```

### 5단계: 결과 보고

유저에게 다음을 보고한다:
- 수집된 댓글 수
- 추출된 규칙 수
- ACCEPT / REVISE / REJECT 각 수와 근거 요약
- 반영된 규칙 목록

## 카테고리

`.claude/review-learnings.md`의 카테고리에 맞춰 분류한다:

| 카테고리 | 예시 |
|---------|------|
| 보안 | null check, 입력 검증, 인증/인가 |
| 코드 품질 | 에러 처리, 네이밍, 중복 제거 |
| 스타일 | 포맷팅, 주석 스타일, 일관성 |
| 아키텍처 | 의존성 방향, 레이어 분리, 패턴 |

기존 카테고리에 맞지 않으면 새 카테고리를 제안한다.

## 제약사항

- 원본 댓글을 삭제하거나 수정하지 않는다 — 규칙 추가만 수행
- 규칙에 항상 출처 PR 번호를 포함한다 — 나중에 "왜 이 규칙?" 추적 가능
- REJECT 판정에는 반드시 근거를 명시한다 — 유저가 판단을 검증할 수 있어야 한다
