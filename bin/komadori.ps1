param (
  [string]$filename,
  [int]$periodic      = 0,
  [int]$interval      = 30,
  [int]$margin_left   = 8,
  [int]$margin_top    = 82,
  [int]$margin_right  = 8,
  [int]$margin_bottom = 8
)
Add-Type -AssemblyName System.Drawing

$oneshot = Join-Path $PSScriptRoot oneshot.ps1
$savegif = Join-Path $PSScriptRoot savegif.ps1

$margin = @($margin_left, $margin_top, $margin_right, $margin_bottom)

if ($periodic) {
  $job = Start-Job -ScriptBlock {
    try {
      $imgs = @()
      $count = 0
      $max_count = 300
      while ($count -lt $max_count) {
        Start-Sleep -m ($using:periodic)
        $imgs += & $using:oneshot $using:margin
        $count++
      }
    }
    catch {}
    finally {
      $delays = ,$using:interval * $imgs.Length
      & $using:savegif $using:filename $imgs $delays
      $count
    }
  }
}

Write-Host "start"

$imgs = @()
$delays = @()

$in = ""
$delay = $interval
while($in -ne "quit") {
  $in = Read-Host
  if ($in -eq "cap") {
    $delays += $delay
    $delay = $interval
    $imgs += & $oneshot $margin
  }
  elseif ($in -eq "keep") {
    $delay += $interval
  }
}

if ($job) {
  $job | Receive-Job
}
else {
  $delays += $delay
  & $savegif $filename $imgs $delays
}

