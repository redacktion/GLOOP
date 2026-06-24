# Harness Compatibility

Gloop is packaged around a small core workflow plus harness-specific adapters. The stable artifact is `core/GLOOP.md`; everything in `adapters/` is a thin import shape for a specific tool.

## Researched Surfaces

| Harness | Native surface | Gloop adapter |
| --- | --- | --- |
| Agent Skills-compatible tools | Skill directory containing `SKILL.md` | `adapters/agent-skill/gloop` |
| Codex | Agent skill and prompt fallback | `adapters/codex/` |
| Claude Code | Slash command and skill directory | `adapters/claude/` |
| Factory Droid | Skills, custom slash commands, custom Droids | `adapters/factory/` |
| Antigravity 2.0 | Skills under Gemini/Antigravity locations and workflow-style Markdown | `adapters/antigravity/` |
| Cursor | Agent Skills, `.mdc` rules, optional subagents | `adapters/cursor/` |
| Hermes | Skills under `~/.hermes/skills`, every skill invocable as a slash command | `adapters/hermes/` |
| Augment/Auggie | Agent Skills-compatible directories | `adapters/augment/` |
| GitHub Copilot / VS Code | Repo instructions and `.instructions.md` files | `adapters/copilot/` |
| Windsurf/Cascade | Markdown workflows invoked as slash commands | `adapters/windsurf/` |
| Generic agents | `AGENTS.md` instructions | `adapters/generic/` |

## Source Notes

- Factory documents skills as `SKILL.md` directories and says custom slash commands live in `.factory/commands`; custom Droids live in `.factory/droids/`. Sources: <https://docs.factory.ai/cli/configuration/skills>, <https://docs.factory.ai/cli/configuration/custom-slash-commands>, <https://docs.factory.ai/cli/configuration/custom-droids>
- Antigravity/Gemini documentation describes skills as folders with `SKILL.md`, with global and project install locations including Gemini config and `.agents/skills`. Sources: <https://antigravity.google/docs/skills>, <https://codelabs.developers.google.com/getting-started-with-antigravity-skills>, <https://geminicli.com/docs/cli/skills/>
- Cursor documents Agent Skills in Agent Skills-compatible locations; it also supports `.cursor/rules/*.mdc` and custom agents. Sources: <https://cursor.com/docs/skills>, <https://cursor.com/docs/rules>, <https://cursor.com/docs/subagents>
- Hermes documents Agent Skills compatibility, local skills under `~/.hermes/skills`, and slash invocation for installed skills. Source: <https://hermes-agent.nousresearch.com/docs/user-guide/features/skills>
- Augment/Auggie documents Agent Skills-compatible directories such as `.augment/skills`, `.claude/skills`, and `.agents/skills`. Source: <https://docs.augmentcode.com/cli/skills>
- GitHub Copilot and VS Code document repository instructions in `.github/copilot-instructions.md` and reusable instruction files under `.github/instructions/*.instructions.md`; VS Code also documents Agent Skills support. Sources: <https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot>, <https://code.visualstudio.com/docs/copilot/customization/custom-instructions>, <https://code.visualstudio.com/docs/agent-customization/agent-skills>
- Windsurf/Cascade documents workflows as Markdown files under `.windsurf/workflows` and global workflows under `~/.codeium/windsurf/global_workflows`. Source: <https://docs.devin.ai/desktop/cascade/workflows>

## Adding Another Harness

1. Keep the workflow logic in `core/GLOOP.md` or `skills/gloop/SKILL.md`.
2. Add the smallest possible adapter under `adapters/<harness>/`.
3. Prefer linking or copying the skill directory when the harness supports Agent Skills.
4. Add a target to `scripts/install.sh`.
5. Validate with the harness' native discovery command when available.
