komadori.vim
============

create animated gif file to screen capture of gvim in Windows by PowerShell or vim in Unix by ImageMagick  
Vimの作業画面のGIFアニメを作ります。  
WindowsではPowerShellをUnixではImageMagickを使います。  
そのため、それぞれの挙動が少し異なります。  

Windows版ではvimprocも使います。  
Unix版はImageMagickとxdotool、xwininfoを必要とします。  

下記の関数をキーにマップするか直接呼んで使ってください。  

```
komadori#capture()
```

画面を撮ります。  


```
komadori#bundle()
```

コマ撮りを終わりGIF画像をまとめます。  

```
komadori#keep()
```

その前に撮った画面を 1 回分長く表示するようにします。  
（Windowsのみ）

```
komadori#insert()
```

実行するとキー入力があるまで待ちます。  
キーが押されたらインサートモードになり、CursorMoveIイベントで`komadori#capture()`します。  
インサートモードを抜けると、`komadori#bundle()`を実行し終わります。  

```
komadori#periodic(time)
```

`time`ミリ秒の間隔でキャプチャを繰り返します。  
一応300カウントで自動的に終わるようになっていますが、大きくメモリを使うため  
メモリが少ないPCの場合、特に気を付けて使ってください。  
（Windowsのみの関数）

#### グローバル変数

 `g:komadori_save_file`     保存するファイルの名前 `~/vim.gif`  
 `g:komadori_interval`      1 フレーム当たりの時間 `40` 10 ミリ秒単位  
 `g:komadori_margin_left`   ウィンドウの左の余白  Win32 `8`   他  `0`  
 `g:komadori_margin_top`    ウィンドウの上の余白  Win32 `82`  他  `0`  
 `g:komadori_margin_right`  ウィンドウの右の余白  Win32 `8`   他  `0`  
 `g:komadori_margin_bottom` ウィンドウの下の余白  Win32 `8`   他  `0`  
 `g:komadori_temp_dir`      一時的な画像ファイルを置くディレクトリ `~/'  

