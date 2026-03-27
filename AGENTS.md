# Skills Lab

Claude Code 스킬과 에이전트를 개발하고 테스트하는 레포지토리.

## 프로젝트 구조

```
skills-lab/
├── .claude/
│   ├── agents/           # 프로젝트 에이전트 정의
│   ├── hooks/            # PostToolUse 훅 스크립트
│   └── settings.json     # 팀 공유 설정
├── .github/
│   ├── workflows/        # GitHub Actions
│   ├── scripts/          # Action 스크립트
│   └── review-rules.md   # Copilot 리뷰 규칙 (자동 동기화)
├── skill-reviewer/       # 스킬 리뷰 스킬
├── agent-reviewer/       # 에이전트 리뷰 스킬
├── review-learnings/     # PR 리뷰 학습 스킬
├── AGENTS.md             # 이 파일
└── CLAUDE.md             # AGENTS.md로 위임
```

## 스킬 목록

| 스킬 | 경로 | 역할 |
|------|------|------|
| skill-reviewer | `skill-reviewer/` | SKILL.md 파일을 Anthropic 스타일 가이드 기준으로 리뷰 |
| agent-reviewer | `agent-reviewer/` | 에이전트 정의 파일을 컨벤션 기준으로 리뷰 |
| review-learnings | `review-learnings/` | PR 리뷰 댓글에서 규칙 추출 + 적절성 판단 |

## 에이전트 목록

| 에이전트 | 경로 | 역할 |
|---------|------|------|
| req-analyzer | `.claude/agents/req-analyzer.md` | 모호한 요구사항 분석 오케스트레이터 |
| req-explorer | `.claude/agents/req-explorer.md` | 코드베이스/웹 맥락 수집 |
| req-validator | `.claude/agents/req-validator.md` | 구현 가능성 + 방향 적절성 검증 |

## 컨벤션

### 스킬 작성

- SKILL.md의 `description`은 trigger-condition 스타일로 작성 — Claude가 유저 의도를 매칭할 때 사용
- 본문은 500줄 이하 유지, 상세 내용은 `references/`로 분리
- 명령형 스타일, 이유 기반 규칙, 필러 제거

### 에이전트 작성

- frontmatter 필수 필드: `name`, `description`, `model`, `color`
- `description`에 `<example>` 블록 2-4개 포함
- `tools`는 최소 권한 원칙
- 상세 컨벤션은 `agent-reviewer/references/agent-conventions.md` 참조

### 리뷰 학습 규칙

코딩 시 `.claude/review-learnings.md`의 규칙을 참조하여 같은 실수를 반복하지 않는다.

## 훅

| 훅 | 트리거 | 동작 |
|----|--------|------|
| `agent-review-reminder.sh` | `agents/*.md` 생성/수정 | agent-reviewer 리뷰 권장 |
| `skill-review-reminder.sh` | `skills/*/SKILL.md` 생성/수정 | skill-reviewer 리뷰 권장 |
