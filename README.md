# skills-lab

Claude Code 스킬과 에이전트를 개발하고 테스트하는 레포지토리.

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
# skill-reviewer -> /path/to/skills-lab/skill-reviewer
# agent-reviewer -> /path/to/skills-lab/agent-reviewer
# review-learnings -> /path/to/skills-lab/review-learnings
```

### 심링크 제거

수동으로 제거하려면:

```bash
rm ~/.claude/skills/skill-reviewer
rm ~/.claude/skills/agent-reviewer
rm ~/.claude/skills/review-learnings
```

## 스킬 및 에이전트 목록

이 레포지토리에서 관리하는 스킬과 에이전트의 전체 목록 및 상세 설명은 [AGENTS.md](AGENTS.md#스킬-목록)를 참조하세요.
## 기여

스킬이나 에이전트를 추가한 후 `setup.sh`의 `SKILLS` 배열에 디렉토리 이름을 추가하세요.
