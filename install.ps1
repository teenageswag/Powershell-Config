<#
.SYNOPSIS
    Automated installation script for Minimal Dark PowerShell Config.
#>

$ErrorActionPreference = "Stop"

function Write-Info($Message) { Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-Success($Message) { Write-Host "[SUCCESS] $Message" -ForegroundColor Green }
function Write-Warn($Message) { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-ErrorMsg($Message) { Write-Host "[ERROR] $Message" -ForegroundColor Red }

function Test-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-WingetPackage($PackageId, $Name) {
    if (Get-Command $PackageId -ErrorAction SilentlyContinue) {
        Write-Info "$Name is already installed."
    }
    else {
        Write-Info "Installing $Name..."
        winget install --id $PackageId --silent --accept-package-agreements --accept-source-agreements
        Write-Success "$Name installed."
    }
}

function Install-PSModule($ModuleName) {
    if (Get-Module -ListAvailable $ModuleName) {
        Write-Info "$ModuleName is already installed."
    }
    else {
        Write-Info "Installing $ModuleName..."
        Install-Module -Name $ModuleName -Force -AllowClobber -Scope CurrentUser
        Write-Success "$ModuleName installed."
    }
}

# --- 1. Check Permissions ---
if (-not (Test-Admin)) {
    Write-Warn "Not running as Admin. Font installation might fail."
}

# --- 2. Install Dependencies ---
Write-Info "Checking dependencies..."
Install-WingetPackage "JanDeDobbeleer.OhMyPosh" "Oh My Posh"
Install-WingetPackage "ajeetdsouza.zoxide" "Zoxide"
Install-PSModule "Terminal-Icons"
Install-PSModule "PSReadLine"

# --- 3. Install Font ---
$fontName = "CaskaydiaCove Nerd Font"
Write-Info "Ensuring $fontName is installed..."
# Note: oh-my-posh font install is the easiest way
oh-my-posh font install CaskaydiaCove --headless

# --- 4. Deploy Theme ---
$themeDir = Join-Path $HOME ".config/oh-my-posh"
if (-not (Test-Path $themeDir)) {
    New-Item -ItemType Directory -Path $themeDir -Force | Out-Null
}
Write-Info "Deploying theme..."
Copy-Item "./theme/dark-minimal-theme.json" -Destination $themeDir -Force
Write-Success "Theme deployed to $themeDir"

# --- 5. Update Profile ---
Write-Info "Updating PowerShell profile..."
if (Test-Path $PROFILE) {
    $backupPath = "$PROFILE.bak_$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $PROFILE -Destination $backupPath
    Write-Info "Backup created: $backupPath"
}
else {
    $profileDir = Split-Path $PROFILE
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
}

Copy-Item "./profile/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
Write-Success "Profile updated."

# --- 6. Windows Terminal Settings (Partial Automation) ---
Write-Info "Next steps for Windows Terminal:"
Write-Info "1. Open Windows Terminal settings (Ctrl+,)"
Write-Info "2. Go to 'JSON file' and check your schemes."
Write-Warn "Automatic injection of settings into Windows Terminal is complex and riskier."
Write-Info "The 'terminal/settings.json' file in this repo contains the recommended configuration."

Write-Success "Installation complete! Please RESTART your terminal."
