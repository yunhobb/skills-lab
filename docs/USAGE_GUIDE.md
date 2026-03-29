# Skills Lab 사용 가이드

이 레포에 정의된 스킬과 에이전트를 실전에서 어떻게 사용하는지 안내한다.

## 전체 구조

```
┌─────────────────────────────────────────────────────────────┐
│                    작업 파이프라인 (에이전트)                    │
│                                                             │
│  기획서 입력          요구사항 분석          설계 검증          │
│  ┌──────────┐      ┌──────────────┐      ┌──────────────┐   │
│  │  spec-   │─────▶│ req-analyzer │─────▶│   design-    │   │
│  │distiller │      │  ┌────────┐  │      │  challenger  │   │
│  └──────────┘      │  │explorer│  │      └──────┬───────┘   │
│                    │  │validate│  │             │            │
│  ┌──────────┐      │  └────────┘  │      ┌──────▼───────┐   │
│  │ notion-  │─────▶│              │      │  decision-   │   │
│  │ import   │      └──────┬───────┘      │  documenter  │   │
│  └──────────┘             │              └──────────────┘   │
│                    ┌──────▼───────┐                          │
│                    │ issue-filter │                          │
│                    └──────────────┘                          │
├─────────────────────────────────────────────────────────────┤
│                    품질 도구 (스킬)                            │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │skill-reviewer│  │agent-reviewer│  │ review-learnings │   │
│  └──────────────┘  └──────────────┘  └──────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│                    통합 워크플로우 (스킬)                       │
│                                                             │
│  ┌──────────────┐                                           │
│  │deep-thinking │  (위 에이전트들을 조합하는 가이드)             │
│  └──────────────┘                                           │
└─────────────────────────────────────────────────────────────┘
```

---

## 에이전트 7개 — 역할과 연결 관계

### 입력 계층: 기획서 → 요구사항

| 에이전트 | 한마디 역할 | 입력 | 출력 |
|---------|-----------|------|------|
| **spec-distiller** | PM 기획서에서 Intent vs Implementation 분리 | 기획서 문서 | 핵심 요구사항 + 성공 정의 |
| **notion-import** (스킬) | 노션 PDF 기획서를 읽어서 req-analyzer로 연결 | PDF 파일 | 요약 + req-analyzer 호출 |

### 분석 계층: 요구사항 → Issue 사양

| 에이전트 | 한마디 역할 | 입력 | 출력 |
|---------|-----------|------|------|
| **req-analyzer** | 모호한 요구사항을 구체적 Issue 사양으로 변환 | 자연어 요구사항 | GitHub Issue 초안 |
| **req-explorer** | 코드베이스/웹에서 맥락 수집 (req-analyzer가 호출) | 탐색 지시 | 맥락 리포트 |
| **req-validator** | Issue 초안의 구현 가능성 검증 (req-analyzer가 호출) | Issue 초안 | 검증 결과 |
| **issue-filter** | "이거 해야 해?" 가치/범위 판단 | Issue 또는 요구사항 | Go/No-Go 판단 |

### 설계 계층: 설계 → 검증 → 기록

| 에이전트 | 한마디 역할 | 입력 | 출력 |
|---------|-----------|------|------|
| **design-challenger** | 설계의 숨겨진 약점과 엣지케이스 발굴 | 설계/코드 | 약점 리포트 |
| **decision-documenter** | 기술 결정을 ADR로 기록 | 결정 사항 | ADR 문서 |

### 자동 연결 관계

에이전트들은 독립적으로도 쓸 수 있지만, 다음과 같이 자동으로 연결된다:

```
req-analyzer ──(중형 이상)──▶ req-explorer  (맥락 수집)
req-analyzer ──(대형)──────▶ req-validator  (사양 검증)
req-analyzer ──(완료 후)───▶ issue-filter   (가치/범위 판단, proactive 제안)
design-challenger ─(완료 후)─▶ decision-documenter (결정 기록, proactive 제안)
```

---

## 스킬 5개 — 역할과 사용법

| 스킬 | 트리거 예시 | 역할 |
|------|-----------|------|
| **deep-thinking** | "깊이 생각해줘", "구현 전 검토" | 에이전트 조합 워크플로우 가이드 |
| **skill-reviewer** | "스킬 리뷰해줘", "SKILL.md 점검" | SKILL.md 품질 리뷰 + 리라이트 |
| **agent-reviewer** | "에이전트 리뷰해줘", "agent 점검" | 에이전트 .md 파일 품질 리뷰 + 리라이트 |
| **review-learnings** | "리뷰 학습", "PR 리뷰 분석" | PR 리뷰 댓글에서 재사용 규칙 추출 |
| **notion-import** | "노션 기획서 분석", PDF 경로 제공 | 노션 PDF → req-analyzer 연동 |

---

## 실전 시나리오별 사용법

### 시나리오 1: PM에게 기획서를 받았을 때

