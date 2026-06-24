---
name: gloop
description: Orchestrate a verified goal followed by a repeated cleanup, optimization, or hardening loop. Use when the user asks to chain goal completion into follow-up iterations, create a goal-plus-loop workflow, continue with codex exec resume, optimize until stopped, or build then polish a repository with explicit verification gates.
---

# Gloop

## Overview

Use Gloop to split an open-ended request into two phases:

1. Goal: deliver the concrete thing the user asked for and prove the done gate.
2. Loop: repeat bounded improvement iterations against the same work until a stop rule fires.

Gloop is an orchestration pattern. Use `$gloop` for direct skill invocation when the host supports skills, `/prompts:gloop` as a portable Codex prompt fallback, or the bundled shell runner for `codex exec` plus `codex exec resume`.

## Bare Invocation

If the user invokes Gloop without a goal or usable arguments, do not start work. Display a concise Gloop design prompt:

```text
Design a Gloop by filling in these fields:

Goal:
What should be built, fixed, researched, or changed?

Done gate:
What proves the goal is finished? Prefer commands, tests, builds, smoke checks, or exact observable behavior.

Loop objective:
After the goal passes, what should each iteration improve? Examples: cleanup, optimization, tests, reliability, profiling, docs, security review.

Verification:
What command or check must pass after the goal and after each loop iteration?

Loop mode:
- ask: ask before each iteration
- auto N: run up to N iterations
- auto until stop-file: continue until .gloop/STOP exists, verification fails, or no useful work remains

Stop rule:
When should the loop stop? Examples: user says stop, max iterations, no measurable gain, no defensible improvement, benchmark target reached.

Safety boundaries:
What files, commands, services, or behavior are off limits?
```

Then provide one practical example for the current context if enough information is visible. Do not infer a long-running auto loop from a bare invocation.

## Intake

Extract or define these fields before starting:

- Goal: the concrete deliverable.
- Done gate: commands or observations that prove the goal is complete.
- Loop objective: the repeated improvement target after the goal is complete.
- Loop budget: max iterations, time budget, or ask-before-continuing.
- Stop rule: user stop, `.gloop/STOP`, no defensible improvement, no measurable gain after N attempts, failing verification, or explicit max iterations.
- Safety boundary: files, commands, benchmarks, and changes that are out of scope.

If the user says "absolute ceiling" or similar, translate it into a testable budget. Prefer "continue while benchmark X improves and verification Y passes" over unbounded optimization.

## Workflow

1. State the parsed Gloop contract:
   - Goal
   - Done gate
   - Loop objective
   - Stop rule
   - Verification commands

2. Execute the goal phase:
   - Make the requested changes.
   - Run the done-gate verification.
   - Do not start the loop until the gate passes.

3. Record handoff state when useful:
   - `.gloop/goal.md` for the original goal.
   - `.gloop/loop.md` for the loop prompt.
   - `.gloop/verify.sh` for verification.
   - `.gloop/notes.md` for decisions, baselines, and benchmark results.
   - `.gloop/STOP` as a manual stop file.

4. Execute loop iterations:
   - Inspect the current repository state and previous notes.
   - Choose one defensible improvement per iteration.
   - Prefer measurable performance, correctness, simplification, or safety gains.
   - Avoid churn, broad rewrites, formatting-only noise, and speculative changes.
   - Run the verification gate after each iteration.
   - Stop if no defensible improvement remains and say `GLOOP_NO_ACTION`.

5. Report each iteration with:
   - What changed
   - Why it was worth doing
   - Verification run
   - Whether another iteration is justified

## Operating Modes

Use the mode that fits the surface:

- Interactive Codex: Codex does not have a native `/loop` command. Use `$gloop` when skills are available, `/prompts:gloop` as the prompt fallback, or perform the goal and one loop iteration at a time before asking whether to continue.
- Codex slash command fallback: install `adapters/codex/prompts/gloop.md` as `~/.codex/prompts/gloop.md`, restart Codex, then invoke `/prompts:gloop`.
- Codex shell orchestration: use `scripts/gloop-codex-exec.sh` when the user wants `codex exec` followed by repeated `codex exec resume` iterations.
- Claude Code: this same workflow can be installed as `/gloop`. If using Claude's native `/loop`, treat it as a host feature and keep this Gloop contract as the loop prompt.

## Codex Exec Runner

The bundled `scripts/gloop-codex-exec.sh` runs the shell-driven version:

```bash
scripts/gloop-codex-exec.sh \
  --goal-file .gloop/goal.md \
  --loop-file .gloop/loop.md \
  --verify './.gloop/verify.sh' \
  --max-iterations 5
```

Default to ask-before-continuing unless the user explicitly requests auto mode. For auto mode, still require a max iteration count, time budget, stop file, or clear no-action marker.

## Prompt Template

Use this structure when the user gives an informal request:

```text
GLOOP
Goal:
<deliverable>

Done gate:
<commands or observations that prove the goal is complete>

Loop objective:
<cleanup, optimization, benchmark, hardening, or review target>

Stop rule:
<ask each iteration, stop file, max iterations, no measurable gain, or explicit user stop>

Verification:
<commands to run after goal and after each loop iteration>
```

Auto-mode language should be explicit:

```text
Loop mode: auto 5
Stop rule: stop after 5 iterations, if verification fails, if .gloop/STOP exists, or if an iteration ends with GLOOP_NO_ACTION.
```

## Guardrails

- Do not treat model confidence as verification; run the gate.
- Do not start an unbounded loop without an external stop control.
- Do not optimize without a baseline when the user expects performance gains.
- Do not keep changing code after repeated no-op or negligible-gain iterations.
- Preserve user changes and avoid unrelated refactors.
