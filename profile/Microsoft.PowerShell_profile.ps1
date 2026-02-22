# Microsoft.PowerShell_profile.ps1
# optimized for Minimal Dark environment

Set-StrictMode -Version Latest

# --- Encoding & Shell Fixes ---
[Console]::InputEncoding  = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Test-CommandExists($Capability) {
    return (Get-Command $Capability -ErrorAction SilentlyContinue) -ne $null
}

# --- Module Initialization ---

# Oh My Posh
if (Test-CommandExists "oh-my-posh") {
    $themePath = Join-Path $HOME ".config/oh-my-posh/dark-minimal-theme.json"
    if (Test-Path $themePath) {
        oh-my-posh init pwsh --config $themePath | Invoke-Expression
    }
}

# Terminal Icons
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons -ErrorAction SilentlyContinue
}

# Zoxide
if (Test-CommandExists "zoxide") {
    zoxide init powershell | Out-String | Invoke-Expression
}

# --- PSReadLine (Safe for 5.1 and 7+) ---
$psrl = Get-Module -ListAvailable -Name PSReadLine |
        Sort-Object Version -Descending |
        Select-Object -First 1

if ($psrl) {

    Import-Module PSReadLine -ErrorAction SilentlyContinue

    # Predictive features only in PowerShell 7+ with PSReadLine >= 2.1
    if ($PSVersionTable.PSVersion.Major -ge 7 -and
        $psrl.Version -ge [Version]"2.1.0") {

        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Set-PSReadLineOption -PredictionViewStyle ListView
        Set-PSReadLineOption -Colors @{
            InlinePrediction = "`e[38;5;8m"
        }
    }
}

# --- Aliases ---
Set-Alias g  git
Set-Alias l  ls
Set-Alias ll ls
Set-Alias v  nvim
Set-Alias py python
Set-Alias lg lazygit

# --- Utility Functions ---
function mkcd($Path) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location -Path $Path
}

# --- Environment ---
$machinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
$userPath    = [System.Environment]::GetEnvironmentVariable("PATH", "User")

if ($machinePath -and $userPath) {
    $env:PATH = "$machinePath;$userPath"
}

$env:BAT_THEME = "TwoDark"
$env:PSConsoleGui_Title = "PowerShell | Minimal Dark"
