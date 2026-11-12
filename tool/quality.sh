#!/usr/bin/env bash
set -euo pipefail

echo "== Flutter/Dart environment =="
flutter --version
dart --version

echo "== Dependency resolution =="
flutter pub get

echo "== Formatting =="
dart format --output=none --set-exit-if-changed .

echo "== Static analysis =="
flutter analyze

echo "== Tests =="
flutter test

# Git whitespace check: skipped when the directory is not a git repository
# (git init deferred by human decision on 2026-11-11; recorded in
# docs/IMPLEMENTATION_PROGRESS.md). The skip is reported, never hidden.
echo "== Git whitespace check =="
git_check_skipped=0
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git diff --check
else
    echo "SKIP: no .git directory — repository not initialized (decision recorded in docs/IMPLEMENTATION_PROGRESS.md)"
    git_check_skipped=1
fi

if [ "$git_check_skipped" -eq 1 ]; then
    echo "QUALITY GATES: PASS (skipped: git whitespace check — not a git repository)"
else
    echo "QUALITY GATES: PASS"
fi
