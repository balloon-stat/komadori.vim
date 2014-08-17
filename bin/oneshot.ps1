param ([int[]]$margin = @(8, 82, 8, 8))

function getVimRect($margin = @(8, 82, 8, 8)) {
  begin {
  Add-Type @"
using System;
using System.Runtime.InteropServices;
 
public class Win32 {
[DllImport("user32.dll")]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
}

public struct RECT
{
  public int Left;
  public int Top;
  public int Right;
  public int Bottom;
}
 
"@
    $rc = New-Object Rect
    $procs = Get-Process | where {$_.ProcessName -eq "gvim"}
    if ($procs.Length -ne 1) {
        return $null
    }
  }

  process {
    [void][Win32]::GetWindowRect($procs.MainWindowHandle, [ref]$rc)

    $rc.Left += $margin[0]
    $rc.Top += $margin[1]
    $rc.Right -= $margin[2]
    $rc.Bottom -= $margin[3]

    return $rc
  }
}

function capture {
  param (
    [Parameter(ValueFromPipeline=1, Mandatory=1)]
     $rc
  )
  begin { Add-Type -AssemblyName System.Drawing }
  process {
    $width = $rc.Right - $rc.Left
    $height = $rc.Bottom - $rc.Top
    $bmp = New-Object Drawing.Bitmap($width, $height)
    $grfx = [Drawing.Graphics]::FromImage($bmp)
    $op = New-Object Drawing.Point(0, 0)
    $wp = New-Object Drawing.Point($rc.Left, $rc.Top)
    $grfx.CopyFromScreen($wp, $op, $bmp.Size)
    $grfx.Dispose()
    return $bmp
  }
}

#getVimRect | capture | % { $_.save("screen.png") }
getVimRect $margin | capture
