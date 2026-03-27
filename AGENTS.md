# Skills Lab

Claude Code 스킬과 에이전트를 개발하고 테스트하는 레포지토리.

<workflow>

모든 작업은 이 흐름을 따른다. Issue를 먼저 만드는 이유는 "뭘 왜 했는지"를 나중에도 추적할 수 있게 하기 위해서다. 채팅은 사라지지만 Issue는 남는다.

<basic-flow>

1. Issue 생성 — 작업의 시작점. 뭘 할 건지 먼저 기록한다.
2. Worktree 생성 — 격리된 환경에서 작업한다.
3. 작업 수행 — 코드, 문서 등 실제 작업.
4. Commit — Conventional Commits 형식(`feat(scope): subject`)으로 커밋한다.
5. Push — 작업이 끝나면 remote에 push한다.
6. PR 생성 — PR body에 `Closes #<number>`를 넣어서 Issue와 연결한다.

Review, Merge, Worktree 정리는 사용자가 직접 한다.

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

Issue는 작업 추적 시스템이다. 작업을 시작하기 전에 기존 이슈를 확인하고, 없으면 새로 만든다.

```bash
gh issue list --state open
gh issue create --title "작업 제목" --body "작업 내용" --label "feat"
```

큰 작업은 sub-issue로 분할하면 여러 agent가 병렬로 처리할 수 있다.

```bash
gh issue create --title "하위 작업" --body "Parent: #<parent-number>"
```

Issue body에는 **무엇을 왜 하는지**와 **TODO 체크박스**를 담는다. 처음부터 완벽할 필요 없다 — 작업하면서 추가하거나 수정한다. 파일/디렉터리 목록을 미리 설계하지 않는다 — 범위는 TODO에서 자연스럽게 드러난다.

</issue-management>

<commits-and-prs>

Commit 메시지는 Conventional Commits 형식(`feat(scope): subject`)을 따른다. pre-commit hook이 실패하면 문제를 고친 뒤 새 commit을 만든다 — amend는 이력이 사라지므로 하지 않는다.

PR body에 `Closes #<number>`를 넣어서 Issue와 연결한다. PR description에 담기엔 긴 내용은 `docs/` 디렉터리에 파일로 작성하고, issue에서 링크한다.

</commits-and-prs>

<git-worktree>

branch checkout 대신 git worktree를 사용한다. 여러 agent가 동시에 작업할 때 branch switching이 충돌을 일으키지만, worktree는 각각 독립된 working directory를 가지므로 이 문제가 없다.

```bash
git worktree add ../<repo>-<topic> -b <branch-name>
git worktree list
git worktree remove ../<repo>-<topic>
```

Branch 이름은 `<type>/<short-description>` 패턴을 따른다. type은 `feat`, `docs`, `fix`, `refactor`, `chore` 중 하나다.

여러 agent가 동시에 작업할 때 핵심 원칙은 **파일 단위 분할**이다. 각 agent가 고유한 파일을 담당하고, 같은 파일을 두 agent가 동시에 수정하지 않는다.

</git-worktree>

<doc-structure>

각 workspace(서브디렉터리)는 이 구조를 따른다:

```text
workspace/
  README.md    # 프로젝트 개요 + docs/ 인덱스 테이블
  AGENTS.md    # 프로젝트별 agent 컨텍스트
  CLAUDE.md    # AGENTS.md delegation
  docs/        # 상세 문서 (주제별 1파일)
```

`docs/` 디렉터리가 핵심이다. 주제별로 파일을 분리하면 여러 agent가 서로 다른 문서를 동시에 작성할 수 있다. 파일명은 lowercase, hyphen 구분(`concepts.md`, `docker-local-lab.md`), 각 파일은 H1 제목으로 시작하고 이후 H2 섹션으로 구성한다.

README.md는 프로젝트 개요와 docs/ 링크 테이블을 담는다:

```markdown
# 프로젝트 제목

## 개요
프로젝트에 대한 간단한 설명

## 문서 목차
| 문서 | 설명 |
|------|------|
| [concepts.md](./docs/concepts.md) | 핵심 개념 정리 |
```

</doc-structure>
