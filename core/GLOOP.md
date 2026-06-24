# Gloop Core Contract

Gloop is pronounced "gloop", rhyming with "scoop". It is a goal-plus-loop workflow that can be carried across agent harnesses that understand Markdown instructions, slash commands, skills, workflows, rules, or repo guidance files.

## Contract

A usable Gloop has these fields:

- Goal: the concrete deliverable to build, fix, research, or change.
- Done gate: the commands, tests, builds, smoke checks, or exact observable behavior that prove the goal is complete.
- Loop objective: the repeated improvement target after the done gate passes.
- Verification: the command or check that must pass after the goal and after each loop iteration.
- Loop mode: ask, auto N, or auto until stop-file.
- Stop rule: the condition that ends the loop.
- Safety boundaries: files, commands, services, costs, credentials, and behavior that are off limits.

## Bare Invocation

If Gloop is invoked without a usable contract, do not start work. Display this prompt:

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

Then give one practical example for the current context if enough information is visible.

## Execution

1. Parse the request into the Gloop contract.
2. State the contract before making changes when the work is non-trivial.
3. Complete the goal phase and run the done gate.
4. Only start the loop after the done gate passes.
5. Record handoff state in `.gloop/` when useful:
   - `.gloop/goal.md`
   - `.gloop/loop.md`
   - `.gloop/verify.sh`
   - `.gloop/notes.md`
   - `.gloop/STOP`
6. During each loop iteration, choose one defensible improvement, make the change, run verification, and report whether another iteration is justified.
7. Stop on the first stop rule hit.

## Loop Discipline

- Default to ask-before-continuing unless the user explicitly requests bounded auto mode.
- Auto mode must include a max iteration count, time budget, stop file, no-action marker, or external stop control.
- Translate "absolute ceiling" into measurable criteria such as "continue while benchmark X improves and verification Y passes".
- For performance work, capture a baseline before optimizing.
- Do not treat model confidence as verification.
- Stop and report `GLOOP_NO_ACTION` when no defensible next improvement remains.

