#######################################################################################
# <説明>
# AWS ELBのリスナールールの優先順位を切り替える
# 
# <更新日>
# 作成日：20220223
# 最終更新日：20220223
#
# <使用時における注意事項>
# ・本スクリプト、及び設定ファイル(setting.ini)の文字コードは「ANSI(SJIS)」を指定すること
# ・-
#
# <コメント>
# ・Sorryページの切り替え等にご使用下さい
# ・-
#
#######################################################################################


#######################################################################################
# 事前設定
#######################################################################################

# 現在の時刻（yyyyMMddhhmmss）を取得
$str_date = Get-Date -Format "yyyyMMddhhmmss"


#######################################################################################
# パラメータ
#######################################################################################

# 設定ファイル(setting.ini)パス
$SettingFile=""

# 設定ファイル読み込み
Get-Content ${SettingFile} | where-object {$_ -notmatch '^\s*$'} | where-object {!($_.TrimStart().StartsWith("#"))}| Invoke-Expression

# 実行ログ
$output = "$OutputPass/elb_switch_${str_date}.log"


#######################################################################################
# メイン処理
#######################################################################################

# ログ見出し出力 
echo "########## $ Start switch_sorry_page_alb_listrner ##########" | Out-File $output -Append

# AWS CLIのバージョンを出力
aws --version | Out-File $output -Append

# TagNameからALBのARNを取得する
$ELBARN=aws elbv2 describe-load-balancers --name ${ALBName} --query 'LoadBalancers[].[LoadBalancerArn]' --output text

# 対象のELBが存在するか確認する
if(${ELBARN} -eq 0 ){
    echo "###### error:${ALBName} が存在しておりません。######" | Out-File $output -Append
}else{
    echo "###### info:${ALBName} が存在しているので、後続処理を行います。######" | Out-File $output -Append
}

# 対象ELBのリスナーARNを取得
$LISTENER_ARN=$(aws elbv2 describe-listeners --load-balancer-arn ${ELBARN} --query "Listeners[][].[Port,ListenerArn]" --output text)

# 対象のELBにリスナーが所属しているか確認する
if(${LISTENER_ARN} -eq 0 ){
    echo "###### error:${ALBName}にリスナーが所属しておりません。######" | Out-File $output -Append
}else{
    echo "###### info:${ALBName} に以下のリスナーが所属しております。後続処理を行います。######" | Out-File $output -Append
}

# 取得したリスナーのARNを分割する
Write-Output $LISTENER_ARN | Out-File $output -Append
$data = Get-Content $output
$Num=Select-String $LISTENERPort $output | ForEach-Object { $($_ -split":")[2]}
$Num=$Num-1
$DefaultListener=$data[$Num]
$DefaultListener=$DefaultListener -replace $LISTENERPort,""
$DefaultListener=$DefaultListener.Trim()
echo "###### info:以下のリスナーに対して処理を実行します。後続処理を行います。######" | Out-File $output -Append
echo $DefaultListener | Out-File $output -Append

# リスナールールのARNを取得
echo "###### info:以下のリスナールールのプライオリティ値を${Priority_After}に変更します。後続処理を行います。######" | Out-File $output -Append
aws elbv2 describe-rules --listener-arn $DefaultListener --query "Rules[?Priority=='${Priority_Before}'][].[RuleArn]" --output text | Out-File $output -Append
$LISTENERRULE_ARN=$(aws elbv2 describe-rules --listener-arn $DefaultListener --query "Rules[?Priority=='${Priority_Before}'][].[RuleArn]" --output text)

# リスナールールのプライオリティ値を変更
aws elbv2 set-rule-priorities  --rule-priorities RuleArn=${LISTENERRULE_ARN},Priority=${Priority_After} | Out-Null

# 対象リスナーの変更後のリスナールールを出力
echo "###### info:対象リスナーのリスナールール一覧を出力します。後続処理を行います。######" | Out-File $output -Append
aws elbv2 describe-rules --listener-arn $DefaultListener --query "Rules[][].[Priority,Actions]" --output text | Out-File $output -Append


#######################################################################################
# 後処理
#######################################################################################

# AWSクレデンシャルを削除
[Environment]::SetEnvironmentVariable("AWS_DEFAULT_REGION", "")
[Environment]::SetEnvironmentVariable("AWS_SECRET_ACCESS_KEY", "")
[Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY_ID", "")

# ログ見出し出力
echo "###### info:全ての処理が正常に終了しました。######" | Out-File $output -Append
echo "########## $ END switch_ListenerRule_Priority ##########" | Out-File $output -Append