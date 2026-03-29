# Skills Lab

Claude Code 스킬과 에이전트를 개발하고 테스트하는 레포지토리.

<purpose>

이 레포는 Claude Code의 확장 기능(스킬, 에이전트, 훅)을 만들고 품질을 검증하는 곳이다. 만든 스킬/에이전트는 다른 프로젝트에서 재사용된다 — 여기서 품질이 낮으면 사용하는 모든 곳에서 문제가 생긴다.

</purpose>

<interaction>

유저의 판단이 필요한 선택지가 있을 때 AskUserQuestion 도구를 사용한다 — 단순 확인("진행할까요?")이나 정보 전달에는 쓰지 않는다.

질문 구성:
- 선택지는 3개를 기본으로 한다
- 각 선택지의 description에 장점과 단점을 포함한다
- 유저는 항상 "Other"로 직접 입력할 수 있다 (자동 제공)
- 비교가 필요한 경우 preview를 활용한다

</interaction>

<quality>

좋은 스킬/에이전트의 조건:

1. **트리거가 정확하다** — description이 유저 의도를 잘 매칭해서, 필요할 때 발동하고 불필요할 때는 발동하지 않는다
2. **최소 권한이다** — 필요한 도구만 부여하고, 필요한 범위만 다룬다. 과도한 권한은 부작용을 일으킨다
3. **출력이 일관된다** — 같은 유형의 입력에 대해 예측 가능한 형식과 품질의 결과를 낸다
4. **이유가 있다** — 규칙마다 왜 그런지 설명이 있어서, 에이전트가 엣지 케이스를 판단할 수 있다

나쁜 스킬/에이전트:
- description이 모호해서 트리거가 안 되거나 엉뚱한 데서 발동
- 도구를 전부 열어놓아서 의도하지 않은 파일 수정 발생
- MUST/ALWAYS 남발로 에이전트가 이유를 이해 못하고 기계적으로 따름

</quality>

<workflow>

모든 작업은 이 흐름을 따른다. Issue를 먼저 만드는 이유는 "뭘 왜 했는지"를 나중에도 추적할 수 있게 하기 위해서다. 채팅은 사라지지만 Issue는 남는다.

<basic-flow>

1. Issue 생성 — 작업의 시작점. 뭘 할 건지 먼저 기록한다.
2. Worktree 생성 — 격리된 환경에서 작업한다.
3. 작업 수행 — 코드, 문서 등 실제 작업.
4. Commit — Conventional Commits 형식(`feat(scope): subject`)으로 커밋한다.
5. Push — 작업이 끝나면 remote에 push한다.
6. PR 생성 — PR body에 `Closes #<number>`를 넣어서 Issue와 연결한다.

Review, Merge, Worktree 정리는 사용자가 직접 한다. pre-commit hook이 실패하면 문제를 고친 뒤 새 commit을 만든다 — amend는 이력이 사라지므로 하지 않는다.

</basic-flow>

<multi-agent>

핵심 아이디어는 **생성과 평가를 분리**하는 것이다. 모델은 자기 결과물을 스스로 평가하면 관대해지는 경향이 있다. 별도의 평가자가 회의적인 시각으로 검토하면 품질이 올라간다.

이 패턴을 GitHub Issue로 구현하며, `.claude/agents/`에 정의된 에이전트 파일을 활용한다.

에이전트 간 관계는 **파이프라인**이지 대화가 아니다. 오케스트레이터가 초반에 한 번 실행되고, 이후 반복 루프는 실행자-검증자 사이에서 돌아간다.

```
오케스트레이터 ──(사양)──▶ 실행자 ◀──(피드백)──▶ 검증자
  │                         │                      │
  │ 1회 실행                │ 반복 루프             │ 반복 루프
  ▼                         ▼                      ▼
사양 작성                  구현                    검토 + 피드백
```

GitHub Issue에서 Parent Issue = 사양, Sub-Issue = 작업 단위, Comment = 진행 기록 + 피드백으로 사용한다.

</multi-agent>

<simplification>

이 워크플로우의 모든 구성 요소는 "모델이 스스로 못하는 것"에 대한 가정을 담고 있다. 모델이 발전하면 이 가정은 빠르게 낡아진다. **가능한 가장 단순한 구성으로 시작하고, 필요할 때만 복잡성을 높인다.**

에이전트가 많을수록 토큰 비용과 지연 시간이 증가한다. 구성 요소를 하나씩 빼면서 결과에 미치는 영향을 확인한다 — 한 번에 많이 바꾸면 뭐가 핵심이었는지 파악할 수 없다.

| 작업 규모 | 기준 | 권장 구성 |
|-----------|------|-----------|
| 소형 | 파일 1-2개, sub-issue 없음 | 실행자만 |
| 중형 | 파일 3-5개, sub-issue 2-3개 | 오케스트레이터 + 실행자 |
| 대형 | 파일 6개 이상, sub-issue 4개 이상 | 오케스트레이터 + 실행자 + 검증자 |

판단이 애매하면 한 단계 낮은 구성으로 시작한다. 작업 중 범위가 커지면 그때 에이전트를 추가한다.

</simplification>

</workflow>

<issue-management>

Issue는 작업 추적 시스템이다. 작업을 시작하기 전에 기존 이슈를 확인하고, 없으면 새로 만든다. 큰 작업은 sub-issue로 분할하면 여러 agent가 병렬로 처리할 수 있다.

