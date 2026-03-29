---
name: notion-import
description: |
  This skill should be used when the user wants to analyze a Notion document exported as PDF. "노션 기획서 분석", "notion-import", "기획서 PDF 분석", "노션 PDF 가져와", "기획서 분석해줘", "spec 분석", or when the user provides a PDF file path for requirement analysis. Also triggers on "요구사항 뽑아줘", "이슈 만들어줘" with a PDF.
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

### 이미지 보완 (선택)

PDF에서 이미지가 잘 안 보이거나 중요한 다이어그램이 있으면 스크린샷 경로를 물어본다. 스크린샷이 있으면 Read로 이미지를 읽어서 분석에 포함한다.

## 제약사항

- PDF 원본을 수정하지 않는다
- PDF 내용을 임의로 해석하지 않는다 — 모호한 부분은 req-analyzer를 통해 유저에게 질문
- 한 번에 20페이지까지 읽을 수 있다 — 긴 문서는 나눠서 처리
