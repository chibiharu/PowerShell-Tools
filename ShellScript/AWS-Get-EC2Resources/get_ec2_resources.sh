#######################################################################################
#
# <スクリプト名>
# EC2インスタンスリソース情報取得スクリプト
#
# <概要>
# 特定タグで指定されているEC2インスタンスの指定のリソース情報を取得する
#
# <更新履歴>
# 20220212 - 新規作成
#
#######################################################################################
#!/bin/bash


#####################################################################
## 事前設定
#####################################################################

# カレントディレクトリのパスを取得
CURRENT=$(cd $(dirname $0);pwd)

# 現在の時刻を取得
nowtime=$(date "+%Y%m%d%H%M%S")


######################################################################
## パラメータ設定
######################################################################

# 設定ファイル
InputFile="${CURRENT}/input/target_resources.conf"

# 変数読み込み用一時ファイル
TempFile="${CURRENT}/input/Temporary.conf"

# 一時出力先ファイル
OutTempFile="${CURRENT}/input/OutTemp.conf"

# 出力先ファイル
OutputFile="${CURRENT}/output/EC2Resources_${nowtime}.conf"


######################################################################
## パラメータ取得
######################################################################

### 設定ファイルを読み込み ###
while read line || [ -n "${line}" ]; 
do
  ## 先頭文字が「null」「#」「[」を除外
  if [[ -z ${line} ]]; then
    # 無視する
    continue
  elif [ ${line:0:1} = "[" ] || [ ${line:0:1} = "#" ]; then
    # 無視する
    continue
  fi
  ## 先頭文字(「true」「false」「TAGS」)によって変数に格納するか判断する
  # 「TAGS」の場合
  if [ ${line:0:4} = "TAGS" ]; then
    param=`echo $line | sed -e "s/TAGS //g"`
    echo ${param} >> ${TempFile}
  # 「true」の場合
  elif [ ${line:0:4} = "true" ]; then
    param=`echo $line | sed -e "s/true //g"`
    echo ${param} >> ${TempFile}
  # 「false」の場合
  else
    # 無視する
    continue
  fi
done < ${InputFile}

# 一時ファイルを読み込み最終行の「,」を削除
sed -i -e "$ s/,//g" ${TempFile} 

# 一時ファイルから変数を取得
source ${TempFile}


######################################################################
## メイン処理
######################################################################
aws ec2 describe-instances --query "Reservations[].Instances[].[${tag}${InstanceId}${InstanceType}${ImageId}${KeyName}${AvailabilityZone}${PrivateIpAddress}${PublicIpAddress}${State}${VpcId}${SubnetId}]" \
--output text \
--filters "Name=tag:${Key},Values=${Value}" \
>> ${OutTempFile}

# 可視性を考慮して、column -tで開始行を揃える
cat ${OutTempFile} | column -t > ${OutputFile}


######################################################################
## 後処理
######################################################################
# 一時ファイルの削除
rm -rf ${TempFile}

# 一時出力先ファイルを削除
rm -rf ${OutTempFile}