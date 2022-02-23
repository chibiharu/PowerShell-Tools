## ScriptTitle：SwithListenerRulrPriority
Amazon ELBの特定のリスナーのリスナールールのプライオリティ値を切り替える。<br>
※Sorryページの切り替え等にご使用下さい

## ディレクトリ説明
- input<br>
設定ファイルを格納
- ouput<br>
実行ログの出力先
- script<br>
メインスクリプトを格納

## 使用方法
- 手順1：設定ファイルのパラメータを各項目に従い指定する。
```:setting.ini
#######################################################################################
## 設定ファイル
#######################################################################################
### 実行ログの保管先パスを指定 ###
$OutputPass=""

### 対象ALBのTagNameを指定 ###
$ALBName=""

### リスナーポートを取得 ###
$LISTENERPort=""

### リスナールールの現在のプライオリティ値を指定 ###
$Priority_Before=""

### リスナールールの変更後のプライオリティ値を指定 ###
$Priority_After=""

### AWSクレデンシャル生成 ###
$Env:AWS_ACCESS_KEY_ID=""
$Env:AWS_SECRET_ACCESS_KEY=""
$Env:AWS_DEFAULT_REGION=""
```
- 手順4：メインスクリプトの設定ファイルのパスを指定する
```:Switch_ListenerRule_Priority.ps1
～～～ 略 ～～～
# 設定ファイル(setting.ini)パス
$SettingFile=""
～～～ 略 ～～～
```
- 手順3：メインスクリプトを実行する
```:スクリプト実行コマンド
./Switch_ListenerRule_Priority.ps1
```
- 手順4：実行ログを確認し、スクリプトが正常に終了していることを確認する。
```:実行ログ(例)
$ cat ./elb_switch_20220224124101.log
########## $ Start switch_sorry_page_alb_listrner ##########
aws-cli/2.2.5 Python/3.8.8 Windows/10 exe/AMD64 prompt/off
###### info:<ELB名> が存在しているので、後続処理を行います。######
###### info:<ELB名> に以下のリスナーが所属しております。後続処理を行います。######
443	<リスナールールARN>
80	<リスナールールARN>
###### info:以下のリスナーに対して処理を実行します。後続処理を行います。######
<リスナールールARN>
###### info:以下のリスナールールのプライオリティ値を3に変更します。後続処理を行います。######
<リスナールールの一覧情報をjson形式で出力>
###### info:全ての処理が正常に終了しました。######
########## $ END switch_ListenerRule_Priority ##########
```
***
## 参照
- 自身のQiita
  - [【Powershell】ALBのリスナールールのプライオリティ値を変更しSorryページの切り替えを行うps1を作成]()
- 参考にさせて頂いた記事
  - [ALBのSorryページ切り替えシェルを作成してみました(CLI)](https://cloud5.jp/alb-sorry-page-switch/) 
  - [awscliを使ったALBによるメンテナンス画面表示](https://note.com/udemaex/n/nb012758fd1f8)
