komadori.vim
============

create animated gif file to screen capture of gvim in Windows by PowerShell or vim in Unix by ImageMagick  
Vim�̍�Ɖ�ʂ�GIF�A�j�������܂��B  
Windows�ł�PowerShell��Unix�ł�ImageMagick���g���܂��B  
���̂��߁A���ꂼ��̋����������قȂ�܂��B  

Windows�łł�vimproc���g���܂��B  
Unix�ł�ImageMagick��xdotool�Axwininfo��K�v�Ƃ��܂��B  

���L�̊֐����L�[�Ƀ}�b�v���邩���ڌĂ�Ŏg���Ă��������B  

```
komadori#capture()
```

��ʂ��B��܂��B  


```
komadori#bundle()
```

�R�}�B����I���GIF�摜���܂Ƃ߂܂��B  

```
komadori#keep()
```

���̑O�ɎB������ʂ� 1 �񕪒����\������悤�ɂ��܂��B  
�iWindows�̂݁j

```
komadori#insert()
```

���s����ƃL�[���͂�����܂ő҂��܂��B  
�L�[�������ꂽ��C���T�[�g���[�h�ɂȂ�ACursorMoveI�C�x���g��`komadori#capture()`���܂��B  
�C���T�[�g���[�h�𔲂���ƁA`komadori#bundle()`�����s���I���܂��B  

```
komadori#periodic(time)
```

`time`�~���b�̊Ԋu�ŃL���v�`�����J��Ԃ��܂��B  
�ꉞ300�J�E���g�Ŏ����I�ɏI���悤�ɂȂ��Ă��܂����A�傫�����������g������  
�����������Ȃ�PC�̏ꍇ�A���ɋC��t���Ďg���Ă��������B  
�iWindows�݂̂̊֐��j

#### �O���[�o���ϐ�

 `g:komadori_save_file`     �ۑ�����t�@�C���̖��O `~/vim.gif`  
 `g:komadori_interval`      1 �t���[��������̎��� `40` 10 �~���b�P��  
 `g:komadori_margin_left`   �E�B���h�E�̍��̗]��  Win32 `8`   ��  `0`  
 `g:komadori_margin_top`    �E�B���h�E�̏�̗]��  Win32 `82`  ��  `0`  
 `g:komadori_margin_right`  �E�B���h�E�̉E�̗]��  Win32 `8`   ��  `0`  
 `g:komadori_margin_bottom` �E�B���h�E�̉��̗]��  Win32 `8`   ��  `0`  
 `g:komadori_temp_dir`      �ꎞ�I�ȉ摜�t�@�C����u���f�B���N�g�� `~/'  

