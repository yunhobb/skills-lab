# Skills Lab

Claude Code 스킬과 에이전트를 개발하고 테스트하는 레포지토리.

이 레포는 Claude Code의 확장 기능(스킬, 에이전트, 훅)을 만들고 품질을 검증하는 곳이다. 만든 스킬/에이전트는 다른 프로젝트에서 재사용된다 — 여기서 품질이 낮으면 사용하는 모든 곳에서 문제가 생긴다.

## 핵심 원칙

유저의 판단이 필요한 선택지가 있을 때 AskUserQuestion 도구를 사용한다 — 단순 확인("진행할까요?")이나 정보 전달에는 쓰지 않는다.

질문 구성:
- 선택지는 3개를 기본으로 한다
- 각 선택지의 description에 장점과 단점을 포함한다
- 유저는 항상 "Other"로 직접 입력할 수 있다 (자동 제공)
- 비교가 필요한 경우 preview를 활용한다

## 참조 문서

@docs/workflow.md
@docs/conventions.md
@docs/catalog.md
