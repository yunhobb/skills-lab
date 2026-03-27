# Agent Convention Reference

Detailed conventions for Claude Code agent definition files. Read this before evaluating or rewriting an agent.

## Frontmatter Fields

### Required Fields

| Field | Rule | Why |
|-------|------|-----|
| `name` | Lowercase + hyphens only, 3-50 chars, start/end with alphanumeric | Claude uses the name for namespacing and CLI invocation — special characters break resolution |
| `description` | Trigger-condition style with `<example>` blocks | Claude matches user intent against the description to decide whether to delegate — vague descriptions cause missed triggers |
| `model` | `inherit` (default), `sonnet`, `opus`, or `haiku` | Model choice affects cost and capability — `haiku` for quick lookups, `sonnet` for standard work, `opus` for deep analysis |
| `color` | One of: `blue`, `cyan`, `green`, `yellow`, `magenta`, `red` | Visual distinction in the UI helps users track which agent is running |

**Color conventions:**
- Blue/Cyan: analysis, review
- Green: success-oriented tasks
- Yellow: validation, caution
- Red: security, critical operations
- Magenta: generation, creative work

### Optional Fields

| Field | Rule | Why |
|-------|------|-----|
| `tools` | Array of tool names | Unnecessary tools distract the agent and increase risk of unintended side effects — grant only what's needed |
| `maxTurns` | Integer | Prevents runaway agents on tasks with predictable scope |
| `memory` | `user`, `project`, or `local` | Matches knowledge lifetime to appropriate persistence scope |
| `background` | `true` / `false` | Only for independent, non-blocking work — blocking tasks need foreground to report results |

**Common tool sets:**
- Read-only analysis: `["Read", "Grep", "Glob"]`
- Code generation: `["Read", "Write", "Edit", "Grep"]`
- Testing: `["Read", "Bash", "Grep"]`
- Full access: omit the field

## Description Quality

The description is the most critical field — it controls when Claude delegates to the agent.

### Required Elements

1. Trigger condition starting with "Use this agent when..."
2. 2-4 `<example>` blocks showing realistic scenarios — Claude matches user intent against these, so variety directly improves trigger accuracy
3. Each example includes `Context:`, `user:`, `assistant:`, and `<commentary>`
4. Both proactive ("Use proactively after...") and reactive ("Use when user asks...") triggering
5. When NOT to use the agent, if there are common confusion points with other agents

### Good vs Bad Patterns

**Good — trigger-condition style:**
```
Use this agent when the user needs security analysis of code changes. Examples:

<example>
Context: User just pushed new authentication code
user: "Can you check this auth flow for vulnerabilities?"
assistant: "I'll use the security-analyzer agent to review the authentication implementation."
<commentary>
Explicit security review request triggers this agent.
</commentary>
</example>
```

**Bad — workflow summary:**
```
An agent that analyzes code for security issues by scanning files and generating reports.
```

The bad pattern describes internal workflow instead of trigger conditions. Claude cannot reliably match this to user intent — it needs to know what the user *says*, not what the agent *does internally*.

## System Prompt (Body)

### Structure Principles

Structure the system prompt so the agent knows: what it is, what to do, how to do it, and what good output looks like. The exact sections vary by complexity:

- **Simple agent:** role + process + output format
- **Standard agent:** role + responsibilities + process + output format
- **Complex agent:** role + responsibilities + process + quality standards + output format + edge cases

Scale sections to their weight — a two-sentence section doesn't need its own header.

### Writing Style

| Pattern | Example |
|---------|---------|
| Imperative form | "Read the file", "Analyze the diff" |
| Reason-based rules | "Use lowercase — the official project doesn't capitalize it outside of logos" |
| Direct tone | Like explaining to a capable colleague |
| Selective bold | Only key terms the agent must not miss |
| Backticks for code only | Commands, filenames, tool names |
| Flat headers (`##`, `###`) | Deep nesting (H4+) causes agents to lose track of section context |

**Avoid:**
- Second person: "You should read..." → "Read..."
- Heavy-handed MUSTs: "MUST ALWAYS validate" → explain why validation matters
- Filler: "please note that", "it is important to", "make sure to"
- Passive voice: "should be checked" → "check"

### Before/After Examples

**Monolithic to structured:**

```
BEFORE:
You are a code reviewer. You review code for bugs and style issues.
You should always check for security vulnerabilities. Make sure to
provide clear feedback. Please note that you must format output as
a list.

AFTER:
You are a code reviewer specializing in quality and security.

**Process:**
1. Read the changed files via git diff
2. Check for logic errors and security vulnerabilities
3. Evaluate naming and style consistency

**Output:** Organize findings by severity — critical issues first,
then warnings, then suggestions. Skip categories with no findings.
```

**Heavy MUST to reasoning:**

```
BEFORE:
You MUST ALWAYS run tests before suggesting any changes. NEVER skip
this step.

AFTER:
Run existing tests before suggesting changes — untested suggestions
risk breaking working code, and the test output often reveals the
actual root cause.
```

**Vague to specific:**

```
BEFORE:
Handle edge cases appropriately.

AFTER:
When the input file has no frontmatter, add all required fields with
sensible defaults. When frontmatter exists but is incomplete, add only
the missing fields — preserve existing values.
```
