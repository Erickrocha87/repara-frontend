---
description: Run Flutter quality gates and summarize evidence
agent: orchestrator
---

Run the project's quality gates using `bash tool/quality.sh` or `pwsh -File tool/quality.ps1` depending on the environment. Do not edit code to silence failures. Report each check as PASS, FAIL, or NOT RUN with relevant output. If failures occur, delegate diagnosis to `flutter-engineer`, then rerun the relevant checks and the full suite when practical.
