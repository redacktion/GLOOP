---
description: Gloop: run a verified goal followed by a bounded improvement loop
argument-hint: GOAL_AND_LOOP_SPEC
---

Use the Gloop workflow for this request.

Invocation arguments:
$ARGUMENTS

If the invocation arguments are empty or do not describe a usable goal, do not start work. Instead, display this helpful design prompt:

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

Parse the request into:

1. Goal
2. Done gate
3. Loop objective
4. Stop rule
5. Verification commands

Then execute in two phases:

1. Complete the goal and prove the done gate with real verification.
2. After the gate passes, perform one bounded loop iteration at a time.

For each loop iteration:

- Inspect the current repository state.
- Make at most one coherent cleanup, optimization, hardening, or correctness improvement.
- Preserve behavior unless explicitly asked otherwise.
- Prefer measurable wins over churn.
- Run verification after changes.
- Stop if no defensible improvement remains and say `GLOOP_NO_ACTION`.

Codex does not have a native `/loop` slash command. This prompt is the portable fallback invoked as `/prompts:gloop`. If the user asks for unattended shell looping, propose or create a runner that uses `codex exec --json` to capture the thread id and `codex exec resume <thread_id> <prompt>` for later iterations.
