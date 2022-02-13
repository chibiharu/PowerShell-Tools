## TootTitle：AWS-Get-EC2Resources
指定のタグが登録されてるEC2インスタンスの任意のリソース情報を取得する

## リソース説明
- get_ec2_resources.sh<br>
メインスクリプト<br>
- input<br>
設定ファイルや処理中に作成される一時ファイルを格納する<br>
- output<br>
出力先ファイルを格納する<br>

## 使用方法
- 手順１：設定ファイルをエディタで開く<br>
```bash
$ vim ~./input/target_resources.conf
```
- 手順２：各セクションの説明に従い設定ファイルを修正する<br>
(例：TagName,InstanceID,PublicIP,PrivateIPを取得する)<br>
```bash
##### Welcome!!! #####
############################
# Section=[Tgas]
# Describe:
# 対象インスタンスへ登録したタグ(Key/Value)を指定する
############################
[Tags]
TAGS Key="GetResourcesTag"
TAGS Value="Target"

############################
# Section=[ResourcesParameters]
# Describe:
# 取得するリソースの種類を指定する
# true = 取得する
# false = 取得しない
############################
[ResourcesParameters]
true tag="Tags[?Key=='Name'] | [0].Value,"
true InstanceId="InstanceId,"
false InstanceType="InstanceType,"
false ImageId="ImageId,"
false KeyName="KeyName,"
false AvailabilityZone="lacement.AvailabilityZone,"
true PrivateIpAddress="PrivateIpAddress,"
true PublicIpAddress="PublicIpAddress,"
false State="State.Name,"
false VpcId="VpcId,"
false SubnetId="SubnetId,"
```
- 手順３：メインスクリプトを実行する
```bash
# メインスクリプトを実行する
$ ~./get_ec2_resources.sh
```
## 動作確認
出力先ファイルを確認する
```bash
# 出力先ファイルを確認する
$ cat ~./output/EC2Resources_20220213042348.conf
testserver-1a  i-xxxxxxxxxxxxxxxxx  192.168.xx.xx  xx.xx.xx.xx(PublicIP)
testserver-1c  i-xxxxxxxxxxxxxxxxx  172.16.xx.xx   None
```
