Radikko
=======

Radiko を簡単に録音するようなシステム．


Requirement
-----------
### ruby ###
2.2以降推奨．
2.1以前だとシンボル GC を積んでいないので，シンボルがガリガリメモリを食っていくよ…！

### redis ###
特に指定はないよ．
録音のスケジューリングに使っている Sidekiq のバックエンドとして必要．
Radikko と連動して redis が起動するようにはなっていないので，他の方法で起動しておいてね！

### Node.js ###
javascript エンジン．

### ffmpeg ###
録音結果からの音声抽出に必要．

### MP4Box ###
コンテナ入れ替えに必要．
FreeBSD であれば，ports を使って multimedia/mp4v2 で入手できる．

### TagLib ###
曲名つけたりとか．
FreeBSD であれば，ports を使って audio/taglib で入手できる．

### bundler ###
インストールするのに使う．
FreeBSD であれば，ports を使って sysutls/rubygem-bundler で入手できる．

### yarn ###
development 環境のときに必要？


How to Use
----------

1. 上述の依存パッケージを導入しておく．
2. `git clone` してくる．
3. `bundle install` で gem を持ってくる．
4. db を作る．`sudo -u www bundle exec rails db:migrate` で．production 環境であれば，`sudo -u www bundle exec rails db:migrate RAILS_ENV=production`で．
5. エリア ID を格納し，初回のクロールを行う．`sudo -u www bundle exec rails db:seed` もしくは `sudo -u www bundle exec rails db:seed RAILS_ENV=production`
6. 番組表を自動的に更新するために，インストールする際に whenever を用いて crontab を 自動生成する．`sudo -u www bundle exec whenever -w` で．
