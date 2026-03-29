---
name: work-sync
description: |
  This skill should be used when the user asks to "이슈 업데이트해줘", "작업 정리해줘", "변경사항 반영", "대화 내용 정리해서 반영해줘", "이슈에 코멘트 남겨줘", "지금까지 한 거 정리", "진행상황 업데이트", "work-sync", or wants conversation progress captured in a tracking document (Issue comment or MD file). Also trigger when a work session is wrapping up and the user mentions syncing progress. ADR 수준의 상세 기술 결정 문서화("의사결정 기록", "결정 문서화", "ADR 작성")는 decision-documenter가 담당한다 — 이 스킬은 경량 진행 기록용이다.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Work Sync

대화에서 발생한 의사결정, 범위 변경, 새로운 발견을 추적 문서(GitHub Issue 또는 MD 파일)에 반영한다.

## 워크플로우

### 추적 대상 식별

대화 맥락에서 추적 대상을 찾는다:

- 유저가 Issue 번호를 언급했으면 → 해당 Issue
- 현재 브랜치가 `feat/`, `fix/` 등이면 → 연결된 Issue 탐색 (`gh issue list`로 확인)
- 둘 다 없으면 → 유저에게 Issue 번호 또는 MD 파일 경로를 물어본다

### 대화 맥락 분석

대화에서 다음 4가지를 추출한다:

**의사결정** — "A 대신 B로 하기로 했다", "X 방식을 선택했다" 같은 결정. 결정 내용과 이유를 함께 기록한다.
- 예: "Pessimistic Lock 선택 — 충돌률 99%에서 Optimistic의 재시도 비용이 더 크기 때문"

**범위 변경** — 원래 계획에 없었지만 추가되거나 제거된 항목. 추가/제거를 구분한다.
- 예: "캐시 레이어 추가 (성능 요구사항 발견)", "관리자 UI 제외 (MVP 범위 축소)"

**새로운 발견** — 작업 중 발견한 기술적 사실, 제약조건, 리스크.
- 예: "기존 API가 pagination을 지원하지 않아 별도 구현 필요"

**완료/미완료 항목** — TODO에서 완료된 것과 새로 추가된 TODO.

### Issue 반영

Issue에 코멘트로 추가한다. Issue body는 수정하지 않는다 — body는 원래 사양이고, 변경 이력은 코멘트로 쌓는 것이 추적에 유리하다.

코멘트 형식:

```markdown
## 작업 진행 업데이트

### 의사결정
- 결정 내용 — 이유

### 범위 변경
- ➕ 추가된 항목 — 이유
- ➖ 제거된 항목 — 이유

### 새로운 발견
- 발견 내용

### 진행 상태
- [x] 완료된 항목
- [ ] 새로 추가된 TODO
```

```bash
gh issue comment <number> --body "코멘트 내용"
```

해당 카테고리에 내용이 없으면 해당 섹션을 생략한다 — 빈 섹션을 남기지 않는다.

### MD 파일 반영

파일 내 체크리스트를 업데이트한다:
- 완료된 항목은 `[x]`로 변경
- 새 TODO는 적절한 위치에 추가
- 의사결정은 `## 의사결정 로그` 섹션에 추가 (없으면 생성)

### 확인

반영 후 결과를 유저에게 보여준다:
- Issue → 코멘트 URL
- MD → 변경된 부분 요약

## 반영하지 않는 것

- 구현 세부사항 (코드 레벨 변경) — 커밋 메시지와 diff가 담당
- 일시적인 디버깅 과정 — 결론만 기록
- 유저가 "이건 기록하지 마"라고 한 내용
