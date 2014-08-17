
function SaveAnimatedGif([string]$filename, [Drawing.Bitmap[]]$imgs, [int[]]$delays) {
  Add-Type -AssemblyName System.Drawing
  $wfs = New-Object IO.FileStream($filename, [IO.FileMode]::Create, [IO.FileAccess]::Write, [IO.FileShare]::None)
  $writer = New-Object IO.BinaryWriter($wfs)
  $ms = New-Object IO.MemoryStream

  $hasGlobalColorTable = $false
  $colorTableSize = 0

  $imgsCount = $imgs.Length
  for ($ix = 0; $ix -lt $imgsCount; $ix++) {
    $imgs[$ix].Save($ms, [Drawing.Imaging.ImageFormat]::Gif)
    $ms.Position = 0

    if ($ix -eq 0) {
      $header = [byte[]](ReadBytes $ms 6)
      $writer.Write($header)
      #Global Color Tableがあるか確認
      $screenDescriptor = [byte[]](ReadBytes $ms 7)
      $hasGlobalColorTable = ($screenDescriptor[4] -band 0x80) -ne 0
      if ($hasGlobalColorTable) {
        $colorTableSize = $screenDescriptor[4] -band 0x07
      }
      #Global Color Tableを使わない
      #広域配色表フラグと広域配色表の寸法を消す
      $screenDescriptor[4] = [byte]($screenDescriptor[4] -band 0x78)
      $writer.Write($screenDescriptor)
      $appExt = [byte[]](GetApplicationExtension 0)
      $writer.Write($appExt)
    }
    else {
      #HeaderとLogical Screen Descriptorをスキップ
      $ms.Position += 6 + 7
    }

    $colorTable = $null
    if ($hasGlobalColorTable) {
      $count = [int][Math]::Pow(2, $colorTableSize + 1) * 3
      $colorTable = [byte[]](ReadBytes $ms $count)
    }
    $grfxControlExt = [byte[]](GetGraphicControlExtension $delays[$ix+1])
    $writer.Write($grfxControlExt)
    #基のGraphics Control Extensionをスキップ
    if ($ms.GetBuffer()[$ms.Position] -eq 0x21) {
      $ms.Position += 8
    }
    $imageDescriptor = [byte[]](ReadBytes $ms 10)
    if (!$hasGlobalColorTable) {
      #Local Color Tableを持っているか確認
      if (($imageDescriptor[9] -band 0x80) -eq 0) {
        throw "Not found color table."
      }
      $colorTableSize = $imageDescriptor[9] -band 7
      $count = [int][Math]::Pow(2, $colorTableSize + 1) * 3
      $colorTable = [byte[]](ReadBytes $ms $count)
    }
    #狭域配色表フラグ (Local Color Table Flag) と狭域配色表の寸法を追加
    $imageDescriptor[9] = [byte]($imageDescriptor[9] -bor 0x80 -bor $colorTableSize)
    $writer.Write($imageDescriptor)
    $writer.Write($colorTable)

    $count = [int]($ms.Length - $ms.Position - 1)
    $remain = [byte[]](ReadBytes $ms $count)
    $writer.Write($remain)
    if ($ix -eq $imgsCount - 1) {
      $writer.Write([byte]0x3B)
    }
    #MemoryStreamをリセット
    $ms.SetLength(0)
  }

  $ms.Close()
  $writer.Close()
  $wfs.Close()
}

function ReadBytes([IO.MemoryStream]$ms, [int]$count) {
  $bs = New-Object Byte[] $count
  [void]$ms.Read($bs, 0, $count)
  return $bs
}

function GetApplicationExtension {
  $bs = New-Object Byte[] 19

  #Extension Introducer
  $bs[0] = 0x21
  #Application Extension Label
  $bs[1] = 0xFF
  #Block Size
  $bs[2] = 0x0B
  #Application Identifier
  $bs[3] = [byte][char]'N'
  $bs[4] = [byte][char]'E'
  $bs[5] = [byte][char]'T'
  $bs[6] = [byte][char]'S'
  $bs[7] = [byte][char]'C'
  $bs[8] = [byte][char]'A'
  $bs[9] = [byte][char]'P'
  $bs[10] = [byte][char]'E'
  #Application Authentication Code
  $bs[11] = [byte][char]'2'
  $bs[12] = [byte][char]'.'
  $bs[13] = [byte][char]'0'
  #Data Sub-block Size
  $bs[14] = 0x03
  #[Netscape Extension Code]
  $bs[15] = 0x01
  #Loop Count 0:infinite
  $bs[16] = 0
  $bs[17] = 0
  #Block Terminator
  $bs[18] = 0x00

  return $bs
}

function GetGraphicControlExtension([int]$delay) {
  $bs = New-Object Byte[] 8

  #Extension Introducer
  $bs[0] = 0x21
  #Graphic Control Label
  $bs[1] = 0xF9
  #Block Size
  $bs[2] = 0x04
  #use Transparency Index: 1
  $bs[3] = 0x00
  #Delay Time [10ms]
  $delayTimeBytes = [BitConverter]::GetBytes($delay)
  $bs[4] = $delayTimeBytes[0]
  $bs[5] = $delayTimeBytes[1]
  #Transparency Index, Transparent Color Index
  $bs[6] = 0x00
  #Block Terminator
  $bs[7] = 0x00

  return $bs
}

SaveAnimatedGif $Args[0] $Args[1] $Args[2]

