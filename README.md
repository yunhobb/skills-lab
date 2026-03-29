# skills-lab

Claude Code 스킬과 에이전트를 개발하고 테스트하는 레포지토리.

> **[사용 가이드 (USAGE_GUIDE.md)](docs/USAGE_GUIDE.md)** — 스킬·에이전트의 유기적 조합 패턴과 실전 시나리오별 사용법

## 설치

```bash
git clone git@github.com:yunhobb/skills-lab.git
cd skills-lab
bash setup.sh
```

`setup.sh`는 프로젝트의 스킬 디렉토리를 `~/.claude/skills/`에 심링크로 연결합니다. Claude Code를 재시작하면 스킬이 인식됩니다.

### 심링크 확인

```bash
ls -la ~/.claude/skills/
# skill-reviewer -> /path/to/skills-lab/.claude/skills/skill-reviewer
# agent-reviewer -> /path/to/skills-lab/.claude/skills/agent-reviewer
# review-learnings -> /path/to/skills-lab/.claude/skills/review-learnings
# deep-thinking  -> /path/to/skills-lab/.claude/skills/deep-thinking
```

### 심링크 제거

```bash
bash setup.sh uninstall
```

## 에이전트

### 요구사항 분석 파이프라인

모호한 요구사항을 구체화하여 GitHub Issue로 변환하는 에이전트 파이프라인.

| 에이전트 | 역할 | 모델 | 도구 |
|---------|------|------|------|
| `req-analyzer` | 모호한 요구사항을 질문으로 구체화하고 Issue 사양 작성 | sonnet | Read, Grep, Glob |
| `req-explorer` | 코드베이스와 외부 자료에서 맥락 수집 | sonnet | Read, Grep, Glob, WebSearch, WebFetch |
| `req-validator` | Issue 초안의 구현 가능성과 방향 적절성 검증 | sonnet | Read, Grep, Glob |

**동작 흐름:**

```
유저: "알림 시스템 만들어줘" (모호한 요구사항)
         │
         ▼
   req-analyzer ── 규모 판단 (소/중/대)
         │
    ┌────┼────────────┐
    │    │             │
   소형  중형          대형
    │    │             │
    │    ▼             ▼
    │  req-explorer  req-explorer
    │  (맥락 수집)   (맥락 수집)
    │    │             │
    │    ▼             ▼
    │  req-analyzer  req-analyzer
    │  (질문+분석)   (질문+분석)
    │    │             │
    │    │             ▼
    │    │         req-validator
    │    │         (검증 루프)
    │    │             │
    ▼    ▼             ▼
   GitHub Issue 사양 출력
```

- **소형** (모호한 점 1-2개): req-analyzer만 사용. 바로 질문을 던져서 구체화.
- **중형** (모호한 점 3-5개): req-explorer가 코드베이스/외부 맥락을 수집한 뒤 req-analyzer가 분석.
- **대형** (전체적으로 불명확): 위 과정에 req-validator가 추가되어 Issue 초안을 검증. PASS할 때까지 수정-검증 루프 반복.

### 설계 깊이 분석

구현 전에 숨겨진 복잡성을 발굴하고 기술 결정을 문서화하는 에이전트.

| 에이전트 | 역할 | 모델 | 도구 |
|---------|------|------|------|
| `design-challenger` | 설계/코드의 숨겨진 약점과 엣지케이스 발굴 | opus | Read, Grep, Glob |
| `decision-documenter` | 기술 결정과 트레이드오프를 ADR 형식으로 기록 | sonnet | Read, Write, Grep, Glob |

#### design-challenger

"정상적으로 동작하는 것처럼 보이지만 특정 조건에서 터지는 시나리오"를 찾는 에이전트. 읽기 전용이며 코드를 수정하지 않는다.

**분석 관점 (5가지 렌즈):**

| 관점 | 찾는 것 | 예시 |
|------|---------|------|
| 동시성 구멍 | 보호되지 않는 공유 자원 접근 경로 | 강좌 정원은 락으로 보호했지만, 학생별 학점 상한 체크에 race condition |
| 데이터 정합성 | 검증과 실행 사이의 상태 변경 (TOCTOU) | 학점 확인 → 등록 사이에 다른 요청이 먼저 등록 완료 |
| 실패 모드 | 네트워크 장애, 부분 실패 시 상태 | DB 커밋 후 캐시 업데이트 전에 서버 다운 |
| 암묵적 가정 | "당연하다"고 전제한 것 중 깨질 수 있는 것 | 단일 인스턴스 가정, 순서 보장 가정 |
| 엣지케이스 | 경계 조건에서의 동작 | 정원 0인 강좌, 동시 만료, 중복 요청 |

