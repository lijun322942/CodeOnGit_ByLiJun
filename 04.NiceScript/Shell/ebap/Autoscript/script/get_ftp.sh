#!/bin/bash
# 根据前台传入的版本包名从ftp服务器下载版本包，进行MD5校验，解压缩版本包
# get_ftp.sh $AppDeployPath $pkg_name $ftp_ip "$ftp_user" "$ftp_pwd" $ftp_dir
# ftp取包参数说明：
#   $1——AppDeployPath：分发部署目录:$WORKSPACE/deploy
#   $2——ftp服务器上存取app集合包包名（不含后缀）
#   $3——ftp_ip：ftp IP地址
#   $4——ftp_user：ftp用户名
#   $5——ftp_pwd：ftp用户密码
#   $6——ftp_dir：ftp上的存包目录:/upload/ebap/dev

# 命令是否执行成功
is_suc ()
{
    if [ $? -eq 0 ]; then
        echo_mine "$@ is success"
    else
        echo_mine "erro" "$@ is failed!"
        exit 1
    fi
}

# 日志分类打印
echo_mine ()
{
    if [ $# -eq 1 ]; then
         echo "[INFO] $@"
    else
        if [[ "$1" == "erro" ]]; then
            echo "[ERRO] $2"
        elif [[ "$1" == "debug" ]]; then
            echo "[DEBUG] $2"
        else
            echo "[INFO] $2"
        fi
    fi
}

echo_mine "[LINE $LINENO] 开始ftp取包"

# 参数校验
if [ -z $1 ]; then
    echo_mine "erro" "[LINE $LINENO]参数存包目录为空"
    exit 1
fi
if [ -z $2 ]; then
    echo_mine "erro" "[LINE $LINENO]参数包名为空"
    exit 1
fi
if [ -z $3 ]; then
    echo_mine "erro" "[LINE $LINENO]参数ftp IP地址为空"
    exit 1
fi
if [ -z $4 ]; then
	echo_mine "erro" "[LINE $LINENO]参数ftp_user为空"
    exit 1
fi
if [ -z $5 ]; then
    echo_mine "erro" "[LINE $LINENO]参数ftp_pwd为空"
    exit 1
fi
if [ -z $6 ]; then
    echo_mine "erro" "[LINE $LINENO]参数ftp存包目录为空"
    exit 1
fi

# 校验部署分发存包目录是否存在
if [ -e $1 ]; then
    rm -rf $1
	is_suc "[LINE $(($LINENO-1))] 移除存包目录${1}下历史文件"
	mkdir -p $1
    is_suc "[LINE $(($LINENO-1))] 创建存包目录["${1}"]，命令[mkdir -p ${1}]"
else
	mkdir -p $1
	is_suc "[LINE $(($LINENO-1))] 创建存包目录["${1}"]，命令[mkdir -p ${1}]"
fi

echo_mine "[LINE $LINENO] 输入参数校验通过，开始取包"

# ftp用户名/密码默认值
ftp_user=$4
ftp_pwd=$5

# ftp取包
ftp -n -i $3 <<!
    user $ftp_user $ftp_pwd
    bin
    cd $6
    get ${2}.tar.gz
    get ${2}.tar.gz.md5
    bye
!
is_suc "[LINE $(($LINENO-7))] ftp取包：ftp存包路径[${6}]，包名[${2}.tar.gz]"

# 将包移到存包目录
mv ${2}.tar.gz $1
is_suc "[LINE $(($LINENO-1))] 将包移到存包目录[${1}]，包名[${2}.tar.gz]，命令[mv ${2}.tar.gz ${1}]"
# 将包MD5文件移到存包目录
mv ${2}.tar.gz.md5 $1
is_suc "[LINE $(($LINENO-1))] 将包MD5文件移到存包目录[${1}]，包名[${2}.tar.gz]，命令[mv ${2}.tar.gz.md5 ${1}]"

echo_mine "[LINE $LINENO] ftp取包完成"

cd $1
# MD5校验
echo_mine "[LINE $LINENO] MD5校验"
md5sum -c ${2}.tar.gz.md5
is_suc "[LINE $(($LINENO-1))] md5校验，命令[md5sum ${2}.tar.gz -c ${2}.tar.gz.md5]"

# 解包
if [ -e ${1}/${2} ]; then
    rm -rf ${1}/${2}
  else
    mkdir -p ${1}/${2}
fi

pwd
echo_mine "[LINE $LINENO] 开始解包"
tar -zxvf ${2}.tar.gz -C ./${2}
is_suc "[LINE $(($LINENO-1))] 解包[${2}.tar.gz]，命令[tar -zxvf ${2}.tar.gz -C ./${2}]"

exit 0
