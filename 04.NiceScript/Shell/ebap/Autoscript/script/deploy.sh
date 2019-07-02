#!/bin/bash
# 根据前台传入的配置文件路径,版本包名分发部署软件版本
# deploy.sh $AppDeployPath $pkg_name $deploy_conf $conf_name $remoteDeployScript
# 部署参数说明：
#   $1——部署包下载存放目录(分发部署目录):$WORKSPACE/deploy
#   $2——部署包名:ebap_sit_201808060935_1049
#   $3——部署配置文件目录
#   $4——部署配置文件名字
#   $5——app部署入口脚本：/home/app/run/deployStart.sh

# 脚本命令是否执行成功
is_suc ()
{
    if [ $? -eq 0 ]; then
        echo "[INFO] $@ 执行完毕！"
    else
        echo "[ERROR]" "$@ 执行失败！请核查..."
        exit 1
    fi
}
# 参数校验
echo [INFO:]校验部署包目录是否存在
if [ ! -e $WORKSPACE/Software/${SoftwareFileName} ]; then
	echo "ERROR" "[LINE $LINENO] 部署包文件["$WORKSPACE/Software/${SoftwareFileName}"]不存在"
	exit 1
fi
		
echo [INFO:]校验部署配置文件是否存在
if [ ! -e $WORKSPACE/Autoscript/deployConf/deployConf.ini ]; then
    echo "ERROR" "[LINE $LINENO] 部署配置文件["$WORKSPACE/Autoscript/script/deployConf.ini"]不存在"
    exit 1
fi

cd $WORKSPACE/Software
echo [INFO:]校验传入MD5值是否和${SoftwareFileName}文件生成的MD5数据值一样,如果一样开始解压缩,否则报错退出流程
md5valuetmp=`md5sum ${SoftwareFileName}|awk '{print $1}'|tr '[a-z]' '[A-Z]'`
echo "md5valuetmp值：" "$md5valuetmp"
SoftwareMd5ToUppercase=`echo $SoftwareMd5|tr '[a-z]' '[A-Z]'`
echo "SoftwareMd5ToUppercase值：" "$SoftwareMd5ToUppercase"
if [[ "$md5valuetmp" != "$SoftwareMd5ToUppercase" ]];then
   echo "[ERROR]" "md5值校验不通过,请核查！！！"
   exit 1
else
   echo "md5值校验通过！"
fi

echo [INFO:] 解压缩待发布软件包...
#获取待发布软件包文件名称,不含扩展名后缀
SoftwareFile=`echo ${SoftwareFileName}|awk -F"." '{print $1}'` 
if [ ! -e ./${SoftwareFile} ];then
	mkdir ./${SoftwareFile}
fi
tar -xvf ${SoftwareFileName} -C ./${SoftwareFile}
is_suc "tar -xvf ${SoftwareFileName} -C ./${SoftwareFile}"

# 解析配置文件内容,执行部署流程
echo "[INFO：重要]=================开始解析组件包部署配置文件,生成软件部署分发清单,执行部署流程================="

