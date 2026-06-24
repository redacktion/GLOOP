# Gloop

Gloop (rhymes with "scoop") is a goal-plus-loop workflow for your model of choice, as long as it can ingest Markdown instructions, skills, rules, workflows, or slash-command prompts. The idea is simple: define a goal, prove the done gate, then iterate on cleanup, optimization, hardening, tests, docs, or whatever else you want looped until a stop rule fires.

This repo packages Gloop as a portable core contract plus harness-specific adapters for Codex, Claude Code, Factory/Droid, Antigravity, Cursor, Hermes, Augment/Auggie, GitHub Copilot/VS Code, Windsurf/Cascade, and generic `AGENTS.md` consumers.

## Layout

- `core/GLOOP.md` - canonical tool-neutral workflow.
- `core/contract.schema.json` - structured Gloop contract schema.
- `core/examples/` - reusable contract examples.
- `skills/gloop/` - canonical Agent Skills-compatible skill.
- `adapters/` - per-harness packaging.
- `scripts/install.sh` - multi-target installer.

## Install

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

## Targets

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
