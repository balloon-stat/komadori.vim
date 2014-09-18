komadori.vim
============

version 0.1.0  

This plugin generates a GIF Animation of your working in Vim.  
For more English information, read doc/komadori.txt.  

vimの作業画面をコマ撮りでGIFアニメにします。  
windowsではPowerShellをX Window SystemではImageMagickを使います。  
そのため、それぞれの挙動が少し異なります。  

x Window SystemではImageMagickとxdotool、xwininfoが必要です。  
非同期で実行させるにはvimprocも必要になります。  

下記の関数をキーにマップするか直接呼んで使ってください。  
基本的には `komadori#capture()` を繰り返し行い  
最後に `komadori#bundle()` を実行すると  
GIFファイルが `g:komadori_save_file` の値のファイルとして作られます。  


---

```
komadori#capture()
```

画面を撮ります。  
一時的なGIFファイルを作って、その旨を表示するため  
エコーさせないようにするには `:silent call komadori#capture()`  
と実行してください。  

---

```
komadori#bundle()
```

コマ撮りを終わりGIF画像をまとめます。  
`g:komadori_save_file` の値のファイルとして作られます。  

---

```
komadori#all_bundle()
```

`g:komadori_temp_dir` にある定型のファイル名のGIF画像をまとめます。  
`g:komadori_save_file` の値のファイルとして作られます。  

---

```
komadori#keep()
```

（PowerShellのみ）  
その前に撮った画面を 1 回分長く表示するようにします。  

---

```
komadori#cmdlist#start()
```

cmdlist に従い実行します。  
cmdlist は１行目に cmdlist と書かれているかどうかで判断されます。  
次の行から : で始まる場合はExコマンドとして  
それ以外はノーマルコマンドとして実行します。  
また１行毎に `komadori#capture()` します。  
cmdlist が終端に達すると `komadori#bundle()` を実行し終わります。  

NOTE: cmdlist のウィンドウと操作対象のウィンドウの２つが必要です。  
NOTE: ウィンドウを新しく開くコマンドはうまく動きません。  

---

```
komadori#insert#start()
```

実行するとキー入力があるまで待ちます。  
キーが押されたらインサートモードになり、CursorMoveIイベントで `komadori#capture()` します。  
インサートモードを抜けると、`komadori#bundle()` を実行し終わります。  

---

```
komadori#periodic#start(time)
```

`time` ミリ秒の間隔でキャプチャを繰り返します。  
念のため 300カウントで自動的に終わるようになっています。  

最後に `komadori#periodic#finish()` を実行して終わらせてください。  

---

```
komadori#periodic#finish()
```

`komadori#periodic#start()` によって起動したプロセスを止めて  
GIFファイルを作ります。  

---

```
komadori#periodic#pause()
```

（ `g:komadori_use_python` が `1` のときのみ）  
`komadori#periodic#start()` によって始めた自動キャプチャの  
ポーズを行います。  

---

```
komadori#periodic#restart()
```

（ `g:komadori_use_python` が `1` のときのみ）  
`komadori#periodic#pause()` によってポーズしているキャプチャを  
再開します。  

---

```
komadori#gyazo#post()
```

gyazo.com に `g:komadori_save_file` の値のファイルを投稿します。  

---

```
komadori#gyazo#url()
```

gyazo.comに最後に投稿した画像のURLを返します。  

---

```
komadori#gyazo#open_url()
```

openbrowser.vimで  
gyazo.comに最後に投稿した画像のURLを開きます。  

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
 `1` のとき `komadori#preriodic()` で if_python を使います。  
 `0` のとき `komadori#preriodic()` で sh または PowerShell を使います。  

 `g:komadori_bundle_use_powershell` default `1`  
 `komadori#bundle()` と `komadori#all_bundle()` と `komadori#periodic#finish` で使われます。  
 Windows で ImageMagick を使って画像をまとめたいときに、  
 この値を `0` にすることで convert が実行されるように設定できます。  
 
 `g:komadori_cursor_blink_control` default `1`
 GVim を使っているときに `komadori#cmdlist#start()` の実行時に  
 カーソルの点滅を止め、終了時にカーソルを点滅させるようにします。  

#### コマンドリスト


 ComadoriStartPeriodic   
 ComadoriFinishPeriodic  
 ComadoriCapture         
 ComadoriBundle          
 ComadoriInsert          
 ComadoriCmdlist         
 ComadoriGyazoPost       
 ComadoriYankGyazoUrl    
 ComadoriOpenGyazoUrl    
