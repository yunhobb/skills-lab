# 스킬·에이전트 작성 컨벤션

## 품질 기준

좋은 스킬/에이전트의 조건:

1. **트리거가 정확하다** — description이 유저 의도를 잘 매칭해서, 필요할 때 발동하고 불필요할 때는 발동하지 않는다
2. **최소 권한이다** — 필요한 도구만 부여하고, 필요한 범위만 다룬다. 과도한 권한은 부작용을 일으킨다
3. **출력이 일관된다** — 같은 유형의 입력에 대해 예측 가능한 형식과 품질의 결과를 낸다
4. **이유가 있다** — 규칙마다 왜 그런지 설명이 있어서, 에이전트가 엣지 케이스를 판단할 수 있다

나쁜 스킬/에이전트:
- description이 모호해서 트리거가 안 되거나 엉뚱한 데서 발동
- 도구를 전부 열어놓아서 의도하지 않은 파일 수정 발생
- MUST/ALWAYS 남발로 에이전트가 이유를 이해 못하고 기계적으로 따름

## 스킬 작성

- `description`은 trigger-condition 스타일로 작성 — Claude가 유저 의도를 매칭할 때 사용
- 본문은 500줄 이하 유지, 상세 내용은 `references/`로 분리
- 명령형 스타일, 이유 기반 규칙, 필러 제거

## 에이전트 작성

- frontmatter 필수 필드: `name`, `description`, `model`, `color`
- `description`에 `<example>` 블록 2-4개 포함
- `tools`는 최소 권한 원칙
- 상세 컨벤션은 `.claude/skills/agent-reviewer/references/agent-conventions.md` 참조

## 리뷰 학습 규칙

코딩 시 레포의 "리뷰 학습 규칙" 문서를 참조하여 같은 실수를 반복하지 않는다.

## 훅

| 훅 | 트리거 | 동작 |
|----|--------|------|
| `agent-review-reminder.sh` | `.claude/agents/*.md` 생성/수정 | agent-reviewer 리뷰 권장 |
| `skill-review-reminder.sh` | `.claude/skills/*/SKILL.md` 생성/수정 | skill-reviewer 리뷰 권장 |
