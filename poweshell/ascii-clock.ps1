# ============================================================
#  Big ASCII Clock + Calendar for PowerShell
#  Author: rwin
#  Press Ctrl+C to exit
# ============================================================

$ErrorActionPreference = 'SilentlyContinue'

# ----- 7-row big digit font (0-9 and : and space) -----
$digits = @{
    '0' = @(" ███ ", "█   █", "█   █", "█   █", "█   █", "█   █", " ███ ")
    '1' = @("  █  ", " ██  ", "  █  ", "  █  ", "  █  ", "  █  ", " ███ ")
    '2' = @(" ███ ", "█   █", "    █", "   █ ", "  █  ", " █   ", "█████")
    '3' = @(" ███ ", "█   █", "    █", "  ██ ", "    █", "█   █", " ███ ")
    '4' = @("   █ ", "  ██ ", " █ █ ", "█  █ ", "█████", "   █ ", "   █ ")
    '5' = @("█████", "█    ", "████ ", "    █", "    █", "█   █", " ███ ")
    '6' = @("  ██ ", " █   ", "█    ", "████ ", "█   █", "█   █", " ███ ")
    '7' = @("█████", "    █", "   █ ", "  █  ", " █   ", " █   ", " █   ")
    '8' = @(" ███ ", "█   █", "█   █", " ███ ", "█   █", "█   █", " ███ ")
    '9' = @(" ███ ", "█   █", "█   █", " ████", "    █", "   █ ", " ███ ")
    ':' = @("     ", "  █  ", "  █  ", "     ", "  █  ", "  █  ", "     ")
    ' ' = @("     ", "     ", "     ", "     ", "     ", "     ", "     ")
}

function Get-BigText {
    param([string]$Text, [string]$ColorCode)
    $rows = @("", "", "", "", "", "", "")
    foreach ($ch in $Text.ToCharArray()) {
        $glyph = $digits["$ch"]
        if (-not $glyph) { $glyph = $digits[' '] }
        for ($i = 0; $i -lt 7; $i++) {
            $rows[$i] += $glyph[$i] + " "
        }
    }
    $out = ""
    foreach ($row in $rows) {
        $out += $ColorCode + $row + $PSStyle.Reset + "`n"
    }
    return $out
}

function Draw-Calendar {
    $today = Get-Date
    $year  = $today.Year
    $month = $today.Month
    $first = Get-Date -Year $year -Month $month -Day 1
    $daysInMonth = [DateTime]::DaysInMonth($year, $month)
    $startDow = [int]$first.DayOfWeek   # 0 = Sunday

    $c = $PSStyle.Foreground.BrightMagenta
    $hi = $PSStyle.Foreground.Black + $PSStyle.BackgroundBrightYellow
    $dim = $PSStyle.Foreground.BrightBlack
    $r = $PSStyle.Reset

    $lines = @()
    $lines += "$c   $($today.ToString('MMMM yyyy'))$r"
    $lines += "$dim Su Mo Tu We Th Fr Sa$r"

    $row = " " * ($startDow * 3)
    for ($d = 1; $d -le $daysInMonth; $d++) {
        $dow = ($startDow + $d - 1) % 7
        $dayStr = "{0,2}" -f $d
        if ($d -eq $today.Day) {
            $row += "$hi$dayStr$r "
        } else {
            $row += "$dayStr "
        }
        if ($dow -eq 6) {
            $lines += $row
            $row = ""
        }
    }
    if ($row.Trim().Length -gt 0) { $lines += $row }
    return $lines
}

try {
    while ($true) {
        Clear-Host

        $now = Get-Date
        $timeStr = $now.ToString("HH:mm:ss")
        $dateStr = $now.ToString("dddd, dd MMMM yyyy")

        $clockColor = $PSStyle.Foreground.BrightGreen
        $accent = $PSStyle.Foreground.BrightCyan
        $dim = $PSStyle.Foreground.BrightBlack
        $r = $PSStyle.Reset

        Write-Host ""
        Write-Host "$accent  ╔════════════════════════════════════════╗$r"
        Write-Host "$accent  ║             T E R M I N A L   C L O C K         ║$r"
        Write-Host "$accent  ╚════════════════════════════════════════╝$r"
        Write-Host ""

        $bigClock = Get-BigText -Text $timeStr -ColorCode $clockColor
        foreach ($line in ($bigClock -split "`n")) {
            Write-Host "   $line"
        }

        Write-Host ""
        Write-Host "  $accent$dateStr$r"
        Write-Host ""
        Write-Host "$dim  ──────────────────────────────────────────$r"
        Write-Host ""

        $cal = Draw-Calendar
        foreach ($line in $cal) {
            Write-Host "  $line"
        }

        Write-Host ""
        Write-Host "$dim  Ctrl+C to exit$r"

        Start-Sleep -Seconds 1
    }
}
finally {
    Write-Host ""
    Write-Host "$($PSStyle.Foreground.BrightCyan)Clock stopped.$($PSStyle.Reset)"
}
