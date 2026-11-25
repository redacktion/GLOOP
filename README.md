# Gloop

Gloop (rhymes with "scoop") is a goal-plus-loop workflow for your model of choice, as long as it can ingest Markdown instructions, skills, rules, workflows, or slash-command prompts.

The idea is simple: define a goal, prove the done gate, then iterate on cleanup, optimization, hardening, tests, docs, or whatever else you want looped until a stop rule fires. While you can include this language in a Goal, by abstracting out the iteration portion, this approach provides greater control to iterative improvements and scopes iteration over a given objective.

Example:

```text
Goal:
Build a small CLI that validates a JSON file and prints a normalized copy.

Done gate:
The CLI builds, unit tests pass, and `json-normalize sample.json` prints stable formatted JSON.

Loop objective:
Improve error messages, edge-case coverage, and command help text.

Verification:
Run the test suite and a smoke invocation after every iteration.

Loop mode:
auto 3

Stop rule:
Stop after three iterations, if verification fails, or if no defensible improvement remains.
```

Execution flow:

```text
      STATE / HANDOFF             CORE WORKFLOW                EXIT PATHS

                              +----------------------+
                              |     User request     |
                              +----------+-----------+
                                         |
                                         v
+----------------------+      +----------+-----------+        +----------------------+
| Optional state files |<-----| Gloop contract       |------->| Missing contract     |
|----------------------|      |----------------------|        |----------------------|
| .gloop/goal.md       |      | Goal                 |        | Show the design      |
| .gloop/loop.md       |      | Done gate            |        | prompt and stop.     |
| .gloop/verify.sh     |      | Loop objective       |        +----------------------+
| .gloop/notes.md      |      | Verification         |
| .gloop/STOP          |      | Loop mode            |
+----------------------+      | Stop rule            |
                              +----------+-----------+
                                         |
                                         v
                              +----------+-----------+
                              | Goal phase           |
                              |----------------------|
                              | Build, fix, research,|
                              | or change the thing. |
                              +----------+-----------+
                                         |
                                         v
                              +----------+-----------+        +----------------------+
                              | Done gate            |        | Gate failed          |
                              |----------------------|        |----------------------|
                              | Run the build, test, |--fail->| Report blocker;      |
                              | or smoke check.      |        | do not loop.         |
                              +----------+-----------+        +----------------------+
                                         | pass
                                         v
+----------------------+      +----------------------+<------ loop back -------------.
| Baseline findings &  |      |    Loop Iteration    |        +----------------------|
| notes                |<-----|       N times        |------->| No useful change?    |
|----------------------|      |----------------------|        |----------------------|
| Metrics              |      | Make one defensible  |        | Report               |
| Decisions            |      | improvement.         |        | GLOOP_NO_ACTION.     |
| Follow-up risks      |      +----------+-----------+        +----------------------+
+----------------------+                 |                                           |
                                         v                                           |
                              +----------+-----------+        +----------------------+
                              | Verification         |        | Verification failed  |
                              |----------------------|        |----------------------|
                              | Run the configured   |--fail->| Report failure and   |
                              | check every time.    |        | preserve context.    |
                              +----------+-----------+        +----------------------+
                                         | pass                                      |
                                         v                                           |
                              +----------+-----------+        +----------------------+
                              | Stop rule            |        | Stop rule hit        |
                              |----------------------|        |----------------------|
                              | User stop, max iter, |--yes-->| Final report with    |
                              | stop file, no gain.  |        | verification notes.  |
                              +----------+-----------+        +----------------------|
                                         |                                           |
                                         |                                           |
                                         '--------- loop back -----------------------^
```

This repo packages Gloop as a portable core contract plus harness-specific adapters for Codex, Claude Code, Factory/Droid, Antigravity, Cursor, Hermes, Augment/Auggie, GitHub Copilot/VS Code, Windsurf/Cascade, and generic `AGENTS.md` consumers.

## Layout

- `core/GLOOP.md` - canonical tool-neutral workflow.
- `core/contract.schema.json` - structured Gloop contract schema.
- `core/examples/` - reusable contract examples.
- `skills/gloop/` - canonical Agent Skills-compatible skill.
- `adapters/` - per-harness packaging.
- `scripts/install.sh` - multi-target installer.

## Install

### Model/Harness-Assisted Installation

To try Gloop on one task without installing anything, fill in the [portable contract](#usage) and give it to your model with the [workflow instructions](core/GLOOP.md).

If you want the adapter available for future tasks, use this install prompt:

```text
Install Gloop from this repository for the current harness.

Repository:
https://github.com/redacktion/GLOOP

Requirements:
- Inspect the README and scripts/install.sh.
- Choose the narrowest matching install target.
- List the destinations before installing. For example, --target cursor --project DIR writes to both the Cursor user directory and DIR/.cursor.
- Ask before replacing existing user files or skill directories.
- Do not patch official app binaries, vendor bundles, or upstream source distributions.
- Verify the installed files are discoverable by the harness.
```

### Manual Installation

Default user-level install:

```bash
./scripts/install.sh
```

Install specific harnesses:

```bash
./scripts/install.sh --target factory --target cursor --target hermes
```

Install everything, including project-scoped adapters:

```bash
./scripts/install.sh --target all --project /path/to/repo
```

Project-scoped files are installed conservatively. If a target file already exists and differs, the installer preserves it and writes a `.gloop-new` sibling.

### Targets

| Target | Installs |
| --- | --- |
| `agent-skill` | `~/.agents/skills/gloop` |
| `codex` | Agent skill and `~/.codex/prompts/gloop.md` |
| `claude` | `~/.claude/commands/gloop.md` and `~/.claude/skills/gloop` |
| `factory` | `~/.factory/skills/gloop`, `~/.factory/commands/gloop.md`, and `~/.factory/droids/gloop-runner.md` |
| `antigravity` | `~/.gemini/config/skills/gloop`, `~/.gemini/antigravity-cli/skills/gloop`, and project `.agents` files when `--project` is set |
| `cursor` | `~/.cursor/skills/gloop`, `~/.cursor/agents/gloop-verifier.md`, and project `.cursor` files when `--project` is set |
| `hermes` | `~/.hermes/skills/gloop` |
| `augment` | `~/.augment/skills/gloop` |
| `gemini` | `~/.gemini/skills/gloop` compatibility files |
| `copilot` | Project `.github/copilot-instructions.md` and `.github/instructions/gloop.instructions.md` |
| `windsurf` | Global and project Windsurf workflow files |
| `generic` | Project `AGENTS.md` adapter |

## Usage

Portable contract:

```text
GLOOP
Goal:
Done gate:
Loop objective:
Verification:
Loop mode:
Stop rule:
Safety boundaries:
```

Codex prompt fallback:

```text
/prompts:gloop Goal: ... Done gate: ... Loop objective: ...
```

Claude Code, Factory, Hermes, Windsurf, and other slash-capable harnesses:

```text
/gloop Goal: ... Done gate: ... Loop objective: ...
```

Shell runner:

```bash
skills/gloop/scripts/gloop-codex-exec.sh \
  --goal-file .gloop/goal.md \
  --loop-file .gloop/loop.md \
  --verify './.gloop/verify.sh' \
  --max-iterations 5
```

## Compatibility Notes

See `docs/HARNESS-COMPATIBILITY.md` for the researched install surfaces and source links.