**입력에 따른 동작:**
- 설계 문서만 있으면 → 논리적 허점 분석 (설계 레벨)
- 코드가 있으면 → 실제 race condition, 락 누락 분석 (코드 레벨)
- 둘 다 있으면 → 설계 의도와 구현 일치 여부까지 확인

**출력 예시:**

```
## 분석 요약
대상: 수강신청 동시성 설계
발견된 약점: 3개 (Critical: 1, Warning: 1, Info: 1)

## [Critical] 학생 레벨 락 누락
시나리오:
1. 학생 A가 과목1 수강신청 (학점 확인: 15학점 → 통과)
2. 학생 A가 동시에 과목2 수강신청 (학점 확인: 15학점 → 통과)
3. 둘 다 등록 성공 → 학생 A는 21학점 (상한 18학점 위반)

영향: 학점 상한 제약조건 위반 — 데이터 정합성 깨짐
제안: 학생 레벨 락 추가. 단, 강좌 락과의 순서를 통일해야 데드락 방지.
```

#### decision-documenter

기술 결정을 ADR(Architecture Decision Record) 형식으로 기록하는 에이전트. 코드를 수정하지 않으며 문서 생성만 수행한다.

**출력 위치:** 프로젝트의 기존 문서 구조를 파악하여 적응한다. 기존 ADR 디렉터리가 있으면 따르고, 없으면 `docs/decisions/`에 생성한다.

**ADR 문서 구조:**

```markdown
# 001. 동시성 제어 전략

## 상황
수강신청에서 정원 1자리에 100명이 동시 경쟁하는 극한 경합 상황.

## 선택지
### A. Pessimistic Lock (SELECT FOR UPDATE)
- 장점: 충돌 시 재시도 불필요, 정합성 보장 단순
- 단점: 처리량 제한, 락 대기 시간

### B. Optimistic Lock (버전 체크)
- 장점: 높은 처리량, 락 없음
- 단점: 99명 실패 → 재시도 폭풍

## 결정
Pessimistic Lock. 수강신청은 정확성 > 속도인 도메인이며,
99% 충돌률에서 Optimistic의 재시도 비용이 Pessimistic의 락 비용보다 크다.

## 포기한 것
동시 처리량. 락 획득 대기로 인해 순차 처리에 가까워진다.

## 재검토 조건
학생 수가 100,000명을 넘거나, 수강신청 기간이 1시간 미만으로 줄어들면
큐 기반 아키텍처 재검토.
```

## 스킬

### 리뷰/품질 스킬

| 스킬 | 호출 | 역할 |
|------|------|------|
| `skill-reviewer` | `/skill-reviewer` | SKILL.md를 Anthropic 스타일 가이드 기준으로 리뷰 |
| `agent-reviewer` | `/agent-reviewer` | 에이전트 정의 파일을 컨벤션 기준으로 리뷰 |
| `review-learnings` | `/review-learnings` | PR 리뷰 댓글에서 재사용 가능한 규칙 추출 |
| `notion-import` | `/notion-import` | Notion 페이지를 마크다운으로 변환 |

### 워크플로우 스킬

| 스킬 | 호출 | 역할 |
|------|------|------|
| `deep-thinking` | `/deep-thinking` | 구현 전 깊은 사고 워크플로우 가이드 |

#### deep-thinking

구현 전에 숨겨진 복잡성을 발굴하고 기술 결정을 문서화하는 워크플로우. `/deep-thinking`으로 호출한다.

**워크플로우:**

```
1. 요구사항 도출    ─── req-analyzer (선택)
       │
2. 약점 발굴       ─── design-challenger (핵심)
       │
3. 설계 보완       ─── 사용자 판단
       │
4. 결정 문서화     ─── decision-documenter
       │
5. 구현 진행
```

모든 단계를 거칠 필요 없다. 각 에이전트는 독립적으로도 호출 가능하며, 이 스킬은 "이 순서로 하면 좋다"는 가이드를 제공한다.

**적합한 경우:**
- 동시성, 분산 시스템, 결제 등 정합성이 중요한 도메인
- 요구사항이 모호하고 숨겨진 복잡성이 의심되는 경우
- 여러 기술 대안 중 선택이 필요한 경우

**과잉인 경우:**
- 단순 CRUD, 설정 변경, 버그 수정
- 이미 검증된 패턴의 반복 적용

**팁:** 판단이 애매하면 2단계(design-challenger)만 빠르게 돌려본다. 약점이 나오면 전체 워크플로우로, 안 나오면 바로 구현.

## 기여

스킬이나 에이전트를 추가한 후 `setup.sh`의 `SKILLS` 배열에 디렉토리 이름을 추가하세요. 상세 컨벤션은 [AGENTS.md](AGENTS.md)를 참조하세요.
