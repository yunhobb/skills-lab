---
name: agent-reviewer
description: This skill should be used when the user asks to "review an agent", "check agent quality", "improve agent file", "rewrite agent", "agent style check", "agent convention check", "check agent frontmatter", "improve agent description", or provides an agent `.md` file path for review. Use this skill whenever the user mentions agent definition quality, agent description triggering, agent system prompt style, or wants to improve any agent file — even if they don't explicitly say "review".
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Agent Reviewer

Rewrite agent definition files (`.md` with YAML frontmatter) to follow Claude Code's agent authoring conventions. Read the agent file, evaluate it against the conventions, and rewrite it in place — improving style and completeness without changing behavior.

Do not use for SKILL.md review (use skill-reviewer) or production code review (use code-reviewer) — this skill only handles agent definition files.

## Input

The user provides an agent file path (e.g., `~/.claude/plugins/my-plugin/agents/code-reviewer.md`). Read the file directly. If the user provides a directory, look for `.md` files inside an `agents/` subdirectory. If exactly one agent `.md` file is found, treat that as the target. If multiple agent `.md` files are found, do not rewrite them all; instead, either ask the user to specify a single file or explain that they must provide a specific agent file path. Never rewrite more than one agent file per request.

## Convention Reference

Evaluate the agent file against `references/agent-conventions.md`. Read the reference before starting the rewrite — it covers frontmatter rules, description quality criteria, system prompt structure, and before/after examples.

## Rewrite Rules

### Preserve

- The agent's core behavior, logic, and domain rules — rewrite style, not function
- YAML frontmatter `name` field (unless it violates naming rules)
- Technical terminology and domain accuracy
- File references and script paths

### Transform

**Frontmatter:**
- Add missing required fields (`name`, `description`, `model`, `color`)
- Fix `name` if it violates naming rules (lowercase + hyphens, 3-50 chars)
- Upgrade `description` to trigger-condition style with `<example>` blocks — vague descriptions cause Claude to miss delegation opportunities
- Adjust `model` if mismatched to complexity (e.g., `opus` for a simple linter wastes resources)
- Adjust `tools` to least-privilege — unnecessary tools distract the agent and risk unintended side effects

**Description:**
- Convert workflow summaries to trigger-condition format — Claude needs to know what the user *says*, not what the agent does internally
- Add `<example>` blocks if fewer than 2 exist — Claude matches intent against these, so variety improves trigger accuracy
- Add `<commentary>` explaining the reasoning behind each trigger
- Cover both proactive and reactive scenarios

**System prompt:**
- Structure so the agent knows: what it is, what to do, how to do it, what good output looks like — scale sections to complexity
- Replace heavy-handed MUSTs with reasoning — agents follow instructions better when they understand why a rule exists
- Convert to imperative form: "Read", "Analyze", "Check" — not "You should read"
- Remove filler: "please note that", "it is important to", "make sure to"
- Flatten H4+ nesting — deep hierarchies cause agents to lose track of section context
- Bold only key terms the agent must not miss; backticks for code/commands/filenames only
- Merge tiny sections (1-2 sentences) into parent sections

## Workflow

1. Read the agent file at the given path
2. Read `references/agent-conventions.md` for the full convention set
3. Identify the agent's purpose — understand what it does before changing anything
4. Evaluate frontmatter, description, and system prompt against conventions
5. Rewrite the file following the transform rules above
6. Write the rewritten file back to the same path
7. Report what changed: list the major improvements grouped by category (frontmatter, description, system prompt). If the file already meets conventions, say so and note only minor adjustments.

## Constraints

- Do not change the agent's behavior or domain rules — only style, structure, and completeness
- Do not add capabilities the agent didn't have
- If unsure whether a change alters behavior, keep the original wording
- The final output is the rewritten file, not a suggestion — write it directly
