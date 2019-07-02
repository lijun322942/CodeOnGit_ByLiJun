#!/bin/bash
# 该脚本作为软件部署入口脚本,通过解析当前任务部署包的地址和应用文件地址作为两个传参调用部署任务脚本
# sh ${arr[3]}/$VersionDate/sh/deployStart.sh $DeployMethod ${arr[4]} $VersionDate
# ftp取包参数说明：
#   $1——部署策略,分为UPDATE/ROLLBACK升级和回退
#   $2——部署应用类型,jar/war
#   $3——版本部署日期:以20190418为例,用于发布前版本备份和版本回退取用

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

#打印脚本当前工作目录
echo "[LINE $LINENO] 应用服务器当前工作目录为:`pwd`"
# 基于待发布包生成应用发布(回退)列表
if [ "x$1" = "xUPDATE" ]; then
	dir ~/JenkinsAutodeploy/update/$3/$2/ > ~/JenkinsAutodeploy/update/$3/UpdateList.txt
	apps=`cat ~/JenkinsAutodeploy/update/$3/UpdateList.txt`
elif [ "x$1" = "xROLLBACK" ]; then
	dir ~/JenkinsAutodeploy/rollback/$3/$2/ > ~/JenkinsAutodeploy/rollback/$3/RollbackList.txt
	apps=`cat ~/JenkinsAutodeploy/rollback/$3/RollbackList.txt`
fi

if [ -z $2 ];then
	echo "[ERROR] 部署应用类型为空,应为jar或者war,请核查!!!"
	exit 1
