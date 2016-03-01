Radikko
=======

Radiko を簡単に録音するようなシステム.


Requirement
-----------
### ruby ###
2.2以降推奨.
2.1以前だとシンボル GC を積んでいないので, シンボルがガリガリメモリを食っていくよ...!

### redis ###
特に指定はないよ.
録音のスケジューリングに使っている Sidekiq のバックエンドとして必要.
Radikko と連動して redis が起動するようにはなっていないので, 他の方法で起動しておいてね!

### Node.js ###
javascript エンジン.

### ffmpeg ###
録音結果からの音声抽出に必要.

### MP4Box ###
コンテナ入れ替えに必要. 

### TagLib ###
曲名つけたりとか. 

Notice
------
### wheneverize ###
番組表を自動的に更新するために, インストールする際に whenever を用いて crontab を 自動生成する.

```sudo -u www bundle whenever -w```

を1回実行すればおっけー.
