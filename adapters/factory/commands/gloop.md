---
description: Run a verified goal followed by a bounded improvement loop
argument-hint: GOAL_AND_LOOP_SPEC
---

Use the Gloop workflow for this request.

Invocation arguments:
$ARGUMENTS

If the arguments are empty or do not describe a usable goal, show the bare Gloop design prompt from `core/GLOOP.md` and stop.

Otherwise:

1. Parse the arguments into Goal, Done gate, Loop objective, Verification, Loop mode, Stop rule, and Safety boundaries.
2. Complete the goal and prove the done gate.
3. After the done gate passes, run bounded loop iterations according to the loop mode.
4. Stop on verification failure, `.gloop/STOP`, max iterations, user stop, or `GLOOP_NO_ACTION`.

Default to ask-before-continuing unless the user explicitly requests bounded auto mode.