```
1. /notion-import docs/기획서.pdf     ← PDF면 notion-import부터
   또는
   "이 기획서 핵심 요구사항 뽑아줘"     ← spec-distiller 발동

2. spec-distiller가 Intent / Implementation 분리
   → "빠른 응답 속도"(Intent) vs "Redis 사용"(Implementation)

3. Intent 기반으로 req-analyzer가 Issue 사양 작성

4. issue-filter가 자동으로 가치/범위 판단 제안
```

**핵심 가치**: PM이 "Redis 쓰세요"라고 했을 때, 그게 진짜 요구사항인지 제안인지 구분해준다. Intent만 지키면 구현 방법은 자유롭게 선택할 수 있다.

### 시나리오 2: 모호한 기능 요청을 받았을 때

```
유저: "알림 시스템 만들어줘"

1. req-analyzer 발동 → 모호한 점 식별 (채널? 타이밍? 대상?)
   - 중형 이상이면 req-explorer가 코드베이스 탐색
   - 대형이면 req-validator가 사양 초안 검증

2. 구체적인 Issue 사양 완성

3. issue-filter가 가치/범위 판단
   → "이건 해야 하지만 범위가 크니 3개 sub-issue로 나누세요" 같은 제안

4. 필요시 각 sub-issue별로 구현 진행
```

**핵심 가치**: "만들어줘"라는 한 마디에서 바로 코드를 짜지 않고, 뭘 만들어야 하는지부터 정리한다.

### 시나리오 3: 구현 전 설계를 검증하고 싶을 때

```
1. "깊이 생각해줘" 또는 /deep-thinking  ← deep-thinking 스킬 발동

2. deep-thinking이 워크플로우를 안내:
   ① req-analyzer로 요구사항 도출 (필요시)
   ② design-challenger로 약점 발굴     ← 핵심 단계
   ③ 사용자가 설계 보완
   ④ decision-documenter로 결정 기록

3. design-challenger가 발견하는 것들:
   - "Pessimistic lock만으론 학생별 학점 상한 race condition 못 막음"
   - "결제 API 타임아웃 시 멱등성 키 없으면 이중 결제 가능"

4. 보완 후 decision-documenter가 ADR 작성
   → 왜 이중 락을 선택했는지, 대안은 뭐였는지 기록
```

**핵심 가치**: "정상적으로 동작하는 것처럼 보이지만 특정 조건에서 터지는" 시나리오를 구현 전에 찾아낸다.

### 시나리오 4: 새 스킬/에이전트를 만들었을 때

```
1. 에이전트 파일 작성 → agent-review-reminder 훅이 리뷰 권장

2. "에이전트 리뷰해줘" → agent-reviewer 발동
   - frontmatter 검증 (name, description, tools, model, color)
   - description의 트리거 품질 평가
   - 최소 권한 원칙 점검
   - 컨벤션 기준으로 리라이트

3. 스킬 파일 작성 → skill-review-reminder 훅이 리뷰 권장

4. "스킬 리뷰해줘" → skill-reviewer 발동
   - description 트리거 품질
   - 구조와 작성 스타일
   - 500줄 이하 여부
```

**핵심 가치**: 스킬/에이전트의 description이 나쁘면 트리거가 안 되거나 엉뚱한 데서 발동한다. 리뷰어가 이를 잡아준다.

### 시나리오 5: PR 리뷰에서 반복되는 지적을 학습하고 싶을 때

```
1. "PR #42 리뷰 학습해줘" → review-learnings 발동

2. 리뷰 댓글에서 반복 가능한 패턴 추출
   - "이 함수 null 체크 빠짐" → "외부 입력은 항상 null check" (규칙화)

3. 적절성 판단 후 규칙 문서에 추가

4. 이후 코딩 시 이 규칙을 참조해서 같은 실수 방지
```

---

## 에이전트 조합 패턴 요약

| 상황 | 조합 | 설명 |
|------|------|------|
| 기획서 → 이슈 | spec-distiller → req-analyzer → issue-filter | 기획서에서 핵심만 뽑아 이슈화 |
| 모호한 요청 → 이슈 | req-analyzer (+explorer, +validator) → issue-filter | 모호함을 구체화하고 가치 판단 |
| 설계 검증 | design-challenger → decision-documenter | 약점 찾고 결정 기록 |
| 전체 워크플로우 | deep-thinking (위 모두 조합) | 요구사항 → 설계 검증 → 결정 기록 |
| 품질 관리 | skill-reviewer / agent-reviewer | 만든 스킬·에이전트 품질 검증 |
| 학습 루프 | review-learnings | PR 리뷰에서 규칙 추출 |

---

## 사용하지 않아야 할 때

| 에이전트/스킬 | 사용하지 않는 경우 |
|-------------|-----------------|
| spec-distiller | 이미 구체적인 기술 사양이 있을 때 |
| req-analyzer | 범위와 산출물이 명확할 때 (바로 구현) |
| issue-filter | 코드 리뷰, 구현, 설계 분석 |
| design-challenger | 코드 스타일 리뷰 (이건 code-reviewer 역할) |
| decision-documenter | 코드 작성이나 구현 |
| req-explorer / req-validator | 직접 호출 금지 (req-analyzer가 오케스트레이션) |