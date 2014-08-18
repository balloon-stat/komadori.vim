
Add-Type -AssemblyName System.Drawing

$imgs = @()
$max = $Args.Length - 1
for ($ix = 1; $ix -le $max - 2; $ix++) {
  $name = $Args[1] + "komadori_" + $ix + ".gif"
  $img = [Drawing.Image]::Fromfile($name)
  $imgs += New-Object Drawing.Bitmap($img)
}

$savegif = Join-Path $PSScriptRoot savegif.ps1
& $savegif $Args[0] $imgs $Args[3..$max]
