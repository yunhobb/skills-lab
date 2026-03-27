---
name: skill-reviewer
description: This skill should be used when the user asks to "review a skill", "rewrite SKILL.md", "check skill quality", "improve skill style", "Anthropic style check", or provides a skill path for style review. Rewrites SKILL.md files to follow Anthropic's prompt authoring best practices.
allowed-tools: Read, Write, Edit, Glob, Grep, WebFetch
---

# Skill Reviewer

Rewrite SKILL.md files to follow Anthropic's writing style for agent-facing prompts. The user provides a skill path — read the current SKILL.md and rewrite it in place.

## Input

The user provides a skill directory path (e.g., `~/.claude/skills/my-skill/`). Read the SKILL.md inside that directory. If the user provides the full file path, use it directly.

## Style Guide

These patterns come from Anthropic's skill-creator and their prompting best practices. The goal is instructions that an AI agent can parse and follow reliably.

**Principles:**

1. Use imperative form — tell the agent what to do, not what it "should" do
2. Explain WHY a rule matters instead of stamping MUST on it — agents follow instructions better when they understand the reasoning
3. Keep a conversational, direct tone — like explaining the task to a capable colleague
4. Stay general — do not overfit to specific examples; the skill will be used across many different inputs
5. Keep it lean — remove anything not pulling its weight; if a section does not change agent behavior, cut it
6. Use examples to clarify patterns that are hard to describe abstractly — one excellent example beats many mediocre ones
7. Use imperative/infinitive form, not second person — write "Read the file" not "You should read the file"

**Structure:**

Use markdown headers (`##`, `###`) for structuring sections — this is the Anthropic convention for SKILL.md files. Reserve deep nesting (H4+) only when truly needed; prefer bold text, lists, or flattening instead.

**Description field:**

Write descriptions in trigger-condition style with specific phrases users would say. Summarizing the workflow in the description causes Claude to shortcut the skill body.

Good: `This skill should be used when the user asks to "create a hook", "add a PreToolUse hook", or mentions hook events.`

Bad: `An agent that creates hooks by reading config, validating schema, and writing files.`

## Rewrite Rules

### Preserve

- YAML frontmatter — update `description` if the skill's scope changed, but keep the `name`
- Rename `tools` to `allowed-tools` if present (the correct frontmatter field)
- All core logic and rules — rewrite style, not behavior
- Domain-specific terminology and technical accuracy
- File references (paths to scripts, references, assets)

### Transform

- Replace heavy-handed MUSTs and ALWAYS with reasoning: explain why the rule exists
- Flatten deep header nesting (H4+) — use bold text, lists, or additional H3s instead
- Remove filler words: "please note that", "it is important to", "make sure to"
- Convert passive voice to imperative: "should be checked" becomes "check"
- Convert second person to imperative: "You should read" becomes "Read"
- Reduce bold overuse — bold only the key term or phrase the agent must not miss
- Remove backtick overuse — backticks are for code/commands/filenames, not emphasis
- Merge small sections (1-2 sentences under a header) into their parent section

### Before/After Examples

**Heavy MUST to reasoning-based:**

```
BEFORE: You MUST ALWAYS use lowercase for kubernetes.
AFTER: Use lowercase for kubernetes — the official project does not capitalize it outside of logos.
```

**Second person to imperative:**

```
BEFORE: You should review the document for grammar errors first.
AFTER: Review grammar and spelling first.
```

**Bold overuse:**

```
BEFORE: Use **dashes** for **all lists**. Do **not** use **asterisks**.
AFTER: Use dashes (`-`) for all lists. Do not use asterisks.
```

**Deep nesting to flat:**

```
BEFORE:
### 3. Markdown Rules
#### Lists
##### Ordered
##### Unordered

AFTER:
### Markdown Rules
Lists: use dashes for all unordered lists. Use numbers for ordered lists.
```

## Workflow

1. Read the current SKILL.md at the given path
2. Identify what the skill does — understand its purpose before changing anything
3. Rewrite the body following the style guide and transform rules above
4. Update the YAML `description` to trigger-condition style if it summarizes workflow instead
5. Rename `tools` to `allowed-tools` in frontmatter if present
6. Write the rewritten SKILL.md back to the same path
7. Report what changed: list the major style transformations applied (not a line-by-line diff)

## Constraints

- Do not change the skill's behavior or rules — only the writing style and structure
- Do not add new features or remove existing capabilities
- If unsure whether a change alters behavior, keep the original wording
- The final output is the rewritten file, not a suggestion — write it directly
- Target 1,500-2,000 words for the rewritten body; if the original exceeds this, suggest moving detailed content to a `references/` directory
