# ============================================================
#  Live System Monitor Dashboard for PowerShell
#  Author: rwin
#  Press Ctrl+C to exit
# ============================================================

$ErrorActionPreference = 'SilentlyContinue'

function Get-Bar {
    param(
        [double]$Percent,
        [int]$Width = 30
    )
    $filled = [math]::Round(($Percent / 100) * $Width)
    if ($filled -gt $Width) { $filled = $Width }
    $empty = $Width - $filled

    # Color threshold
    $color = if ($Percent -ge 85) { $PSStyle.Foreground.BrightRed }
             elseif ($Percent -ge 60) { $PSStyle.Foreground.BrightYellow }
             else { $PSStyle.Foreground.BrightGreen }

    $bar = $color + ("█" * $filled) + $PSStyle.Foreground.BrightBlack + ("░" * $empty) + $PSStyle.Reset
    return $bar
}

function Get-Sparkline {
    param([double[]]$History, [int]$Width = 30)
    $chars = @('▁','▂','▃','▄','▅','▆','▇','█')
    $padded = $History
    if ($padded.Count -lt $Width) {
        $padded = (@(0) * ($Width - $padded.Count)) + $padded
    } else {
        $padded = $padded[-$Width..-1]
    }
    $line = ""
    foreach ($v in $padded) {
        $idx = [math]::Floor(($v / 100) * ($chars.Count - 1))
        if ($idx -lt 0) { $idx = 0 }
        if ($idx -gt $chars.Count - 1) { $idx = $chars.Count - 1 }
        $line += $chars[$idx]
    }
    return $line
}

function Draw-Header {
    $c = $PSStyle.Foreground.BrightCyan
    $r = $PSStyle.Reset
    Write-Host ""
    Write-Host "$c╔══════════════════════════════════════════════════════╗$r"
    Write-Host "$c║           L I V E   S Y S T E M   M O N I T O R        ║$r"
    Write-Host "$c╚══════════════════════════════════════════════════════╝$r"
    Write-Host ""
}

# ----- History buffers for sparklines -----
$cpuHistory  = @()
$ramHistory  = @()
$maxHistory  = 30

# Prime CPU counter (first call is always inaccurate)
Get-Counter '\Processor(_Total)\% Processor Time' | Out-Null

try {
    while ($true) {
        Clear-Host
        Draw-Header

        # ---- CPU ----
        $cpuPercent = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue, 1)
        $cpuHistory += $cpuPercent
        if ($cpuHistory.Count -gt $maxHistory) { $cpuHistory = $cpuHistory[-$maxHistory..-1] }

        # ---- RAM ----
        $os        = Get-CimInstance Win32_OperatingSystem
        $ramTotal  = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
        $ramFree   = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
        $ramUsed   = [math]::Round($ramTotal - $ramFree, 1)
        $ramPercent = [math]::Round(($ramUsed / $ramTotal) * 100, 1)
        $ramHistory += $ramPercent
        if ($ramHistory.Count -gt $maxHistory) { $ramHistory = $ramHistory[-$maxHistory..-1] }

        # ---- Disk ----
        $disk = Get-PSDrive -Name C
        $diskUsed  = [math]::Round($disk.Used / 1GB, 1)
        $diskTotal = [math]::Round(($disk.Used + $disk.Free) / 1GB, 1)
        $diskPercent = [math]::Round(($diskUsed / $diskTotal) * 100, 1)

        # ---- Top processes by CPU ----
        $topProcs = Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 -Property ProcessName, CPU, WorkingSet

        $lbl = $PSStyle.Foreground.White
        $val = $PSStyle.Foreground.BrightWhite
        $dim = $PSStyle.Foreground.BrightBlack
        $r   = $PSStyle.Reset

        Write-Host ("  {0}CPU   {1} {2,5}%   {3}" -f $lbl, (Get-Bar $cpuPercent), $cpuPercent, $r)
        Write-Host ("        {0}{1}{2}" -f $dim, (Get-Sparkline $cpuHistory), $r)
        Write-Host ""
        Write-Host ("  {0}RAM   {1} {2,5}%   {3}{4:N1}/{5:N1} GB{6}" -f $lbl, (Get-Bar $ramPercent), $ramPercent, $dim, $ramUsed, $ramTotal, $r)
        Write-Host ("        {0}{1}{2}" -f $dim, (Get-Sparkline $ramHistory), $r)
        Write-Host ""
        Write-Host ("  {0}DISK  {1} {2,5}%   {3}{4:N1}/{5:N1} GB{6}" -f $lbl, (Get-Bar $diskPercent), $diskPercent, $dim, $diskUsed, $diskTotal, $r)
        Write-Host ""
        Write-Host "$dim  ────────────────────────────────────────────────────────$r"
        Write-Host "$val  Top Processes (CPU time)$r"
        foreach ($p in $topProcs) {
            $memMB = [math]::Round($p.WorkingSet / 1MB, 1)
            Write-Host ("    {0,-20} {1}CPU: {2,8:N1}s   MEM: {3,7:N1} MB{4}" -f $p.ProcessName, $dim, $p.CPU, $memMB, $r)
        }
        Write-Host ""
        Write-Host "$dim  Updated: $(Get-Date -Format 'HH:mm:ss')   |   Ctrl+C to exit$r"

        Start-Sleep -Seconds 1
    }
}
finally {
    Write-Host ""
    Write-Host "$($PSStyle.Foreground.BrightCyan)Monitor stopped.$($PSStyle.Reset)"
}
