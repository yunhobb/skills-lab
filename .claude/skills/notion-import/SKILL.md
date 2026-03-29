---
name: notion-import
description: |
  This skill should be used when the user wants to import a Notion document exported as PDF for analysis. "노션 PDF 분석", "notion-import", "노션 PDF 가져와", "PDF 기획서 열어줘", or when the user provides a PDF file path (.pdf) for requirement analysis. PDF 파일 경로가 명시된 경우에만 트리거한다 — PDF 없이 "기획서 분석해줘"만 말하면 req-analyzer가 담당한다.
allowed-tools: Read, Glob
---

# Notion Import

노션에서 내보낸 PDF 기획서를 읽고, req-analyzer와 연동하여 요구사항 분석 → GitHub Issue 생성까지 수행하는 스킬.

## 입력

유저가 PDF 파일 경로를 전달한다. 인자가 없으면 경로를 물어본다.

```
/notion-import docs/spec.pdf
/notion-import ~/Downloads/기획서.pdf
```

## 워크플로우

### PDF 읽기

Read 도구로 PDF를 읽는다. PDF가 길면 `pages` 파라미터로 나눠서 읽는다 — 한 번에 최대 20페이지.

파일이 존재하지 않거나 PDF가 아니면 알리고 종료한다.

### 내용 요약

PDF 내용을 파악한 뒤 요약을 보여준다:
- 문서 제목 / 목적
- 주요 섹션 목록
- 전체 페이지 수

요약을 보여주고 분석 진행 여부를 물어본다.

### req-analyzer 연동

분석을 진행하면 PDF 내용을 req-analyzer 에이전트에 전달한다. 이후 모호함 식별, 질문, Issue 생성은 req-analyzer가 수행한다 — 이 스킬에서 직접 분석하지 않는다.

전달 형식:
- **원문 텍스트**: PDF에서 추출한 전체 텍스트
- **문서 메타데이터**: 제목, 페이지 수, 주요 섹션 목록
- **입력 유형 힌트**: "기획서"임을 명시 — req-analyzer가 이를 보고 spec-distiller 위임 여부를 판단한다

### 분석 후 다음 단계

req-analyzer 분석이 완료되면 다음으로 이어갈 수 있다:
- **design-architect**: 요구사항을 기반으로 spec.md, plan.md, tasks.md 생성
- **deep-thinking**: 설계 검증 워크플로우 (약점 발굴 → 결정 문서화)

### 이미지 보완 (선택)

PDF에서 이미지가 잘 안 보이거나 중요한 다이어그램이 있으면 스크린샷 경로를 물어본다. 스크린샷이 있으면 Read로 이미지를 읽어서 분석에 포함한다.

## 제약사항

- PDF 원본을 수정하지 않는다
- PDF 내용을 임의로 해석하지 않는다 — 모호한 부분은 req-analyzer를 통해 유저에게 질문
- 한 번에 20페이지까지 읽을 수 있다 — 긴 문서는 나눠서 처리
