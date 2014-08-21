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
念のため 300カウントで自動的に終わるようになっています。  

最後に`komadori#finish_periodic()`を実行して終わらせてください。  

---

```
komadori#finish_periodic()
```

`komadori#periodic()`によって起動したプロセスを止めて  
GIFファイルを作ります。  

---

```
komadori#pause_periodic()
```

（`g:komadori_use_python`が`1`のときのみ）  
`komadori#periodic()`によって始めた自動キャプチャの  
ポーズを行います。  

---

```
komadori#restart_periodic()
```

（`g:komadori_use_python`が`1`のときのみ）  
`komadori#pause_periodic()`によってポーズしているキャプチャを  
再開します。  

---

```
komadori#gyazo_post()
```

Gyazo.com に`g:komadori_save_file`の値のファイルを投稿します。  

---

```
komadori#gyazo_url()
```

Gyazo.comに最後に投稿した画像のURLを返します。  

---

```
komadori#open_gyazo_url()
```

openbrowser.vimで  
Gyazo.comに最後に投稿した画像のURLを開きます。  

---

#### グローバル変数

 `g:komadori_save_file`     保存するファイルの名前 `~/vim.gif`  
 `g:komadori_temp_dir`      一時的な画像ファイルを置くディレクトリ `~/`  
 `g:komadori_interval`      1 フレーム当たりの時間 `40` 10 ミリ秒単位  
 `g:komadori_margin_left`   ウィンドウの左の余白  Win32 `8`   X  `0`  
 `g:komadori_margin_top`    ウィンドウの上の余白  Win32 `100` X  `0`  
 `g:komadori_margin_right`  ウィンドウの右の余白  Win32 `8`   X  `0`  
 `g:komadori_margin_bottom` ウィンドウの下の余白  Win32 `8`   X  `0`  
 
 `g:komadori_use_python` default `1`  
 `1`のとき`komadori#preriodic()`で if_python を使う  
 `0`のとき`komadori#preriodic()`で sh または PowerShell を使う  

#### コマンドリスト

 ComadoriStartPeriodic   
 ComadoriFinishPeriodic  
 ComadoriCapture         
 ComadoriBundle          
 ComadoriInsert          
 ComadoriGyazoPost       
 ComadoriYankGyazoUrl    
 ComadoriOpenGyazoUrl    
