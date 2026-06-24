#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  gloop-codex-exec.sh --goal-file FILE --loop-file FILE [options]

Options:
  --repo DIR             Repository/workspace directory. Default: current dir.
  --verify CMD           Verification command to run after the goal and each loop.
  --max-iterations N     Stop after N loop iterations. Default: 0, meaning no numeric cap.
  --auto                 Do not ask before each next iteration.
  --sandbox MODE         Codex sandbox mode. Default: workspace-write.
  --state-dir DIR        State directory. Default: .gloop.
  -h, --help             Show this help.

Stop controls:
  - Press Ctrl-C.
  - Create STATE_DIR/STOP.
  - Let Codex finish an iteration with the marker GLOOP_NO_ACTION.

Design a Gloop:
  Goal:
    What should be built, fixed, researched, or changed?
  Done gate:
    What proves the goal is finished? Prefer tests, builds, smoke checks, or exact observable behavior.
  Loop objective:
    What should each iteration improve after the goal passes?
  Verification:
    What command or check must pass after the goal and each iteration?
  Loop mode:
    ask | auto N | auto until stop-file
  Stop rule:
    Stop on user request, max iterations, verification failure, no measurable gain, or GLOOP_NO_ACTION.
  Safety boundaries:
    What files, commands, services, or behavior are off limits?

Example:
  gloop-codex-exec.sh \
    --goal-file .gloop/goal.md \
    --loop-file .gloop/loop.md \
    --verify './.gloop/verify.sh' \
    --max-iterations 5
USAGE
}

repo="."
goal_file=""
loop_file=""
verify_cmd=""
max_iterations=0
ask_each_iteration=1
sandbox="workspace-write"
state_dir=".gloop"

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      repo="$2"
      shift 2
      ;;
    --goal-file)
      goal_file="$2"
      shift 2
      ;;
    --loop-file)
      loop_file="$2"
      shift 2
      ;;
    --verify)
      verify_cmd="$2"
      shift 2
      ;;
    --max-iterations)
      max_iterations="$2"
      shift 2
      ;;
    --auto)
      ask_each_iteration=0
      shift
      ;;
    --sandbox)
      sandbox="$2"
      shift 2
      ;;
    --state-dir)
      state_dir="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$goal_file" || -z "$loop_file" ]]; then
  echo "Both --goal-file and --loop-file are required." >&2
  usage >&2
  exit 2
fi

if ! command -v codex >/dev/null 2>&1; then
  echo "codex CLI is required on PATH." >&2
  exit 127
fi

if ! [[ "$max_iterations" =~ ^[0-9]+$ ]]; then
  echo "--max-iterations must be a non-negative integer." >&2
  exit 2
fi

cd "$repo"
mkdir -p "$state_dir"

goal_path="$(python3 -c 'import os,sys; print(os.path.abspath(sys.argv[1]))' "$goal_file")"
loop_path="$(python3 -c 'import os,sys; print(os.path.abspath(sys.argv[1]))' "$loop_file")"
timestamp="$(date +%Y%m%d-%H%M%S)"
goal_jsonl="$state_dir/goal-$timestamp.jsonl"

echo "[gloop] Starting goal phase"
codex exec -s "$sandbox" --json "$(cat "$goal_path")" | tee "$goal_jsonl"

thread_id="$(
  python3 - "$goal_jsonl" <<'PY'
import json
import sys

thread_id = ""
with open(sys.argv[1], "r", encoding="utf-8") as fh:
    for line in fh:
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if event.get("type") == "thread.started":
            thread_id = event.get("thread_id", "")
print(thread_id)
PY
)"

if [[ -z "$thread_id" ]]; then
  echo "Could not find thread_id in $goal_jsonl." >&2
  exit 1
fi

echo "[gloop] Captured thread: $thread_id"

if [[ -n "$verify_cmd" ]]; then
  echo "[gloop] Verifying goal gate"
  bash -lc "$verify_cmd"
fi

iteration=0
while true; do
  if [[ -f "$state_dir/STOP" ]]; then
    echo "[gloop] Stop file found: $state_dir/STOP"
    break
  fi

  iteration=$((iteration + 1))
  if [[ "$max_iterations" -gt 0 && "$iteration" -gt "$max_iterations" ]]; then
    echo "[gloop] Reached max iterations: $max_iterations"
    break
  fi

  final_message="$state_dir/loop-$iteration.final.txt"
  loop_prompt="$(
    cat <<EOF
GLOOP loop iteration $iteration.

The initial goal phase is complete and verified. Continue in the same repository and same Codex thread.

Loop instructions:
$(cat "$loop_path")

Iteration rules:
- Inspect the current repository state before editing.
- Make at most one coherent improvement this iteration.
- Preserve behavior unless the loop instructions explicitly request a behavior change.
- Prefer measurable performance, correctness, simplification, or safety gains over churn.
- Run or request the configured verification before claiming completion.
- If no defensible improvement remains, do not edit files. End the final response with GLOOP_NO_ACTION.
EOF
  )"

  echo "[gloop] Starting loop iteration $iteration"
  codex exec -s "$sandbox" resume -o "$final_message" "$thread_id" "$loop_prompt"

  if [[ -n "$verify_cmd" ]]; then
    echo "[gloop] Verifying loop iteration $iteration"
    bash -lc "$verify_cmd"
  fi

  if grep -q "GLOOP_NO_ACTION" "$final_message"; then
    echo "[gloop] Codex reported no defensible improvement remains."
    break
  fi

  if [[ "$ask_each_iteration" -eq 1 ]]; then
    printf "[gloop] Continue to next iteration? [y/N] "
    read -r answer </dev/tty || answer=""
    case "$answer" in
      y|Y|yes|YES) ;;
      *) break ;;
    esac
  fi
done

echo "[gloop] Done"
