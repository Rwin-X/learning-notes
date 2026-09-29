# ============================================================
#  Neofetch-style System Info Display for PowerShell
#  Author: rwin
# ============================================================

function Get-Uptime {
    $os = Get-CimInstance Win32_OperatingSystem
    $uptime = (Get-Date) - $os.LastBootUpTime
    return "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
}

function Get-Colored($text, $color) {
    return $PSStyle.Foreground.$color + $text + $PSStyle.Reset
}

# ----- Gather system info -----
$os          = Get-CimInstance Win32_OperatingSystem
$cpu         = (Get-CimInstance Win32_Processor).Name -replace '\(R\)','' -replace '\(TM\)',''
$gpu         = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name
$ramTotal    = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$ramFree     = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$ramUsed     = [math]::Round($ramTotal - $ramFree, 1)
$hostname    = $env:COMPUTERNAME
$username    = $env:USERNAME
$osName      = $os.Caption
$osVersion   = $os.Version
$uptime      = Get-Uptime
$shell       = "PowerShell " + $PSVersionTable.PSVersion.ToString()
$resolution  = try {
    Add-Type -AssemblyName System.Windows.Forms
    $s = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    "$($s.Width)x$($s.Height)"
} catch { "N/A" }
$disk        = Get-PSDrive -Name C -ErrorAction SilentlyContinue
$diskUsed    = if ($disk) { [math]::Round(($disk.Used / 1GB), 1) } else { "?" }
$diskTotal   = if ($disk) { [math]::Round((($disk.Used + $disk.Free) / 1GB), 1) } else { "?" }

# ----- ASCII Logo (Windows-style diamond, cyan) -----
$c = $PSStyle.Foreground.Cyan
$b = $PSStyle.Foreground.BrightCyan
$w = $PSStyle.Foreground.White
$r = $PSStyle.Reset

$logo = @(
"$c            ,.=:!!t3Z3z.,               $r"
"$c           :tt:::tt333EE3               $r"
"$b           Et:::ztt33EEEL$c @Ee.,      ..,   $r"
"$b          ;tt:::tt333EE7 $c;EEEEEEttttt33# $r"
"$b         :Et:::zt333EEQ.$c SEEEEEttttt33QL  $r"
"$b         it::::tt333EEF$c @EEEEEEttttt33F   $r"
"$b        ;3=*^```\`\`\`\"*4EEV$c :EEEEEEttttt33@.   $r"
"$w        ,.=::::!t=., $c \`   \`\`\`\`\`\`\`\`\`\`\`\`\`.fEEEEEE.    $r"
"$w       ;::::::::zt33)   $c EEEtttttttEEXEEEEEE\`    $r"
"$w      :t::::::::tt33.$c:Z3z..  \`\`\`\`\`  \`\`\`,..g.     $r"
"$w      i::::::::zt33F$c AEEEtttt::::ztF         $r"
"$w     ;:::::::::t33V$c ;EEEttttt::::t3          $r"
"$w     E::::::::zt33L$c @EEEtttt::::z3F          $r"
"$w    {3=*^\`\`\`\`\`\`\`\`\`\"*4E3)$c ;EEEtttt:::::tZ\`          $r"
"$w                    \`$c :EEEEtttt::::z7          $r"
"$w                     \`VEzjt:;;z>*\`            $r"
)

# ----- Info block -----
$sep = ("-" * 28)

$info = @(
    ""
    (Get-Colored "$username" "BrightCyan") + "@" + (Get-Colored "$hostname" "BrightCyan")
    $sep
    (Get-Colored "OS       : " "Cyan") + $osName
    (Get-Colored "Kernel   : " "Cyan") + $osVersion
    (Get-Colored "Uptime   : " "Cyan") + $uptime
    (Get-Colored "Shell    : " "Cyan") + $shell
    (Get-Colored "Resolut. : " "Cyan") + $resolution
    (Get-Colored "CPU      : " "Cyan") + $cpu.Trim()
    (Get-Colored "GPU      : " "Cyan") + $gpu
    (Get-Colored "Memory   : " "Cyan") + "$ramUsed GB / $ramTotal GB"
    (Get-Colored "Disk (C) : " "Cyan") + "$diskUsed GB / $diskTotal GB"
    ""
    "  " + $PSStyle.Foreground.Black + $PSStyle.BackgroundBlack + "   " + $r + `
          $PSStyle.Foreground.Red + $PSStyle.BackgroundRed + "   " + $r + `
          $PSStyle.Foreground.Green + $PSStyle.BackgroundGreen + "   " + $r + `
          $PSStyle.Foreground.Yellow + $PSStyle.BackgroundYellow + "   " + $r + `
          $PSStyle.Foreground.Blue + $PSStyle.BackgroundBlue + "   " + $r + `
          $PSStyle.Foreground.Magenta + $PSStyle.BackgroundMagenta + "   " + $r + `
          $PSStyle.Foreground.Cyan + $PSStyle.BackgroundCyan + "   " + $r + `
          $PSStyle.Foreground.White + $PSStyle.BackgroundWhite + "   " + $r
)

# ----- Render side by side -----
Write-Host ""
$maxLines = [Math]::Max($logo.Count, $info.Count)
for ($i = 0; $i -lt $maxLines; $i++) {
    $logoLine = if ($i -lt $logo.Count) { $logo[$i] } else { " " * 45 }
    $infoLine = if ($i -lt $info.Count) { $info[$i] } else { "" }
    Write-Host ("{0}  {1}" -f $logoLine, $infoLine)
}
Write-Host ""
