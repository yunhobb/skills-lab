---
name: notion-import
description: |
  This skill should be used when the user wants to import a Notion document into Claude Code. "노션 가져와", "노션 기획서 분석", "notion-import", "기획서 가져오기", "노션 문서 읽어줘", "클립보드에 복사해뒀어", or when the user mentions bringing Notion content into the current session.
allowed-tools: Read, Write, Bash, Glob
---

# Notion Import

노션 문서를 Claude Code로 가져오는 스킬. 클립보드 텍스트(마크다운)를 기본으로 하고, 이미지가 중요한 섹션은 스크린샷 파일로 보완한다.

## 입력 방식

두 가지 입력을 조합한다:

**클립보드 (필수)** — 노션에서 Cmd+A → Cmd+C 하면 텍스트가 마크다운으로 복사된다. `pbpaste`로 읽는다.

**스크린샷 (선택)** — 다이어그램, 와이어프레임, 표 등 이미지가 중요한 섹션만 캡처해서 폴더에 저장. 경로를 인자로 전달하거나, 스킬이 질문한다.

## 워크플로우

### 클립보드 읽기

`pbpaste`로 클립보드 내용을 가져와서 마크다운 파일로 저장한다.

```bash
pbpaste > docs/spec/notion-content.md
```

클립보드가 비어있거나 마크다운이 아니면 유저에게 알린다:
- "노션에서 Cmd+A → Cmd+C로 내용을 복사한 뒤 다시 실행해주세요"

### 스크린샷 확인

유저에게 이미지 보완이 필요한지 물어본다:
- "스크린샷 파일이 있나요? 경로를 알려주세요 (없으면 텍스트만으로 진행합니다)"

스크린샷이 있으면 해당 이미지 파일들을 Read로 읽어서 텍스트와 함께 분석에 포함한다.

### 저장

가져온 내용을 정리하여 저장한다:

```
docs/spec/
├── notion-content.md    # 클립보드에서 가져온 텍스트
└── images/              # 스크린샷 (있는 경우)
    ├── 01-diagram.png
    └── 02-wireframe.png
```

저장 경로는 유저가 지정할 수 있다. 지정하지 않으면 `docs/spec/`을 기본으로 사용한다.

### 결과 보고

가져온 내용을 요약한다:
- 텍스트 분량 (줄 수, 섹션 수)
- 포함된 스크린샷 수
- 저장 경로

이후 유저가 원하면 req-analyzer 등 다른 스킬/에이전트에 넘겨서 분석할 수 있다.

## 제약사항

- 클립보드 내용을 임의로 수정하지 않는다 — 원문 그대로 저장
- 노션 이미지 링크(notion.so URL)는 인증이 필요해서 접근 불가 — 스크린샷으로 대체한다는 안내를 유저에게 한다
- macOS 전용 (`pbpaste` 사용) — 다른 OS에서는 유저에게 수동 붙여넣기를 안내
