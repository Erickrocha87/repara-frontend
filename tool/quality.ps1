$ErrorActionPreference = "Stop"

function Invoke-Check {
    param([string]$Label, [scriptblock]$Command)
    Write-Host "`n== $Label ==" -ForegroundColor Cyan
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "$Label failed with exit code $LASTEXITCODE"
    }
}

Invoke-Check "Flutter version" { flutter --version }
Invoke-Check "Dart version" { dart --version }
Invoke-Check "Dependency resolution" { flutter pub get }
Invoke-Check "Formatting" { dart format --output=none --set-exit-if-changed . }
Invoke-Check "Static analysis" { flutter analyze }
Invoke-Check "Tests" { flutter test }

# Git whitespace check: skipped when the directory is not a git repository
# (git init deferred by human decision on 2026-11-11; recorded in
# docs/IMPLEMENTATION_PROGRESS.md). The skip is reported, never hidden.
$gitCheckSkipped = $false
if (Test-Path -Path ".git") {
    Invoke-Check "Git whitespace check" { git diff --check }
} else {
    Write-Host "`n== Git whitespace check ==" -ForegroundColor Cyan
    Write-Host "SKIP: no .git directory - repository not initialized (decision recorded in docs/IMPLEMENTATION_PROGRESS.md)" -ForegroundColor Yellow
    $gitCheckSkipped = $true
}

if ($gitCheckSkipped) {
    Write-Host "`nQUALITY GATES: PASS (skipped: git whitespace check - not a git repository)" -ForegroundColor Green
} else {
    Write-Host "`nQUALITY GATES: PASS" -ForegroundColor Green
}
