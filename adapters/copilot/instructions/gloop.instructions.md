---
applyTo: "**"
---

# Gloop

Use this instruction when a user explicitly asks for Gloop, a goal-plus-loop workflow, or a verified goal followed by bounded improvement iterations.

Required contract fields:

- Goal
- Done gate
- Loop objective
- Verification
- Loop mode
- Stop rule
- Safety boundaries

If fields are missing, display a concise prompt asking the user to fill them in. If fields are present, complete the goal first, prove the done gate, then perform bounded loop iterations. Each loop iteration must have one coherent improvement, verification evidence, and a stop-rule check.

