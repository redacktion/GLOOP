# Gloop

Run a verified goal followed by bounded improvement iterations.

## Usage

Invoke as `/gloop` with a contract:

```text
Goal:
Done gate:
Loop objective:
Verification:
Loop mode:
Stop rule:
Safety boundaries:
```

## Workflow

1. If the contract is missing, ask for the required fields.
2. Complete the goal.
3. Run the done gate.
4. Start the loop only after the done gate passes.
5. Make one defensible improvement per loop iteration.
6. Run verification after every iteration.
7. Stop on max iterations, `.gloop/STOP`, user stop, verification failure, no measurable gain, or `GLOOP_NO_ACTION`.

