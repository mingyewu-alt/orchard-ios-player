$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$player = Get-Content -Raw -Encoding UTF8 (Join-Path $root 'Sources\PlayerView.swift')
$app = Get-Content -Raw -Encoding UTF8 (Join-Path $root 'Sources\OrchardPlayerApp.swift')
$plist = Get-Content -Raw -Encoding UTF8 (Join-Path $root 'Resources\Info.plist')

$checks = @(
    @{ Name = 'Web view has a UI delegate'; Pass = $player -match 'webView\.uiDelegate\s*=\s*context\.coordinator' },
    @{ Name = 'New-window links load in the existing player'; Pass = $player -match 'createWebViewWith configuration' },
    @{ Name = 'Web media state is tracked'; Pass = $player -match '__orchardPlayback' },
    @{ Name = 'Background transition asks active media to continue'; Pass = $player -match 'prepareForBackgroundPlayback' },
    @{ Name = 'Playback audio session is configured'; Pass = $app -match 'setCategory\(\s*\.playback' },
    @{ Name = 'Audio background mode is declared'; Pass = $plist -match '<string>audio</string>' }
)

$failed = $checks | Where-Object { -not $_.Pass }
$checks | ForEach-Object {
    $status = if ($_.Pass) { 'PASS' } else { 'FAIL' }
    Write-Output "[$status] $($_.Name)"
}

if ($failed.Count -gt 0) { exit 1 }
