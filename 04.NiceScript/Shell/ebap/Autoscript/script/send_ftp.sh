#!/bin/bash
# 该脚本用户生成压缩归档版本号，压缩所有软件包，归档ftp服务器目录
# 	send_ftp.sh $WORKSPACE/package $ftp_ip "$ftp_user" "$ftp_pwd" $ftp_dir $softwareUsefor
# 	上传ftp参数说明：
#   	$1——AppPackagePath：待打包目录（编译打包完成后存包目录）:$WORKSPACE/package
#   	$2——ftp_ip：ftp IP地址
#   	$3——ftp_user：ftp用户名
#   	$4——ftp_pwd：ftp用户密码
#   	$5——ftp_dir：ftp上的存包目录
#   	$6——softwareUsefor：打包软件用途类型(dev/sit/product/uat/pet)

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
echo_mine "[LINE $LINENO] 三、开始打包应用包，上传ftp"
#1、时间日期转换脚本，将系统时间（Mon Jul 30 17:42:21 CST 2018）转换为显示（201807301749），为后续包名使用
datetime=`date +%Y%m%d%H%M`
echo_mine "[LINE $LINENO] 本次版本构建时间为：${datetime}"

#2、获取git库代码节点信息，将节点信息归档，为后续包名使用
cd $WORKSPACE/appCode
echo "[Git Log]:" > ./gitinfo.log 
git log -length -1 >> gitinfo.log
gitRevision=`grep ^commit ./gitinfo.log`
echo_mine "[LINE $LINENO] 本次版本构建Git节点号为：${gitRevision}"
gitCodeNode=${gitRevision:7:6}
echo "[Git Branch]: $CodeBranch" >> ./gitinfo.log 

#3、拼接生成包名：ebap_dev_$date_$time_$代码库svn节点号
packge_ver=ebap_${softwareUsefor}_${datetime}_${gitCodeNode}_${CodeBranch}
echo_mine "[LINE $LINENO] 本次版本构建打包版本号名称为：${packge_ver}"

# 参数校验
if [ -z $1 ]; then
    echo_mine "erro" "[LINE $LINENO]参数待打包为空"
    exit 1
fi
if [ -z $2 ]; then
    echo_mine "erro" "[LINE $LINENO]参数ftp地址为空"
    exit 1
fi
if [ -z $3 ]; then
	echo_mine "erro" "[LINE $LINENO]参数ftp_user为空"
    exit 1
fi
if [ -z $4 ]; then
    echo_mine "erro" "[LINE $LINENO]参数ftp_pwd为空"
    exit 1
fi
if [ -z $5 ]; then
    echo_mine "erro" "[LINE $LINENO]参数ftp_dir为空"
    exit 1
fi
if [ -z $6 ]; then
    echo_mine "erro" "[LINE $LINENO]参数softwareUsefor打包软件用途类型为空"
    exit 1
fi

# 校验代打包目录是否存在
if [ ! -e $1 ]; then
    echo_mine "erro" "[LINE $LINENO]待打包["${1}"]目录不存在"
    exit 1
fi

echo_mine "[LINE $LINENO] 输入参数校验通过，开始打包"
# 压缩包
cd ${1}
# 拷贝gitlog仓库节点文件到本地仓库，压缩完整包
cp $WORKSPACE/appCode/gitinfo.log ./gitinfo.log
tar -cvf ${packge_ver}.tar ./*
is_suc "[LINE $(($LINENO-1))] 打包[${packge_ver}.tar]，命令[tar -zcvf ${packge_ver}.tar ${1}/*]"
echo_mine "[LINE $LINENO] 开始上传ftp"

# 生成MD5文件
md5sum ${packge_ver}.tar > ${packge_ver}.tar.md5

# 上传ftp
ftp -n -i $2 <<!
    user $ftp_user $ftp_pwd
    bin
    cd $5
    put ${packge_ver}.tar
    put ${packge_ver}.tar.md5
    bye
!
is_suc "[LINE $(($LINENO-7))] 上传ftp：存包路径[ftp://${2}${5}]，包名[${packge_ver}.tar]"
#执行完毕,退出任务
exit 0
