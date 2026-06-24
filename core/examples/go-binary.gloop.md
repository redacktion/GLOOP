# Example Gloop: Go Binary

Goal:
Build a Go binary that exposes `mytool --version` and `mytool run <input>`.

Done gate:
`go test ./...`, `go vet ./...`, `go build -o bin/mytool ./cmd/mytool`, and `./bin/mytool --version` all pass.

Loop objective:
Clean up and optimize the repository after the binary works. Prefer correctness, simpler structure, faster hot paths backed by benchmarks, clearer errors, and useful tests.

Verification:
Run `go test ./...`, `go vet ./...`, and `go build -o bin/mytool ./cmd/mytool` after the goal and after each loop iteration.

Loop mode:
auto 5

Stop rule:
Stop after five iterations, if `.gloop/STOP` exists, if verification fails, or if an iteration has no defensible improvement and reports `GLOOP_NO_ACTION`.

Safety boundaries:
Do not change public CLI flags unless the goal explicitly requires it. Do not add network calls, telemetry, or new services.

