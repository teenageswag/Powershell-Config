# Microsoft.PowerShell_profile.ps1
# optimized for Minimal Dark environment

Set-StrictMode -Version Latest

# --- Encoding & Shell Fixes ---
[console]::InputEncoding = [console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
function Test-CommandExists($Capability) {
    return (Get-Command $Capability -ErrorAction SilentlyContinue) -ne $null
}

# --- Module Initialization ---
# Oh My Posh
if (Test-CommandExists "oh-my-posh") {
    oh-my-posh init pwsh --config "d:\Development\Oh-My-Posh-Theme\dark-minimal-theme.json" | Invoke-Expression
}

# Icons
if (Get-Module -ListAvailable Terminal-Icons) {
    Import-Module Terminal-Icons -ErrorAction SilentlyContinue
}

# Zoxide
if (Test-CommandExists "zoxide") {
    zoxide init powershell | Out-String | Invoke-Expression
}

# --- PSReadLine (Performance & UX) ---
if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -Colors @{
        InlinePrediction = "`e[38;5;8m" # Muted grey (ANSI Color 8)
    }
}

# --- Aliases ---
Set-Alias g git
Set-Alias l ls
Set-Alias ll ls
Set-Alias v nvim
Set-Alias py python
Set-Alias lg lazygit

# Utility Functions
function mkcd($Path) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location -Path $Path
}

# Environment
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("PATH","User")
$env:BAT_THEME = "TwoDark"
$env:PSConsoleGui_Title = "PowerShell | Minimal Dark"
