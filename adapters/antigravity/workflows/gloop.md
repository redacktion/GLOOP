# Gloop

Use this workflow when a request needs a concrete verified goal followed by bounded improvement iterations.

## Input

Accept a Gloop contract with:

- Goal
- Done gate
- Loop objective
- Verification
- Loop mode
- Stop rule
- Safety boundaries

If any required field is missing, display the bare design prompt from `core/GLOOP.md` and ask the user to fill it in.

## Steps

1. Parse and restate the contract.
2. Complete the goal phase.
3. Run the done gate exactly as specified.
4. Start loop iterations only after the done gate passes.
5. For each iteration, make one defensible cleanup, optimization, hardening, test, documentation, or reliability improvement.
6. Run verification after each iteration.
7. Stop on the first stop rule hit and report the final state.

