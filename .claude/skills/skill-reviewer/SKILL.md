---
name: skill-reviewer
description: This skill should be used when the user asks to "review a skill", "rewrite SKILL.md", "check skill quality", "improve skill style", "Anthropic style check", "is my skill well-written", or provides a skill path for review. Also use when users mention "skill doesn't trigger well", "skill feels bloated", "skill output is inconsistent", or want to polish any SKILL.md for better agent parsing — even if they don't explicitly say "review".
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Skill Reviewer

Review and rewrite SKILL.md files to follow Anthropic's prompt authoring best practices. The user provides a skill path — read the current SKILL.md, assess it across three dimensions (description quality, structure, writing style), and rewrite it in place.

## Input

The user provides a skill directory path (e.g., `~/.claude/skills/my-skill/`). Read the SKILL.md inside that directory. If the user provides the full file path, use it directly.

## Review Dimensions

Assess the skill across three areas before rewriting. Report findings for each, then apply fixes in the rewrite.

### Description Quality

The `description` field is the primary trigger mechanism — it determines whether Claude invokes the skill. A poor description means the skill never fires, no matter how good the body is.

- Write in **trigger-condition style** with specific phrases users would say. Summarizing the workflow causes Claude to shortcut the skill body instead of reading it.
- Be slightly pushy — include adjacent phrases and edge cases where the skill should still trigger. Claude tends to under-trigger, so err on the side of broader matching.
- Include both what the skill does and when to use it.

Good: `This skill should be used when the user asks to "create a hook", "add a PreToolUse hook", or mentions hook events.`

Bad: `An agent that creates hooks by reading config, validating schema, and writing files.`

### Structure and Progressive Disclosure

Skills use a three-level loading system: metadata (always in context), SKILL.md body (loaded on trigger), and bundled resources (loaded on demand). Keep the body under **500 lines** — if approaching this limit, move detailed content (large example sets, reference tables, domain-specific docs) to a `references/` directory with clear pointers from SKILL.md about when to read them.

Check for:
- Sections that could live in `references/` instead of the body
- Missing pointers to existing reference files
- Headers that are too deeply nested (H4+) — flatten with bold text, lists, or additional H3s

### Writing Style

These patterns come from Anthropic's skill-creator and their prompting best practices. The goal is instructions that an AI agent can parse and follow reliably.

**Principles:**

1. Use imperative form — tell the agent what to do, not what it "should" do
2. Explain WHY a rule matters — agents follow instructions better when they understand the reasoning, and this scales across diverse inputs better than rigid directives
3. Keep a conversational, direct tone — like explaining the task to a capable colleague
4. Stay general — skills get used across many different inputs, so avoid overfitting to specific examples
5. Keep it lean — if a section does not change agent behavior, cut it
6. Use examples to clarify patterns that are hard to describe abstractly — one excellent example beats many mediocre ones

## Rewrite Rules

### Preserve

- YAML frontmatter — update `description` if needed, but keep the `name`
- Rename `tools` to `allowed-tools` if present (the correct frontmatter field)
- All core logic and rules — rewrite style and structure, not behavior
- Domain-specific terminology and technical accuracy
- File references (paths to scripts, references, assets)

### Transform

- Replace heavy-handed MUSTs and ALWAYS with reasoning — explain why the rule exists so the agent can generalize to edge cases
- Flatten deep header nesting (H4+) — use bold text, lists, or additional H3s instead
- Remove filler words: "please note that", "it is important to", "make sure to"
- Convert passive voice and second person to imperative: "should be checked" → "check", "You should read" → "Read"
- Reduce bold overuse — bold only the key term or phrase the agent must not miss
- Reserve backticks for code, commands, and filenames — not for emphasis
- Merge small sections (1-2 sentences under a header) into their parent

### Before/After Examples

**Heavy directive to reasoning-based:**
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

1. Read the SKILL.md and understand its purpose before changing anything
2. Assess the three review dimensions (description, structure, style) and note issues
3. Rewrite the file applying fixes — style, structure, and description quality; do not alter the skill's core logic or capabilities
4. Write the result back to the same path
5. Report what changed: the review findings per dimension and the major transformations applied

## Constraints

- Do not change the skill's behavior or rules — only the writing style, structure, and description
- Do not add new features or remove existing capabilities
- If unsure whether a change alters behavior, keep the original wording
- Write the rewritten file directly — the output is the file, not a suggestion
