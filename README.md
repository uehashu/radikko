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


Notice
------
### libv8 について ###
内部で使っている libv8 というライブラリだけど, OS ごとに適切なバージョンが違ってて
めんどくさい.
Gemfile で OS を自動的に判別するようにしてるけど, Gemfile.lock も変更しなければならない.

```sudo -u www bundle update libv8```

を実行すれば, 使っている OS に適した libv8 を入れ, Gemfile.lock を適切に更新してくれる.

### wheneverize ###
番組表を自動的に更新するために, インストールする際に whenever を用いて crontab を 自動生成する.

```sudo -u www bundle whenever -w```

を1回実行すればおっけー.
