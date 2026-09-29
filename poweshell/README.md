# PowerShell Terminal Toolkit

A small collection of colorful, self-contained PowerShell scripts that turn your terminal into something a little more fun to look at — a neofetch-style system info banner, a live resource monitor, a big ASCII clock with calendar, and a Matrix-style digital rain animation.

No external dependencies. No modules to install. Just PowerShell.

![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-5391FE?logo=powershell&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Windows-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Contents

| Script | Description |
|---|---|
| [`neofetch.ps1`](#-neofetchps1) | Neofetch-style system info panel with an ASCII logo |
| [`live-monitor.ps1`](#-live-monitorps1) | Live CPU / RAM / disk dashboard with bar graphs and sparklines |
| [`ascii-clock.ps1`](#-ascii-clockps1) | Big ASCII digital clock with a live monthly calendar |
| [`matrix-rain.ps1`](#-matrix-rainps1) | Matrix-style digital rain animation with a custom reveal message |

---

## Requirements

- **Windows PowerShell 5.1** or, ideally, **PowerShell 7+** for full color support (`$PSStyle`).
- A terminal that renders ANSI colors well — [Windows Terminal](https://aka.ms/terminal) is recommended.
- Script execution allowed for your user. If scripts are blocked, run once:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

---

## Usage

Clone or download this repo, then from the folder run any script directly:

```powershell
.\neofetch.ps1
.\live-monitor.ps1
.\ascii-clock.ps1
.\matrix-rain.ps1
```

Animated scripts (`live-monitor`, `ascii-clock`, `matrix-rain`) loop until you stop them with `Ctrl+C`.

---

## 🖥 neofetch.ps1

A one-shot system information panel, inspired by [neofetch](https://github.com/dylanaraps/neofetch), with an ASCII Windows logo on the left and system details on the right: OS, kernel version, uptime, shell, resolution, CPU, GPU, memory, and disk usage, plus a small color palette strip at the bottom.

```powershell
.\neofetch.ps1
```

---

## 📊 live-monitor.ps1

A live-updating dashboard (refreshes every second) showing:

- Color-coded bar graphs for **CPU**, **RAM**, and **Disk** usage (green → yellow → red by load)
- 30-second **sparkline** history for CPU and RAM
- Top 5 processes by CPU time

```powershell
.\live-monitor.ps1
```

Press `Ctrl+C` to exit.

> The first reading may take a moment — `Get-Counter` needs a warm-up sample for accurate CPU usage.

---

## 🕐 ascii-clock.ps1

A large 7-row ASCII digital clock that updates every second, with the current month's calendar rendered underneath and today's date highlighted.

```powershell
.\ascii-clock.ps1
```

Press `Ctrl+C` to exit.

> Best viewed in a terminal window at least ~60 columns wide.

---

## 🟩 matrix-rain.ps1

A "digital rain" animation in the style of *The Matrix* — falling katakana and numbers with a bright leading character and a fading green trail. After a few seconds, a custom message fades in at the center of the screen.

```powershell
.\matrix-rain.ps1
```

To change the reveal message, edit this line near the top of the script:

```powershell
$Message = "HELLO RWIN"
```

Press `Ctrl+C` to exit.

---

## Notes

- All scripts rely on `$PSStyle` for ANSI colors, introduced in **PowerShell 7.2**. On Windows PowerShell 5.1, colors may not render — consider upgrading to [PowerShell 7](https://github.com/PowerShell/PowerShell) for the intended experience.
- These scripts are meant for personal terminal customization and fun — not production tooling.

## License

MIT — do whatever you want with these.
