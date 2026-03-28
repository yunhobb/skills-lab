---
name: notion-import
description: |
  This skill should be used when the user wants to analyze a Notion document exported as PDF. "노션 기획서 분석", "notion-import", "기획서 PDF 분석", "노션 PDF 가져와", "기획서 분석해줘", "spec 분석", or when the user provides a PDF file path for requirement analysis. Also triggers on "요구사항 뽑아줘", "이슈 만들어줘" with a PDF.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Notion Import

노션에서 내보낸 PDF 기획서를 읽고 요구사항을 분석하는 스킬. PDF를 입력받아 내용을 파악한 뒤, req-analyzer와 연동하여 모호한 점 식별 → 질문 → GitHub Issue 생성까지 한 번에 수행한다.

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

PDF 내용을 파악한 뒤 유저에게 요약을 보여준다:
- 문서 제목 / 목적
- 주요 섹션 목록
- 전체 페이지 수

유저가 요약을 확인하고 분석 진행 여부를 결정한다.

### 요구사항 분석 (req-analyzer 연동)

유저가 분석을 원하면 req-analyzer 에이전트에 PDF 내용을 전달한다. req-analyzer가 수행하는 작업:

1. 모호한 점 식별 — 기획서에서 정의되지 않은 용어, 누락된 제약 조건, 암묵적 가정을 찾는다
2. 질문으로 구체화 — 모호한 점마다 선택지를 포함한 질문을 유저에게 던진다
3. GitHub Issue 생성 — 답변을 반영하여 목표/범위/제약조건/TODO가 포함된 Issue를 작성한다

규모 판단은 req-analyzer가 자동으로 수행한다 (소형/중형/대형에 따라 에이전트 구성이 달라짐).

### 이미지 보완 (선택)

PDF에서 이미지가 잘 안 보이거나 중요한 다이어그램이 있으면, 유저에게 스크린샷을 요청한다:
- "다이어그램/와이어프레임 스크린샷이 있으면 경로를 알려주세요"

스크린샷이 있으면 Read로 이미지를 읽어서 분석에 포함한다.

## 제약사항

- PDF 원본을 수정하지 않는다
- PDF 내용을 임의로 해석하지 않는다 — 모호한 부분은 유저에게 질문
- 한 번에 20페이지까지 읽을 수 있다 — 긴 문서는 나눠서 처리
