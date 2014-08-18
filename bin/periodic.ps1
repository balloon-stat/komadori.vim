param ($file, $period, $interval, $left, $top, $right, $bottom)
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

$oneshot = Join-Path $PSScriptRoot oneshot.ps1
$savegif = Join-Path $PSScriptRoot savegif.ps1

Read-Host "Start to push Enter!"
Write-Host "Finish to push any key"
Write-Host
Write-Host "Start after 10 seconds"
for ($ix = 1; $ix -le 10; $ix++) {
   Start-Sleep -s 1
   Write-Host $ix " seconds"
}
Write-Host "Start!"
$margin = $left, $top, $right, $bottom
try {
  $imgs = @()
  $count = 0
  $max_count = 300
  while ($count -lt $max_count) {
    Start-Sleep -m $period
    $imgs += & $oneshot $margin
    $count++
    Write-Host $count
    if ($Host.UI.RawUI.KeyAvailable) {
      break
    }
  }
}
catch{}
finally {
  $delays = ,$interval * $imgs.Length
  & $savegif $file $imgs $delays
}

