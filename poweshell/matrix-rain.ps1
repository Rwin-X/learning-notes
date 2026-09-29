# ============================================================
#  Matrix Digital Rain for PowerShell
#  Author: rwin
#  Press Ctrl+C to exit
# ============================================================

$ErrorActionPreference = 'SilentlyContinue'

# ----- Config -----
$Message = "HELLO RWIN"     # پیامی که وسط بارون ظاهر می‌شه
$RevealAfter = 40           # بعد از چند فریم پیام ظاهر بشه

$width  = [Console]::WindowWidth
$height = [Console]::WindowHeight - 1

$chars = "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾗﾘﾙﾚﾛﾜﾝ0123456789".ToCharArray()

# Each column: current drop position (-1 = not started), speed, trail length
$drops  = @()
$speeds = @()
for ($x = 0; $x -lt $width; $x++) {
    $drops  += Get-Random -Minimum (-30) -Maximum 0
    $speeds += Get-Random -Minimum 1 -Maximum 3
}

[Console]::CursorVisible = $false
[Console]::Clear()

$green      = $PSStyle.Foreground.Green
$brightGrn  = $PSStyle.Foreground.BrightGreen
$white      = $PSStyle.Foreground.BrightWhite
$dimGreen   = $PSStyle.Foreground.FromRgb(0,60,0)
$reset      = $PSStyle.Reset

$frame = 0

try {
    while ($true) {
        $frame++
        $sb = New-Object System.Text.StringBuilder
        [void]$sb.Append("`e[H")  # move cursor home, no full clear (less flicker)

        # Build screen buffer
        $screen = New-Object 'string[,]' $height, $width
        for ($y = 0; $y -lt $height; $y++) {
            for ($x = 0; $x -lt $width; $x++) {
                $screen[$y, $x] = $null
            }
        }

        for ($x = 0; $x -lt $width; $x++) {
            $drops[$x] += $speeds[$x] * 0.4
            $headY = [math]::Floor($drops[$x])

            if ($headY -gt $height + 15) {
                $drops[$x] = Get-Random -Minimum (-20) -Maximum (-1)
                $speeds[$x] = Get-Random -Minimum 1 -Maximum 3
            }

            for ($trail = 0; $trail -lt 16; $trail++) {
                $y = $headY - $trail
                if ($y -ge 0 -and $y -lt $height) {
                    $ch = $chars[(Get-Random -Maximum $chars.Length)]
                    if ($trail -eq 0) {
                        $screen[$y, $x] = "$white$ch$reset"
                    } elseif ($trail -lt 4) {
                        $screen[$y, $x] = "$brightGrn$ch$reset"
                    } else {
                        $screen[$y, $x] = "$green$ch$reset"
                    }
                }
            }
        }

        # Render buffer to lines
        $lines = New-Object System.Text.StringBuilder
        for ($y = 0; $y -lt $height; $y++) {
            $rowSb = New-Object System.Text.StringBuilder
            for ($x = 0; $x -lt $width; $x++) {
                $cell = $screen[$y, $x]
                if ($cell) { [void]$rowSb.Append($cell) } else { [void]$rowSb.Append(' ') }
            }
            [void]$lines.Append($rowSb.ToString())
            [void]$lines.Append("`n")
        }

        # ---- Reveal message in the center after some frames ----
        if ($frame -gt $RevealAfter -and $Message) {
            $midY = [math]::Floor($height / 2)
            $midX = [math]::Max(0, [math]::Floor(($width - $Message.Length - 4) / 2))
            $box = " $Message "
            $boxTop = "+" + ("-" * $box.Length) + "+"
            # We just print it as an overlay after the frame using cursor positioning
        }

        [Console]::SetCursorPosition(0, 0)
        [Console]::Out.Write($lines.ToString())

        if ($frame -gt $RevealAfter -and $Message) {
            $midY = [math]::Floor($height / 2)
            $box = "  $Message  "
            $midX = [math]::Max(0, [math]::Floor(($width - $box.Length) / 2))
            [Console]::SetCursorPosition($midX, $midY)
            [Console]::Out.Write("$white$($PSStyle.Background.FromRgb(0,20,0))$box$reset")
        }

        Start-Sleep -Milliseconds 60
    }
}
finally {
    [Console]::CursorVisible = $true
    [Console]::ResetColor()
    Clear-Host
    Write-Host "$($PSStyle.Foreground.BrightGreen)Wake up, rwin...$($PSStyle.Reset)"
}
