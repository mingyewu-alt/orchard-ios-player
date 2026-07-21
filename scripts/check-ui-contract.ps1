$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$plistPath = Join-Path $projectRoot 'Resources\Info.plist'
$projectPath = Join-Path $projectRoot 'project.yml'
$launchPath = Join-Path $projectRoot 'Resources\LaunchScreen.storyboard'
$playerPath = Join-Path $projectRoot 'Sources\PlayerView.swift'
$blockerPath = Join-Path $projectRoot 'Sources\ContentBlocker.swift'
$iconPath = Join-Path $projectRoot 'Resources\Assets.xcassets\AppIcon.appiconset\AppIcon-1024.png'

$plist = Get-Content -Raw -Encoding UTF8 $plistPath
$project = Get-Content -Raw -Encoding UTF8 $projectPath
$player = Get-Content -Raw -Encoding UTF8 $playerPath
$blocker = Get-Content -Raw -Encoding UTF8 $blockerPath

$checks = @(
    @{ Name = 'Launch storyboard is declared'; Pass = $plist -match '<key>UILaunchStoryboardName</key>' },
    @{ Name = 'Xcode uses checked-in Info.plist'; Pass = $project -match 'INFOPLIST_FILE: Resources/Info\.plist' },
    @{ Name = 'Launch storyboard exists'; Pass = Test-Path -LiteralPath $launchPath },
    @{ Name = 'Shield has a toggle action'; Pass = $player -match 'model\.toggleBlocker\(\)' },
    @{ Name = 'Blocker can be disabled'; Pass = $blocker -match 'static func remove\(' },
    @{ Name = 'App icon exists'; Pass = Test-Path -LiteralPath $iconPath }
)

$failed = $checks | Where-Object { -not $_.Pass }
$checks | ForEach-Object {
    $status = if ($_.Pass) { 'PASS' } else { 'FAIL' }
    Write-Output "[$status] $($_.Name)"
}

if ($failed.Count -gt 0) {
    exit 1
}
