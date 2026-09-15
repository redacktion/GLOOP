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

## Native-State Profile (Opt-In)

Use this contract-only profile when the request or host adapter explicitly selects it and the host already owns task state, verification receipts, budgets, and approvals. It adds no runner, resume wrapper, provider routing, or storage. It does not grant permission to execute commands or change files.

Bind the contract to the existing host task instead of copying it:

| Contract requirement | Existing host state |
| --- | --- |
| Goal, done gate, loop objective | Plan/task identifiers and their acceptance criteria |
| Verification | Check definitions and receipts tied to the current work |
| Loop mode, finite budget, stop rule | Execution authorization, remaining iteration/time budget, and stop conditions |
| Safety boundaries | Explicit nonempty scope and approval constraints |

Resolve these bindings before starting. Reuse known fields and ask only for missing or ambiguous information, rather than displaying the full bare-invocation prompt again. An unresolved task or receipt reference is not a usable binding. A prior receipt counts only if it still verifies the current work.

This profile replaces optional `.gloop/` handoff files with the host's existing task and receipt state. Do not create `.gloop/` files, duplicate contracts or counters, or a second resume mechanism. If the host cannot retain the required state, stop rather than silently falling back to a separate store.

### Compatibility and Budget

Select the profile in request/adapter prose, not by adding a JSON property or `loop_mode` value. The base schema remains unchanged: `safety_boundaries` is optional there, but explicit nonempty safety boundaries are required for this profile. Existing base contracts remain valid without selecting it.

Require a finite host-owned budget before work, including in ask mode. For bounded auto refinement, the existing `loop_mode` object with `type: auto` and `max_iterations` can supply the iteration cap; any deadline remains in host state. A stop file or external stop control alone is not a finite budget. A cap is not authorization: default to ask before each iteration unless the operator explicitly authorizes bounded auto mode. An exhausted or zero remaining budget permits no next iteration, even though a newly declared schema `max_iterations` must be at least one.

### Execution and Stops

1. Before goal work or any refinement iteration, check authorization, remaining budget, and all stop rules. Complete the goal and prove the done gate before refinement. A failed gate records failure, not completion, and stops the loop.
2. Choose at most one defensible improvement per iteration within the existing scope and loop objective.
3. Make that improvement, run verification, and update budget consumption, results, and observed gain in the same native task/receipt. Model confidence is not evidence.
4. Stop on failed verification, exhausted budget, no gain, no defensible action, or an operator stop. Record `GLOOP_NO_ACTION` in the native outcome when no useful action remains. An effect needing approval pauses without executing it; neither a passing gate nor auto mode bypasses approval.
5. Preserve failure, pause, and approval evidence on handoff or resume. Resume does not silently reset the budget, widen scope, switch providers, or authorize further effects. Recheck the retained state before continuing.

These are adapter requirements, not runtime enforcement supplied by this document. Before claiming host conformance, verify that an incomplete goal cannot enter refinement, failed gates retain failure, zero/exhausted budgets prevent another iteration, no-action stops are recorded, and approval-required effects pause without execution.
