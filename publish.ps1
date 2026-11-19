# (C) HexCap publisher - copies the NEWEST "(C) HexCap vX.Y (...).html" from the vault
# to index.html in this repo and pushes it to GitHub Pages.
# Live game: https://sweets93.github.io/hexcap/
param([Parameter(Mandatory = $true)][string]$Source)

$ErrorActionPreference = 'Stop'
$git  = 'C:\Program Files\Git\cmd\git.exe'
$repo = $PSScriptRoot

$builds = Get-ChildItem -LiteralPath $Source -File | Where-Object { $_.Name -match '^\(C\) HexCap v(\d+)\.(\d+).*\.html$' } |
    ForEach-Object { [pscustomobject]@{ File = $_; Ver = [version]("{0}.{1}" -f $Matches[1], $Matches[2]) } } |
    Sort-Object Ver -Descending
if (-not $builds) { Write-Host "No HexCap builds found in $Source"; exit 1 }
$latest = $builds[0].File

Write-Host ""
Write-Host "  Publishing: $($latest.Name)" -ForegroundColor Cyan
Copy-Item -LiteralPath $latest.FullName -Destination (Join-Path $repo 'index.html') -Force

Set-Location $repo
& $git add -A
& $git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Already live - nothing changed since the last publish." -ForegroundColor Yellow
} else {
    & $git commit -q -m ("Publish " + $latest.BaseName.Replace('(C) ', ''))
    & $git push -q
    if ($LASTEXITCODE -ne 0) { Write-Host "  Push failed. Is this PC still signed in to GitHub? (gh auth status)" -ForegroundColor Red; exit 1 }
    Write-Host "  Pushed. GitHub takes about a minute to update the site." -ForegroundColor Green
}
Write-Host ""
Write-Host "  Play / share:  https://sweets93.github.io/hexcap/" -ForegroundColor Cyan
Write-Host "  (On the phone: if you still see the old version, close the tab and reopen.)"
Write-Host ""
