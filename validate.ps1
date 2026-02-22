<#
.SYNOPSIS
    Validation script for Minimal Dark PowerShell Config installation.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$results = New-Object System.Collections.Generic.List[object]

function Add-Result {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [ValidateSet('PASS', 'WARN', 'FAIL')] [string] $Status,
        [Parameter(Mandatory)] [string] $Details,
        [Parameter(Mandatory)] [string] $Recommendation
    )

    $results.Add([PSCustomObject]@{
        Name           = $Name
        Status         = $Status
        Details        = $Details
        Recommendation = $Recommendation
    }) | Out-Null
}

function Test-ReadableFile {
    param(
        [Parameter(Mandatory)] [string] $Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return @{ Exists = $false; Readable = $false; Error = 'File not found.' }
    }

    try {
        Get-Content -LiteralPath $Path -TotalCount 1 -ErrorAction Stop | Out-Null
        return @{ Exists = $true; Readable = $true; Error = $null }
    }
    catch {
        return @{ Exists = $true; Readable = $false; Error = $_.Exception.Message }
    }
}

function Resolve-TerminalSettingsPath {
    $candidates = @(
        (Join-Path $HOME 'AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json'),
        (Join-Path $HOME 'AppData/Local/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json')
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return $candidate
        }
    }

    return $null
}

function Test-TerminalScheme {
    param(
        [Parameter(Mandatory)] [string] $SettingsPath,
        [Parameter(Mandatory)] [string] $SchemeName
    )

    try {
        $raw = Get-Content -LiteralPath $SettingsPath -Raw -ErrorAction Stop
        $json = $raw | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        return @{ Found = $false; Error = "Could not parse settings.json: $($_.Exception.Message)" }
    }

    $scheme = $json.schemes | Where-Object { $_.name -eq $SchemeName } | Select-Object -First 1
    if ($null -eq $scheme) {
        return @{ Found = $false; Error = "Scheme '$SchemeName' not found." }
    }

    return @{ Found = $true; Error = $null }
}

Write-Host '=== Minimal Dark Validation ===' -ForegroundColor Cyan

# 1) CLI tools
$commands = @('pwsh', 'oh-my-posh', 'zoxide', 'git')
foreach ($cmd in $commands) {
    if (Get-Command $cmd -ErrorAction SilentlyContinue) {
        Add-Result -Name "Command: $cmd" -Status 'PASS' -Details 'Command is available in PATH.' -Recommendation 'No action needed.'
    }
    else {
        Add-Result -Name "Command: $cmd" -Status 'FAIL' -Details 'Command not found in PATH.' -Recommendation "Install '$cmd' and ensure it is available in PATH."
    }
}

# 2) File checks (existence + readability)
$themePath = Join-Path $HOME '.config/oh-my-posh/dark-minimal-theme.json'
$profileIncludePath = $PROFILE.CurrentUserCurrentHost
$terminalSettingsPath = Resolve-TerminalSettingsPath

$fileChecks = @(
    @{ Name = 'Oh My Posh theme'; Path = $themePath; Recommendation = 'Copy ./theme/dark-minimal-theme.json to ~/.config/oh-my-posh/.' },
    @{ Name = 'PowerShell profile include file'; Path = $profileIncludePath; Recommendation = 'Copy ./profile/Microsoft.PowerShell_profile.ps1 to your $PROFILE path.' }
)

foreach ($item in $fileChecks) {
    $state = Test-ReadableFile -Path $item.Path
    if (-not $state.Exists) {
        Add-Result -Name "File: $($item.Name)" -Status 'FAIL' -Details "Missing file: $($item.Path)" -Recommendation $item.Recommendation
    }
    elseif (-not $state.Readable) {
        Add-Result -Name "File: $($item.Name)" -Status 'FAIL' -Details "File exists but is not readable: $($item.Path). Error: $($state.Error)" -Recommendation 'Fix file permissions and verify file encoding/content.'
    }
    else {
        Add-Result -Name "File: $($item.Name)" -Status 'PASS' -Details "File exists and is readable: $($item.Path)" -Recommendation 'No action needed.'
    }
}

if ($null -eq $terminalSettingsPath) {
    Add-Result -Name 'File: Windows Terminal settings.json' -Status 'WARN' -Details 'Windows Terminal settings.json not found (stable/preview paths).' -Recommendation 'Open Windows Terminal at least once or verify the settings path manually.'
}
else {
    $terminalReadable = Test-ReadableFile -Path $terminalSettingsPath
    if (-not $terminalReadable.Readable) {
        Add-Result -Name 'File: Windows Terminal settings.json' -Status 'FAIL' -Details "Found but unreadable: $terminalSettingsPath. Error: $($terminalReadable.Error)" -Recommendation 'Fix file permissions, then re-run validation.'
    }
    else {
        Add-Result -Name 'File: Windows Terminal settings.json' -Status 'PASS' -Details "Found and readable: $terminalSettingsPath" -Recommendation 'No action needed.'
        $schemeCheck = Test-TerminalScheme -SettingsPath $terminalSettingsPath -SchemeName 'Minimal Dark'
        if ($schemeCheck.Found) {
            Add-Result -Name 'Terminal scheme: Minimal Dark' -Status 'PASS' -Details 'Required color scheme exists in Windows Terminal settings.' -Recommendation 'No action needed.'
        }
        else {
            Add-Result -Name 'Terminal scheme: Minimal Dark' -Status 'FAIL' -Details $schemeCheck.Error -Recommendation 'Add the "Minimal Dark" scheme from ./terminal/settings.json to your Windows Terminal settings.'
        }
    }
}

# 3) PowerShell modules
$modules = @('Terminal-Icons', 'PSReadLine')
foreach ($module in $modules) {
    if (Get-Module -ListAvailable -Name $module) {
        Add-Result -Name "Module: $module" -Status 'PASS' -Details 'Module is available.' -Recommendation 'No action needed.'
    }
    else {
        Add-Result -Name "Module: $module" -Status 'FAIL' -Details 'Module is not installed for the current user/environment.' -Recommendation "Run: Install-Module -Name $module -Scope CurrentUser -Force"
    }
}

# 4) Final report
Write-Host ''
Write-Host '--- Detailed Results ---' -ForegroundColor Cyan
foreach ($r in $results) {
    $color = switch ($r.Status) {
        'PASS' { 'Green' }
        'WARN' { 'Yellow' }
        default { 'Red' }
    }

    Write-Host "[$($r.Status)] $($r.Name)" -ForegroundColor $color
    Write-Host "        $($r.Details)"
    if ($r.Status -ne 'PASS') {
        Write-Host "        Recommendation: $($r.Recommendation)" -ForegroundColor Yellow
    }
}

$failCount = ($results | Where-Object Status -eq 'FAIL').Count
$warnCount = ($results | Where-Object Status -eq 'WARN').Count
$passCount = ($results | Where-Object Status -eq 'PASS').Count
$totalCount = $results.Count

$overall = if ($failCount -gt 0) { 'FAIL' } elseif ($warnCount -gt 0) { 'WARN' } else { 'PASS' }
$overallColor = if ($overall -eq 'PASS') { 'Green' } elseif ($overall -eq 'WARN') { 'Yellow' } else { 'Red' }

Write-Host ''
Write-Host "=== Summary: $overall ===" -ForegroundColor $overallColor
Write-Host "Passed: $passCount / $totalCount"
Write-Host "Warnings: $warnCount"
Write-Host "Failed: $failCount"

if ($overall -eq 'FAIL') {
    exit 1
}

exit 0
