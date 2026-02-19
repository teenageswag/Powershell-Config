# Minimal Dark PowerShell Config

A minimalist dark theme for Windows Terminal with Oh My Posh, optimized for a clean and efficient CLI experience.

![Minimal Dark Theme](https://raw.githubusercontent.com/teenageswag/Powershell-Config/main/preview.png)

> [!TIP]
> This config focuses on readability and minimalism, using a curated dark palette with yellow and green accents.

## ✨ Features

- **Dark Minimal Theme**: Easy on the eyes, balanced color scheme.
- **Rich Prompt**: Real-time Git status, user context, and execution time.
- **Productivity Boost**: Pre-configured aliases (`g`, `l`, `v`, `lg`, etc.) and smart navigation (`zoxide`).
- **One-Click Install**: Fully automated setup script.

## 🚀 Quick Start (Automated)

The easiest way to get started is to use the automated installation script. It handles dependencies, fonts, and configuration.

1. **Clone the repository**:

   ```powershell
   git clone https://github.com/teenageswag/Powershell-Config.git
   cd Powershell-Config
   ```

2. **Run the installer**:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1
   ```

3. **Restart your terminal**.

## 🛠️ Manual Installation

If the script fails or you prefer a manual approach, follow these steps:

### 1. Install Dependencies

Run these commands in PowerShell:

```powershell
# Core engines
winget install JanDeDobbeleer.OhMyPosh
winget install ajeetdsouza.zoxide

# Recommended Font
oh-my-posh font install CaskaydiaCove

# PowerShell Modules
Install-Module -Name Terminal-Icons -Scope CurrentUser
Install-Module -Name PSReadLine -Scope CurrentUser -Force
```

### 2. Deploy Configuration

1. **Theme**: Copy `theme/dark-minimal-theme.json` to `$HOME/.config/oh-my-posh/`.
2. **Profile**: Copy `profile/Microsoft.PowerShell_profile.ps1` to your PowerShell profile location (run `echo $PROFILE` to find it).
3. **Windows Terminal**: Open settings (`Ctrl+,`), go to the JSON file, and add the "Minimal Dark" scheme from `terminal/settings.json`.

## 📂 Project Structure

- `profile/`: Custom PowerShell profile with aliases and functions.
- `theme/`: Oh My Posh prompt configuration.
- `terminal/`: Windows Terminal settings (color scheme & profiles).
- `install.ps1`: All-in-one automation script.

## ⌨️ Useful Aliases

| Alias | Command | Description |
| :--- | :--- | :--- |
| `g` | `git` | Git CLI |
| `l`, `ll` | `ls` | List directory |
| `v` | `nvim` | Neovim |
| `lg` | `lazygit` | Git TUI |
| `mkcd` | `function` | Create & enter directory |

## ⚖️ License

Distributed under the MIT License. See `LICENSE` for more information.

---
[Project Repository](https://github.com/teenageswag/Powershell-Config)
