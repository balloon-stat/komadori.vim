komadori.vim
============

create animated gif file to screen capture of gvim in Windows  
GVim�̍�Ɖ�ʂ�GIF�A�j�������܂��BWindows��p�ł��B  

���L�̊֐����L�[�Ƀ}�b�v���邩���ڌĂ�Ŏg���Ă��������B  

```
komadori#start()
```

�R�}�B����J�n���܂��B

```
komadori#capture()
```

��ʂ��B��܂��B

```
komadori#stop()
```

�R�}�B����I���AGIF�t�@�C�����쐬���܂��B

```
komadori#oneshot()
```

���݂̉�ʂ�GIF�t�@�C���ɂ��܂��B

```
komadori#insert()
```

`komadori#start()`�����s���A�L�[���������܂ő҂��܂��B  
�L�[���������ƃC���T�[�g���[�h�ɂȂ�ACursorMoveI�C�x���g��`komadori#capture()`���܂��B  
�C���T�[�g���[�h�𔲂���ƁA`komadori#stop()`�����s���I���܂��B  

```
komadori#periodic(time)
```

`komadori#start()`�����s���A`time`�~���b�̊Ԋu��`komadori#capture()`���܂��B  
�ꉞ300�J�E���g�Ŏ����I�ɏI���悤�ɂȂ��Ă��܂����A�傫�����������g������  
�����������Ȃ�PC�̏ꍇ�A���ɋC��t���Ďg���Ă��������B  


#### �O���[�o���ϐ�

 `g:komadori_save_file`     �ۑ�����t�@�C���̖��O `~/vim.gif`
 `g:komadori_periodic`      0 �łȂ��ꍇ�A���̊Ԋu�ŃL���v�`�����J��Ԃ� `0` �~���b�P��
 `g:komadori_interval`      1 �t���[��������̎��� `30` 10 �~���b�P��
 `g:komadori_margin_left`   �E�B���h�E�̍��̗]�� `8`
 `g:komadori_margin_top`    �E�B���h�E�̏�̗]�� `82`
 `g:komadori_margin_right`  �E�B���h�E�̉E�̗]�� `8`
 `g:komadori_margin_bottom` �E�B���h�E�̉��̗]�� `8`
