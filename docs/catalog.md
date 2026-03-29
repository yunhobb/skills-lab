# 스킬·에이전트 카탈로그

## 스킬

| 스킬 | 경로 | 역할 |
|------|------|------|
| skill-reviewer | `.claude/skills/skill-reviewer/` | SKILL.md를 Anthropic 스타일 가이드 기준으로 리뷰 |
| agent-reviewer | `.claude/skills/agent-reviewer/` | 에이전트 정의 파일을 컨벤션 기준으로 리뷰 |
| review-learnings | `.claude/skills/review-learnings/` | PR 리뷰 댓글에서 규칙 추출 + 적절성 판단 |
| deep-thinking | `.claude/skills/deep-thinking/` | 구현 전 깊은 사고 워크플로우 가이드 (약점 발굴 → 결정 문서화) |
| notion-import | `.claude/skills/notion-import/` | Notion PDF 기획서 → req-analyzer 연동 |
| work-sync | `.claude/skills/work-sync/` | 대화 중 의사결정·범위 변경을 Issue/MD에 반영 |

## 에이전트

| 에이전트 | 경로 | 역할 |
|---------|------|------|
| req-analyzer | `.claude/agents/req-analyzer.md` | 모호한 요구사항 분석 오케스트레이터 |
| req-explorer | `.claude/agents/req-explorer.md` | 코드베이스/웹 맥락 수집 |
| req-validator | `.claude/agents/req-validator.md` | 구현 가능성 + 방향 적절성 검증 |
| design-challenger | `.claude/agents/design-challenger.md` | 설계/코드의 숨겨진 약점과 엣지케이스 발굴 |
| decision-documenter | `.claude/agents/decision-documenter.md` | 기술 결정과 트레이드오프를 ADR 형식으로 기록 |
| spec-distiller | `.claude/agents/spec-distiller.md` | PM 기획서에서 핵심 요구사항(Intent) 추출 및 성공 정의 도출 |
| issue-filter | `.claude/agents/issue-filter.md` | Issue의 가치/범위 판단 + 다음 단계 라우팅 추천 |
