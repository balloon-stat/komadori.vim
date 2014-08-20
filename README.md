komadori.vim
============

Vimの作業画面をコマ撮りでGIFアニメにします。  
WindowsではPowerShellをX Window SystemではImageMagickを使います。  
そのため、それぞれの挙動が少し異なります。  

他にはvimprocも必要とします。  
X Window SystemではImageMagickとxdotool、xwininfoも必要です。  

下記の関数をキーにマップするか直接呼んで使ってください。  
基本的には`komadori#capture()`を繰り返し行い  
最後に`komadori#bundle()`を実行すると  
GIFファイルが`g:komadori_save_file`の値のファイルとして作られます。  


---

```
komadori#capture()
```

画面を撮ります。  

---

```
komadori#bundle()
```

コマ撮りを終わりGIF画像をまとめます。  

---

```
komadori#keep()
```

（Windowsのみ）  
その前に撮った画面を 1 回分長く表示するようにします。  

---

```
komadori#insert()
```

実行するとキー入力があるまで待ちます。  
キーが押されたらインサートモードになり、CursorMoveIイベントで`komadori#capture()`します。  
インサートモードを抜けると、`komadori#bundle()`を実行し終わります。  

---

```
komadori#periodic(time)
```

`time`ミリ秒の間隔でキャプチャを繰り返します。  
一応300カウントで自動的に終わるようになっていますが、大きくメモリを使うため  
メモリが少ないPCの場合、特に気を付けて使ってください。  

WindowsではPowerShellが立ち上がります。  

他の環境ではshがバックグラウンドで起動します。  
そのため`komadori#finish_periodic()`を実行して終わらせてください。  

---

```
komadori#finish_periodic()
```

（Windows以外）  
`komadori#periodic()`によって起動したプロセスを止めて  
GIFファイルを作ります。  

---

```
komadori#pause_periodic()
```

（vimserverを使っているときのみ）  
`komadori#periodic()`によって始めた自動キャプチャの  
ポーズを行います。  

---

```
komadori#restart_periodic()
```

（vimserverを使っているときのみ）  
`komadori#pause_periodic()`によってポーズしているキャプチャを  
再開します。  

---

#### グローバル変数

 `g:komadori_save_file`     保存するファイルの名前 `~/vim.gif`  
 `g:komadori_temp_dir`      一時的な画像ファイルを置くディレクトリ `~/`  
 `g:komadori_interval`      1 フレーム当たりの時間 `40` 10 ミリ秒単位  
 `g:komadori_margin_left`   ウィンドウの左の余白  Win32 `8`   X  `0`  
 `g:komadori_margin_top`    ウィンドウの上の余白  Win32 `82`  X  `0`  
 `g:komadori_margin_right`  ウィンドウの右の余白  Win32 `8`   X  `0`  
 `g:komadori_margin_bottom` ウィンドウの下の余白  Win32 `8`   X  `0`  
 
 [X Window Systemのみ]  
 `g:komadori_use_vimserver` default `1`  
 `1`のとき`komadori#preriodic()`で vim を使う  
 `0`のとき`komadori#preriodic()`で sh を使う  