Issue body에는 **무엇을 왜 하는지**와 **TODO 체크박스**를 담는다. 처음부터 완벽할 필요 없다 — 작업하면서 추가하거나 수정한다. 파일/디렉터리 목록을 미리 설계하지 않는다 — 범위는 TODO에서 자연스럽게 드러난다.

### 네이티브 Sub-issue

Sub-issue는 GitHub의 네이티브 sub-issue API로 생성한다 — body에 체크박스로 링크하는 방식이 아니라, 실제 parent-child 관계를 설정한다. 네이티브 sub-issue는 GitHub UI에서 진행률 바로 표시되고, sub-issue를 닫으면 parent에 자동 반영된다.

```bash
# 1. sub-issue 생성
gh issue create --repo <owner>/<repo> --title "Sub-issue 제목" --body "내용"

# 2. sub-issue의 ID 조회 (-F는 integer로 전달)
ISSUE_ID=$(gh api repos/<owner>/<repo>/issues/<number> --jq '.id')

# 3. parent에 네이티브 sub-issue로 연결 (순차 실행 — 병렬 시 priority 충돌)
gh api repos/<owner>/<repo>/issues/<parent_number>/sub_issues --method POST -F sub_issue_id=$ISSUE_ID

# 4. 확인
gh api repos/<owner>/<repo>/issues/<parent_number>/sub_issues --jq '.[].number'
```

주의: sub-issue 연결 API는 **순차 실행**해야 한다. 병렬로 실행하면 priority 필드 충돌로 일부가 실패한다.

### Issue 제목 prefix

Issue 제목에 `[작업정리]` prefix를 붙여서 목록에서 맥락을 바로 파악할 수 있게 한다. sub-issue는 `/Sub`를 추가한다.

- Parent: `[작업정리] 제목` — 예: `[백엔드 서비스] 금융 시장 데이터 백엔드 서비스 구현`
- Sub-issue: `[작업정리/Sub] 제목` — 예: `[백엔드 서비스/Sub] 종목 조회 API`

parent와 sub-issue는 **같은 작업정리 이름**을 사용한다. `작업정리`는 parent 작업의 핵심을 2-4글자로 요약한 것이다.

</issue-management>

<git-worktree>

branch checkout 대신 git worktree를 사용한다 — 여러 agent가 동시에 작업할 때 branch switching이 충돌을 일으키지만, worktree는 각각 독립된 working directory를 가지므로 이 문제가 없다.

Branch 이름은 `<type>/<short-description>` 패턴을 따른다. type은 `feat`, `docs`, `fix`, `refactor`, `chore` 중 하나다.

여러 agent가 동시에 작업할 때 핵심 원칙은 **파일 단위 분할**이다. 각 agent가 고유한 파일을 담당하고, 같은 파일을 두 agent가 동시에 수정하지 않는다.

</git-worktree>

<project-specific>

## 스킬 목록

| 스킬 | 경로 | 역할 |
|------|------|------|
| skill-reviewer | `skill-reviewer/` | SKILL.md를 Anthropic 스타일 가이드 기준으로 리뷰 |
| agent-reviewer | `agent-reviewer/` | 에이전트 정의 파일을 컨벤션 기준으로 리뷰 |
| review-learnings | `review-learnings/` | PR 리뷰 댓글에서 규칙 추출 + 적절성 판단 |
| deep-thinking | `deep-thinking/` | 구현 전 깊은 사고 워크플로우 가이드 (약점 발굴 → 결정 문서화) |

## 에이전트 목록

| 에이전트 | 경로 | 역할 |
|---------|------|------|
| req-analyzer | `.claude/agents/req-analyzer.md` | 모호한 요구사항 분석 오케스트레이터 |
| req-explorer | `.claude/agents/req-explorer.md` | 코드베이스/웹 맥락 수집 |
| req-validator | `.claude/agents/req-validator.md` | 구현 가능성 + 방향 적절성 검증 |
| design-challenger | `.claude/agents/design-challenger.md` | 설계/코드의 숨겨진 약점과 엣지케이스 발굴 |
| decision-documenter | `.claude/agents/decision-documenter.md` | 기술 결정과 트레이드오프를 ADR 형식으로 기록 |
| spec-distiller | `.claude/agents/spec-distiller.md` | PM 기획서에서 핵심 요구사항(Intent) 추출 및 성공 정의 도출 |

## 컨벤션

### 스킬 작성

- `description`은 trigger-condition 스타일로 작성 — Claude가 유저 의도를 매칭할 때 사용
- 본문은 500줄 이하 유지, 상세 내용은 `references/`로 분리
- 명령형 스타일, 이유 기반 규칙, 필러 제거

### 에이전트 작성

- frontmatter 필수 필드: `name`, `description`, `model`, `color`
- `description`에 `<example>` 블록 2-4개 포함
- `tools`는 최소 권한 원칙
- 상세 컨벤션은 `agent-reviewer/references/agent-conventions.md` 참조

### 리뷰 학습 규칙

코딩 시 레포의 "리뷰 학습 규칙" 문서를 참조하여 같은 실수를 반복하지 않는다.

## 훅

| 훅 | 트리거 | 동작 |
|----|--------|------|
| `agent-review-reminder.sh` | `agents/*.md` 생성/수정 | agent-reviewer 리뷰 권장 |
| `skill-review-reminder.sh` | `skills/*/SKILL.md` 생성/수정 | skill-reviewer 리뷰 권장 |

</project-specific>
