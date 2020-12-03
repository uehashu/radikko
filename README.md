Radikko
=======

Radiko を簡単に録音するようなシステム．


Requirement
-----------
### Ruby ###
Ruby on Rails 6.0 なので，Ruby のバージョンは2.5以上が必要．

### redis ###
特に指定はないよ．
録音のスケジューリングに使っている Sidekiq のバックエンドとして必要．
Radikko と連動して redis が起動するようにはなっていないので，他の方法で起動しておいてね！

### Node.js ###
javascript エンジン．

### ffmpeg ###
録音に必要．

### MP4Box ###
コンテナ入れ替えに必要．
FreeBSD だったら `pkg install gpac-mp4box` で入る．
ubuntu だったら `apt install gpac` で入る．

### TagLib ###
曲名つけたりとか．
FreeBSD だったら `pkg install taglib` で入る．
ubuntu だったら `apt install libtag1-dev` で入る．

### bundler ###
インストールするのに使う．
FreeBSD だったら `pkg install rubygem-bundler~ で入る．

### yarn ###
`production` 環境において `assets:precompile` する際に必要になる．
ubuntu ではややこしいことに，`apt` でインストールされる yarn は我々が必要な yarn ではない．
リポジトリを追加すれば `apt` でインストールできる．
詳しくは https://classic.yarnpkg.com/ja/docs/install/#debian-stable を見る．

### nokogiri for ubuntu ###
nokogiri を使っている．
ubuntu だとエラーが出るようなので，
```
apt install build-essential liblzma-dev patch ruby-dev zlib1g-dev
```
をやっておく

### sqlite3 for ubuntu ###
sqlite3 を使っている．
ubuntu だとエラーが出るようなので，
```
apt install sqlite3 libsqlite3-dev
```
をやっておく．


How to Use
----------

実行環境により，ほとんどの動作は `sudo -u www-data` とかで動かすべきかもしれない．

1. 上述の依存パッケージを導入しておく．
2. `git clone` してくる．`/var/www/` とかでやるべきかもしれない．
3. `bundle install` で gem を持ってくる．（環境を汚したくない場合は `bundle install --path vendor/bundle`）
4. db を作る．`bundle exec rails db:migrate` で．production 環境であれば，`bundle exec rails db:migrate RAILS_ENV=production`で．
5. エリア ID を格納し，初回のクロールを行う．`bundle exec rails db:seed` もしくは `bundle exec rails db:seed RAILS_ENV=production`
6. 番組表を自動的に更新するために，インストールする際に whenever を用いて crontab を 自動生成する．`bundle exec whenever -w` で．
7. `bundle exec foreman start` で production 環境で動く．development 環境で
動かすときは `bundle exec foreman start -f Procfile.development` で．

systemd や upstart のスクリプトは `bundle exec foreman export -a radikko -u www-data FORMAT /STARTUP.d/` とかで
出力できる．ubuntu だったら `bundle exec foreman export -a radikko -u www-data systemd /etc/systemd/syste` で，`systemd enable radikko.target` みたいな．


For Production environment
--------------------------
credentials が必要になるので，初回のみ
`EDITOR=vim bundle exec rails credentials:edit` する（編集は必要ない）．

precompiled assets が必要になるので，新しいコミットを取り込むたびに
`bundle exec rails assets:precompile` するようにする．

Production 環境で動かすとき，assets は Puma から提供されないので，
フロントエンドサーバから `public/assets` へ直接向ける．



注意点
------
サーバがちゃんと JST かどうかは確認しておく．

フロントエンドサーバを介さずに直接使いたいときは，
`config/environments/production.rb` を以下のように書き換える．
```
config.public_file_server.enabled = true
```
