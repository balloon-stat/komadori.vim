komadori.vim
============

create animated gif file to screen capture of gvim in Windows  
GVimの作業画面のGIFアニメを作ります。Windows専用です。  

下記の関数をキーにマップするか直接呼んで使ってください。  

```
komadori#start()
```

コマ撮りを開始します。

```
komadori#capture()
```

画面を撮ります。

```
komadori#stop()
```

コマ撮りを終わり、GIFファイルを作成します。

```
komadori#oneshot()
```

現在の画面をGIFファイルにします。

```
komadori#insert()
```

`komadori#start()`を実行し、キーが押されるまで待ちます。  
キーが押されるとインサートモードになり、CursorMoveIイベントで`komadori#capture()`します。  
インサートモードを抜けると、`komadori#stop()`を実行し終わります。  

```
komadori#periodic(time)
```

`komadori#start()`を実行し、`time`ミリ秒の間隔で`komadori#capture()`します。  
一応300カウントで自動的に終わるようになっていますが、大きくメモリを使うため  
メモリが少ないPCの場合、特に気を付けて使ってください。  


#### グローバル変数

 `g:komadori_save_file`     保存するファイルの名前 `~/vim.gif`
 `g:komadori_periodic`      0 でない場合、その間隔でキャプチャを繰り返す `0` ミリ秒単位
 `g:komadori_interval`      1 フレーム当たりの時間 `30` 10 ミリ秒単位
 `g:komadori_margin_left`   ウィンドウの左の余白 `8`
 `g:komadori_margin_top`    ウィンドウの上の余白 `82`
 `g:komadori_margin_right`  ウィンドウの右の余白 `8`
 `g:komadori_margin_bottom` ウィンドウの下の余白 `8`