for line in $(cat $WORKSPACE/Autoscript/deployConf/deployConf.ini)
    do		
		echo " " #打印空行作为分隔线
		#DEV|10.16.1.90|app|~/JenkinsAutodeploy|jar|mcht-*.jar|order-*.jar
		echo "[INFO]根据配置文件执行部署(回退)[${line//|/ }]"
		echo "[DATE]`date`"
		IFS='|' arr=($line)
			if [ "x${DeployMethod}" = "xUPDATE" ]; then
				echo "[INFO：][${DeployEnv}环境] ${arr[1]} ${arr[4]}类型应用：执行版本升级开始！☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆"

				echo "[INFO：](1)拷贝应用服务器部署脚本到远端,生成版本升级列表"
				if ssh ${arr[2]}@${arr[1]} "test -e ${arr[3]}/update/$VersionDate"; then
					echo "[ERROR]:应用服务器[${arr[1]}]目标版本构建目录 ${arr[3]}/update/$VersionDate 已部署,请选择新的构建VersionDate执行部署！"
					exit 1
				fi
				ssh ${arr[2]}@${arr[1]} "mkdir -p ${arr[3]}/update/$VersionDate/sh"
				echo "[LINE $LINENO] scp -r $WORKSPACE/Autoscript/remoteDeployScript/* ${arr[2]}@${arr[1]}:${arr[3]}/update/$VersionDate/sh/"
				scp -r $WORKSPACE/Autoscript/remoteDeployScript/* ${arr[2]}@${arr[1]}:${arr[3]}/update/$VersionDate/sh/
				is_suc "scp -r $WORKSPACE/Autoscript/remoteDeployScript/* ${arr[2]}@${arr[1]}:${arr[3]}/update/$VersionDate/sh/"
				echo ssh ${arr[2]}@${arr[1]} "chmod +X -R ${arr[3]}/update/$VersionDate/sh/*"	
				ssh ${arr[2]}@${arr[1]} "chmod +X -R ${arr[3]}/update/$VersionDate/sh/*"
				is_suc "chmod +X -R ${arr[3]}/update/$VersionDate/sh/*"

				echo "[INFO：](2)将待发布应用文件分发到对应应用服务器"				
				echo "应用服务器归档目录存在即先删除再新建目录,如果不存在,则新建目录以归档"
				tmp_arr3=${arr[3]}/update/$VersionDate/${arr[4]}
				echo ssh ${arr[2]}@${arr[1]} "mkdir -p ${tmp_arr3}"
				ssh ${arr[2]}@${arr[1]} "mkdir -p ${tmp_arr3}"
				is_suc "mkdir -p ${tmp_arr3}"				
				cd $WORKSPACE/Software/$SoftwareFile/${arr[4]}s
				echo "打印当前工作目录:"`pwd`
				echo "[INFO] 显示当前目录下待发布应用文件列表:"`ls -l`
				# 获取基础数组arr中下标5及以后的变量为该应用服务器上的待发布应用列表
				echo "[INFO：] 分发待发布版本到应用服务器..."
				IFS=' ' arr_apps=(${arr[*]:5})				
				for ((i=0;i<${#arr_apps[*]};i++))
					do
						scp `echo ${arr_apps[i]}` ${arr[2]}@${arr[1]}:${tmp_arr3}/
						if ssh ${arr[2]}@${arr[1]} "test ! -e ${tmp_arr3}/`echo ${arr_apps[i]}`"; then
							echo "[ERROR]:scp `echo ${arr_apps[i]}` ${arr[2]}@${arr[1]}:${tmp_arr3}/  执行失败，程序退出！"
							exit 1
						fi
						echo "[INFO]:""scp `echo ${arr_apps[i]}` ${arr[2]}@${arr[1]}:${tmp_arr3}/ 执行完毕！"
				done
				echo "[INFO：] 拷贝软件包构建日志信息到环境"
				scp $WORKSPACE/Software/$SoftwareFile/gitinfo.log ${arr[2]}@${arr[1]}:${arr[3]}/update/$VersionDate/gitinfo.log

				echo "[INFO：]:(3)开始执行远程部署..."	
				echo ssh ${arr[2]}@${arr[1]} "sh ${arr[3]}/update/$VersionDate/sh/deployStart.sh $DeployMethod ${arr[4]} $VersionDate"
				ssh ${arr[2]}@${arr[1]} "sh ${arr[3]}/update/$VersionDate/sh/deployStart.sh $DeployMethod ${arr[4]} $VersionDate"
				is_suc "sh ${arr[3]}/update/$VersionDate/sh/deployStart.sh $DeployMethod ${arr[4]} $VersionDate"

				echo "*****[INFO]:执行版本升级流程完毕！"
				echo "*****[DATE]:`date`"
			elif [ "x${DeployMethod}" = "xROLLBACK" ]; then
				echo "[INFO：][${DeployEnv}环境] ${arr[1]} ${arr[4]}类型应用：执行版本回退开始！☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆"
				
				echo "[INFO：](1)拷贝应用服务器部署脚本到远端,生成版本回退列表"
				if ssh ${arr[2]}@${arr[1]} "test -e ${arr[3]}/rollback/$VersionDate"; then
					echo "[ERROR]:应用服务器[${arr[1]}]目标版本构建目录 ${arr[3]}/rollback/$VersionDate 已回退,请选择新的构建VersionDate执行回退！"
					exit 1
				fi
				ssh ${arr[2]}@${arr[1]} "mkdir -p ${arr[3]}/rollback/$VersionDate/sh"
				echo "[LINE $LINENO] scp -r $WORKSPACE/Autoscript/remoteDeployScript/* ${arr[2]}@${arr[1]}:${arr[3]}/rollback/$VersionDate/sh/"
				scp -r $WORKSPACE/Autoscript/remoteDeployScript/* ${arr[2]}@${arr[1]}:${arr[3]}/rollback/$VersionDate/sh/
				is_suc "scp -r $WORKSPACE/Autoscript/remoteDeployScript/* ${arr[2]}@${arr[1]}:${arr[3]}/rollback/$VersionDate/sh/"
				echo ssh ${arr[2]}@${arr[1]} "chmod +X -R ${arr[3]}/rollback/$VersionDate/sh/*"	
				ssh ${arr[2]}@${arr[1]} "chmod +X -R ${arr[3]}/rollback/$VersionDate/sh/*"
				is_suc "chmod +X -R ${arr[3]}/rollback/$VersionDate/sh/*"

				echo "[INFO：](2)将待发布应用文件分发到对应应用服务器"				
				echo "应用服务器归档目录存在即先删除再新建目录,如果不存在,则新建目录以归档"
				tmp_arr3=${arr[3]}/rollback/$VersionDate/${arr[4]}
				echo ssh ${arr[2]}@${arr[1]} "mkdir -p ${tmp_arr3}"
				ssh ${arr[2]}@${arr[1]} "mkdir -p ${tmp_arr3}"
				is_suc "mkdir -p ${tmp_arr3}"				
				cd $WORKSPACE/Software/$SoftwareFile/${arr[4]}s
				echo "打印当前工作目录:"`pwd`
				echo "[INFO] 显示当前目录下待发布应用文件列表:"`ls -l`
				# 获取基础数组arr中下标5及以后的变量为该应用服务器上的待发布应用列表
				echo "[INFO：] 分发待发布版本到应用服务器,仅用于生成版本回退列表,版本文件不会被部署..."
				IFS=' ' arr_apps=(${arr[*]:5})				
				for ((i=0;i<${#arr_apps[*]};i++))
					do
						scp `echo ${arr_apps[i]}` ${arr[2]}@${arr[1]}:${tmp_arr3}/
						if ssh ${arr[2]}@${arr[1]} "test ! -e ${tmp_arr3}/`echo ${arr_apps[i]}`"; then
							echo "[ERROR]:scp `echo ${arr_apps[i]}` ${arr[2]}@${arr[1]}:${tmp_arr3}/  执行失败，程序退出！"
							exit 1
						fi
						echo "[INFO]:""scp `echo ${arr_apps[i]}` ${arr[2]}@${arr[1]}:${tmp_arr3}/ 执行完毕！"
				done
				
				echo "[INFO：]:(3)开始执行远程回退..."
				echo ssh ${arr[2]}@${arr[1]} "sh ${arr[3]}/rollback/$VersionDate/sh/deployStart.sh $DeployMethod ${arr[4]} $VersionDate"
				ssh ${arr[2]}@${arr[1]} "sh ${arr[3]}/rollback/$VersionDate/sh/deployStart.sh $DeployMethod ${arr[4]} $VersionDate"
				is_suc "sh ${arr[3]}/rollback/$VersionDate/sh/deployStart.sh $DeployMethod ${arr[4]} $VersionDate"				
				echo "*****[INFO]:执行版本回退流程完毕！"
				echo "*****[DATE]:`date`"
			else
				echo "[ERROR][LINE $LINENO] 软件发布策略(DeployMethod)界面入参错误，请核查！"
				exit 1
			fi
done
