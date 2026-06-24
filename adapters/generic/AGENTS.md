# Gloop Agent Instructions

Use the Gloop workflow when the user explicitly asks for a verified goal followed by cleanup, optimization, hardening, verification, or repeated improvement iterations.

Read `core/GLOOP.md` when present. A valid Gloop needs:

- Goal
- Done gate
- Loop objective
- Verification
- Loop mode
- Stop rule
- Safety boundaries

If the request is missing a usable contract, ask for the missing fields. Do not start an unbounded loop. Finish the goal and prove the done gate before starting loop iterations. Run verification after each iteration and stop on the first stop rule hit.

