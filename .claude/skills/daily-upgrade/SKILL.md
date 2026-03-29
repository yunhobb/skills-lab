---
name: daily-upgrade
description: |
  Upgrade all development tools via Homebrew, sync Brewfile packages, and verify RTK hooks. Use this skill whenever the user mentions daily upgrade, brew update, package upgrade, claude-code update, brew outdated, 데일리 업그레이드, 브루 업데이트, 패키지 업데이트, 일일 업그레이드, 패키지 정리, or any request to bring their dev environment up to date — even casual mentions like "update everything", "오늘 업데이트 좀", "환경 최신화", "업그레이드 해줘", "최신 버전으로".
allowed-tools: Bash
---

# Daily Upgrade

개발 환경 전체를 최신 상태로 갱신한다: Homebrew 패키지, Brewfile 동기화, RTK 훅 검증.

## 실행 순서

순서대로 실행한다. 한 단계가 실패해도 나머지는 계속 진행하되, 실패를 기록한다.

### 1. Homebrew 메타데이터 갱신

최신 패키지 정보가 없으면 `brew upgrade`가 새 버전을 감지하지 못한다.

```bash
brew update
```

### 2. Brewfile 동기화

Brewfile이 존재하면 누락된 패키지를 설치하여 환경 재현성을 유지한다. 없으면 건너뛴다.

```bash
BREWFILE=~/Desktop/Claude-Skills/homebrew/Brewfile
if [ -f "$BREWFILE" ]; then
  brew bundle install --file="$BREWFILE"
else
  echo "Brewfile not found at $BREWFILE — skipping"
fi
```

### 3. 전체 패키지 업그레이드

formulae와 cask 모두 업그레이드한다 (Claude Code 포함).

```bash
brew upgrade
```

### 4. 정리

업그레이드 후 생긴 구버전을 삭제하여 디스크 공간을 확보한다.

```bash
brew cleanup
```

### 5. RTK 훅 검증

RTK(토큰 절약 프록시)는 업그레이드 후 깨질 수 있으므로 항상 확인한다.

```bash
rtk init --show
```

출력에 에러가 있거나 훅이 비활성 상태이면 복구한다:

```bash
rtk init --global --auto-patch
```

### 6. 버전 확인 및 결과 보고

버전 정보를 수집한 뒤 아래 표 형식으로 보고한다:

```bash
claude --version
rtk --version
```

| 항목 | 결과 |
|------|------|
| brew update | OK / 실패 사유 |
| Brewfile 동기화 | N개 설치 / 이미 최신 / 파일 없음 |
| brew upgrade | N개 업그레이드 / 이미 최신 |
| brew cleanup | N개 정리 / 정리할 것 없음 |
| Claude Code 버전 | vX.X.X |
| rtk 버전 | vX.X.X |
| rtk 훅 상태 | OK / 복구 필요 |
