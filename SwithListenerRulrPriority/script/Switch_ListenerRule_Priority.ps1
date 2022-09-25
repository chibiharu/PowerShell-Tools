#######################################################################################
# <����>
# AWS ELB�̃��X�i�[���[���̗D�揇�ʂ�؂�ւ���
# 
# <�X�V��>
# �쐬���F20220223
# �ŏI�X�V���F20220223
#
# <�g�p���ɂ����钍�ӎ���>
# �E�{�X�N���v�g�A�y�ѐݒ�t�@�C��(setting.ini)�̕����R�[�h�́uANSI(SJIS)�v���w�肷�邱��
# �E-
#
# <�R�����g>
# �ESorry�y�[�W�̐؂�ւ����ɂ��g�p������
# �E-
#
#######################################################################################


#######################################################################################
# ���O�ݒ�
#######################################################################################

# ���݂̎����iyyyyMMddhhmmss�j���擾
$str_date = Get-Date -Format "yyyyMMddhhmmss"


#######################################################################################
# �p�����[�^
#######################################################################################

# �ݒ�t�@�C��(setting.ini)�p�X
$SettingFile=""

# �ݒ�t�@�C���ǂݍ���
Get-Content ${SettingFile} | where-object {$_ -notmatch '^\s*$'} | where-object {!($_.TrimStart().StartsWith("#"))}| Invoke-Expression

# ���s���O
$output = "$OutputPass/elb_switch_${str_date}.log"


#######################################################################################
# ���C������
#######################################################################################

# ���O���o���o�� 
echo "########## $ Start switch_sorry_page_alb_listrner ##########" | Out-File $output -Append

# AWS CLI�̃o�[�W�������o��
aws --version | Out-File $output -Append

# TagName����ALB��ARN���擾����
$ELBARN=aws elbv2 describe-load-balancers --name ${ALBName} --query 'LoadBalancers[].[LoadBalancerArn]' --output text

# �Ώۂ�ELB�����݂��邩�m�F����
if(${ELBARN} -eq 0 ){
    echo "###### error:${ALBName} �����݂��Ă���܂���B######" | Out-File $output -Append
}else{
    echo "###### info:${ALBName} �����݂��Ă���̂ŁA�㑱�������s���܂��B######" | Out-File $output -Append
}

# �Ώ�ELB�̃��X�i�[ARN���擾
$LISTENER_ARN=$(aws elbv2 describe-listeners --load-balancer-arn ${ELBARN} --query "Listeners[][].[Port,ListenerArn]" --output text)

# �Ώۂ�ELB�Ƀ��X�i�[���������Ă��邩�m�F����
if(${LISTENER_ARN} -eq 0 ){
    echo "###### error:${ALBName}�Ƀ��X�i�[���������Ă���܂���B######" | Out-File $output -Append
}else{
    echo "###### info:${ALBName} �Ɉȉ��̃��X�i�[���������Ă���܂��B�㑱�������s���܂��B######" | Out-File $output -Append
}

# �擾�������X�i�[��ARN�𕪊�����
Write-Output $LISTENER_ARN | Out-File $output -Append
$data = Get-Content $output
$Num=Select-String $LISTENERPort $output | ForEach-Object { $($_ -split":")[2]}
$Num=$Num-1
$DefaultListener=$data[$Num]
$DefaultListener=$DefaultListener -replace $LISTENERPort,""
$DefaultListener=$DefaultListener.Trim()
echo "###### info:�ȉ��̃��X�i�[�ɑ΂��ď��������s���܂��B�㑱�������s���܂��B######" | Out-File $output -Append
echo $DefaultListener | Out-File $output -Append

# ���X�i�[���[����ARN���擾
echo "###### info:�ȉ��̃��X�i�[���[���̃v���C�I���e�B�l��${Priority_After}�ɕύX���܂��B�㑱�������s���܂��B######" | Out-File $output -Append
aws elbv2 describe-rules --listener-arn $DefaultListener --query "Rules[?Priority=='${Priority_Before}'][].[RuleArn]" --output text | Out-File $output -Append
$LISTENERRULE_ARN=$(aws elbv2 describe-rules --listener-arn $DefaultListener --query "Rules[?Priority=='${Priority_Before}'][].[RuleArn]" --output text)

# ���X�i�[���[���̃v���C�I���e�B�l��ύX
aws elbv2 set-rule-priorities  --rule-priorities RuleArn=${LISTENERRULE_ARN},Priority=${Priority_After} | Out-Null

# �Ώۃ��X�i�[�̕ύX��̃��X�i�[���[�����o��
echo "###### info:�Ώۃ��X�i�[�̃��X�i�[���[���ꗗ���o�͂��܂��B�㑱�������s���܂��B######" | Out-File $output -Append
aws elbv2 describe-rules --listener-arn $DefaultListener --query "Rules[][].[Priority,Actions]" --output text | Out-File $output -Append


#######################################################################################
# �㏈��
#######################################################################################

# AWS�N���f���V�������폜
[Environment]::SetEnvironmentVariable("AWS_DEFAULT_REGION", "")
[Environment]::SetEnvironmentVariable("AWS_SECRET_ACCESS_KEY", "")
[Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY_ID", "")

# ���O���o���o��
echo "###### info:�S�Ă̏���������ɏI�����܂����B######" | Out-File $output -Append
echo "########## $ END switch_ListenerRule_Priority ##########" | Out-File $output -Append