else
	if [ "x$2" = "xjar" ]; then
		#jar类型应用执行comm常规部署策略,调用CommDeploy.sh
		for app in $apps
			do
			if [ "x$1" = "xUPDATE" ]; then
				echo "**************************************************"
				echo "*******[APP] ${app} 版本部署开始!"
				echo "*******[DATE]:`date`"
				echo "**************************************************"
				# 版本升级入参顺序 $1=sysinfo;stop;backup;update;start;
				# 打印环境参数信息
				sh ~/JenkinsAutodeploy/update/$3/sh/CommDeploy.sh "sysinfo" $app $3
				is_suc "sh ~/JenkinsAutodeploy/update/$3/sh/CommDeploy.sh "sysinfo" $app $VersionDate"
				# 停止服务
				sh ~/JenkinsAutodeploy/update/$3/sh/CommDeploy.sh "stop" $app $3
				is_suc "[LINE $LINENO] sh ~/JenkinsAutodeploy/update/$3/sh/CommDeploy.sh "stop" $app" $3
				# 备份基础版本
				sh ~/JenkinsAutodeploy/update/$3/sh/CommDeploy.sh "backup" $app $3
				is_suc "[LINE $LINENO] sh ~/JenkinsAutodeploy/update/$3/sh/CommDeploy.sh "backup" $app" $3
				# 替换版本文件
				sh ~/JenkinsAutodeploy/update/$3/sh/CommDeploy.sh "update" $app $3
				is_suc "[LINE $LINENO] sh ~/JenkinsAutodeploy/update/$3/sh/CommDeploy.sh "update" $app" $3
				# 启动服务
				sh ~/JenkinsAutodeploy/update/$3/sh/CommDeploy.sh "start" $app $3
				is_suc "[LINE $LINENO] sh ~/JenkinsAutodeploy/update/$3/sh/CommDeploy.sh "start" $app" $3			
				echo "*******[APP] ${app} 版本部署完毕!"
				echo "*******[DATE]:`date`"
			elif [ "x$1" = "xROLLBACK" ]; then
				# 版本回退入参顺序 $1=sysinfo;stop;rollback;start;
				echo "[LINE $LINENO] ${app} 版本回退开始 `date`"
				# 打印环境参数信息
				sh ~/JenkinsAutodeploy/rollback/$3/sh/CommDeploy.sh "sysinfo" $app $3
				is_suc "[LINE $LINENO] sh ~/JenkinsAutodeploy/rollback/$3/sh/CommDeploy.sh "sysinfo" $app $3"
				# 停止服务
				sh ~/JenkinsAutodeploy/rollback/$3/sh/CommDeploy.sh "stop" $app $3
				is_suc "[LINE $LINENO] sh ~/JenkinsAutodeploy/rollback/$3/sh/CommDeploy.sh "stop" $app $3"
				# 回退版本文件
				sh ~/JenkinsAutodeploy/rollback/$3/sh/CommDeploy.sh "rollback" $app $3
				is_suc "[LINE $LINENO] sh ~/JenkinsAutodeploy/rollback/$3/sh/CommDeploy.sh "rollback" $app $3"
				# 启动服务
				sh ~/JenkinsAutodeploy/rollback/$3/sh/CommDeploy.sh "start" $app $3
				is_suc "[LINE $LINENO] sh ~/JenkinsAutodeploy/rollback/$3/sh/CommDeploy.sh "start" $app $3"
				echo "[LINE $LINENO] ${app} 版本回退完毕 `date`"
				echo ""				
			else
				echo "[ERROR] 部署策略,升级和回退入参错误,应为UPDATE或ROLLBACK,请核查..."
				exit 1
			fi
		done
	elif [ "x$2" = "xwar" ]; then
		#war类型应用执行weblogic部署策略,调用WeblogicDeploy.sh
		for app in $apps
			do
			if [ "x$1" = "xUPDATE" ]; then
				echo "**************************************************"
				echo "*******[APP ] ${app} 版本部署开始!"
				echo "*******[DATE]:`date`"
				echo "**************************************************"
				# 版本升级入参顺序 $1=sysinfo;stop;backup;update;start;
				# 打印环境参数信息
				sh ~/JenkinsAutodeploy/update/$3/sh/WeblogicDeploy.sh "sysinfo" $3
				is_suc "[LINE $LINENO] "
				# 备份基础版本
				sh ~/JenkinsAutodeploy/update/$3/sh/WeblogicDeploy.sh "backup" $app $3
				is_suc "[LINE $LINENO] sh ~/JenkinsAutodeploy/update/$3/sh/WeblogicDeploy.sh "backup" $app" $3
				# 替换版本文件
				sh ~/JenkinsAutodeploy/update/$3/sh/WeblogicDeploy.sh "update" $app $3
				is_suc "[LINE $LINENO] sh ~/JenkinsAutodeploy/update/$3/sh/WeblogicDeploy.sh "update" $app" $3				
			elif [ "x$1" = "xROLLBACK" ]; then
				# 版本回退入参顺序 $1=sysinfo;stop;rollback;start;
				echo "[LINE $LINENO] ${app} 版本回退开始 `date`"
				# 打印环境参数信息
				sh ~/JenkinsAutodeploy/rollback/$3/sh/WeblogicDeploy.sh "sysinfo" $app $3
				is_suc "[LINE $LINENO] sh ~/JenkinsAutodeploy/rollback/$3/sh/WeblogicDeploy.sh "sysinfo" $app $3"
				# 停止服务
				echo sh ~/JenkinsAutodeploy/rollback/$3/sh/WeblogicDeploy.sh "stop" $app $3
				is_suc "[LINE $LINENO] sh ~/JenkinsAutodeploy/rollback/$3/sh/WeblogicDeploy.sh "stop" $app $3"
				# 回退版本文件
				sh ~/JenkinsAutodeploy/rollback/$3/sh/WeblogicDeploy.sh "rollback" $app $3
				is_suc "[LINE $LINENO] sh ~/JenkinsAutodeploy/rollback/$3/sh/WeblogicDeploy.sh "rollback" $app $3"
				# 启动服务
				echo sh ~/JenkinsAutodeploy/rollback/$3/sh/WeblogicDeploy.sh "start" $app $3
				is_suc "[LINE $LINENO] sh ~/JenkinsAutodeploy/rollback/$3/sh/WeblogicDeploy.sh "start" $app $3"
				echo "[LINE $LINENO] ${app} 版本回退完毕 `date`"
				echo ""				
			else
				echo "[ERROR] 部署策略,升级和回退入参错误,应为UPDATE或ROLLBACK,请核查..."
				exit 1
			fi
		done
	else
		echo "[ERROR] 部署应用类型入参错误,应为jar或者war,请核查!!!"
		exit 1
	fi
fi
