#!/bin/bash
# 该脚本为所有任务脚本执行入口脚本，通过传参分发执行到指定脚本任务
# taskStart.sh $script $WORKSPACE
# 部署参数说明：
#   $1——执行具体脚本脚本文件名
#   $2——通过传参生效全局参数脚本

# 执行全局参数脚本，获取全局变量
echo "当前工作目录为:"+`pwd`
echo source $WORKSPACE/Autoscript/env/env.sh
source $WORKSPACE/Autoscript/env/env.sh

# 通过入参判断分别执行到具体脚本
if [[ "$1" == "package" ]]; then
	echo Step1、存包目录清除及创建，执行各项目打包流程
	# -e 检测目录或文件是否存在，存在则返回true
	if [ -e $WORKSPACE/package ]; then
		rm -rf $WORKSPACE/package
		# 创建子目录
		echo "创建存包子目录：jars wars"
		mkdir -p $WORKSPACE/package/jars
		mkdir -p $WORKSPACE/package/wars
	  else
		echo "创建存包目录："$WORKSPACE/package
		mkdir -p $WORKSPACE/package/jars
		mkdir -p $WORKSPACE/package/wars
	fi
	# 注释说明
	# 1.生效当前用户的环境变量
	# 2.检查并生成deploy目录
	# 3.打包
	#   参数说明：$1——项目名
	#             $2——打包类型(war/jar/pom)
	#             $3——打包软件用途类型(dev/sit/product/uat/pet)
	#             $4——打包完成后app存包目录:$WORKSPACE/package
	#             $5——项目源码码存放目录:$WORKSPACE/appCode
	#             $6——部分maven打包后交付件涉及二级目录，新增参数校验区别归档
# POMS
	# 打包任务ifsp-file(涉及二级目录),多传入"SencondPath"参数：fileserver-*.war,filemapping-*.jar
	# 打包任务ifsp-paypagycore-master( 涉及二级目录),多传入"SencondPath"参数：chlcore-*.jar,ebapnotifyweb-*.war,chlmng-*.jar	
	for App in $PomAppsReadyToPack
	do
		echo "[日志] $App Is Starting...☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆"	
		echo sh  $WORKSPACE/Autoscript/script/package.sh $App "pom" $softwareUsefor $WORKSPACE/package $WORKSPACE/appCode "SencondPath"
		sh  $WORKSPACE/Autoscript/script/package.sh $App "pom" $softwareUsefor $WORKSPACE/package $WORKSPACE/appCode "SencondPath"
        if [ $? -ne 0 ]; then
            echo "[ERROR] 打包流程执行失败,退出任务"
            exit 1			
		fi
		echo "[日志] $App Is Finished...☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆"
	done
	
# WARS
	# 该打包任务涉及如下Apps
	for App in $WarAppsReadyToPack
	do
		# 打包任务ifsp-apps-project(涉及二级目录),多传入"SencondPath"参数
		if [[ "$App" = "ifsp-apps-project" ]];then
			echo "[日志] $App Is Starting...☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆"	
			echo sh  $WORKSPACE/Autoscript/script/package.sh $App "war" $softwareUsefor $WORKSPACE/package $WORKSPACE/appCode "SencondPath"
			sh  $WORKSPACE/Autoscript/script/package.sh $App "war" $softwareUsefor $WORKSPACE/package $WORKSPACE/appCode "SencondPath"
			if [ $? -ne 0 ]; then
				echo "[ERROR] 打包流程执行失败,退出任务"
				exit 1			
			fi			
			echo "[日志] $App Is Finished...☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆"		
		else
			echo "[日志] $App Is Starting...☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆"	
			echo sh  $WORKSPACE/Autoscript/script/package.sh $App "war" $softwareUsefor $WORKSPACE/package $WORKSPACE/appCode
			sh  $WORKSPACE/Autoscript/script/package.sh $App "war" $softwareUsefor $WORKSPACE/package $WORKSPACE/appCode
			if [ $? -ne 0 ]; then
				echo "[ERROR] 打包流程执行失败,退出任务"
				exit 1
			fi
			echo "[日志] $App Is Finished...☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆"					
		fi
	done
	
# JARS
	# 该打包任务涉及如下Apps
	for App in $JarAppsReadyToPack
	do
		# 打包任务ifsp-monitor(涉及二级目录),多传入"SencondPath"参数
		if [[ "$App" = "ifsp-monitor" ]];then
			echo "[日志] $App Is Starting...☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆"	
			echo sh  $WORKSPACE/Autoscript/script/package.sh $App "jar" $softwareUsefor $WORKSPACE/package $WORKSPACE/appCode "SencondPath"
			sh  $WORKSPACE/Autoscript/script/package.sh $App "jar" $softwareUsefor $WORKSPACE/package $WORKSPACE/appCode "SencondPath"
			if [ $? -ne 0 ]; then
				echo "[ERROR] 打包流程执行失败,退出任务"
				exit 1			
			fi			
			echo "[日志] $App Is Finished...☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆"		
		else
			echo "[日志] $App Is Starting...☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆"	
			echo sh  $WORKSPACE/Autoscript/script/package.sh $App "jar" $softwareUsefor $WORKSPACE/package $WORKSPACE/appCode
			sh  $WORKSPACE/Autoscript/script/package.sh $App "jar" $softwareUsefor $WORKSPACE/package $WORKSPACE/appCode
			if [ $? -ne 0 ]; then
				echo "[ERROR] 打包流程执行失败,退出任务"
				exit 1
			fi
			echo "[日志] $App Is Finished...☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆"			
		fi
	done
	
elif [[ "$1" == "send_ftp" ]]; then
	echo Step2、生成压缩归档版本号，压缩所有软件包，归档ftp服务器目录
	# 上传ftp参数说明：
	#   $1——AppPackagePath：待打包目录
	#   $2——ftp_ip：ftp IP地址
	#   $3——ftp_user：ftp用户名
	#   $4——ftp_pwd：ftp用户密码
	#   $5——ftp_dir：ftp存包目录
	#   $6——softwareUsefor：打包软件用途类型(dev/sit/product/uat/pet)
	echo sh  $WORKSPACE/Autoscript/script/send_ftp.sh $WORKSPACE/package $ftp_ip "$ftp_user" "$ftp_pwd" $ftp_dir $softwareUsefor
	sh  $WORKSPACE/Autoscript/script/send_ftp.sh $WORKSPACE/package $ftp_ip "$ftp_user" "$ftp_pwd" $ftp_dir $softwareUsefor
	if [ $? -ne 0 ]; then
		echo "[ERROR] 软件包打包完毕，上传ftp服务器失败，请核查！！！"
		exit 1
	fi	
elif [[ "$1" == "get_ftp" ]]; then
	echo Step3、根据前台传入的版本包名从ftp服务器下载版本包，进行MD5校验，解压缩版本包
	# ftp取包参数说明：
	#   $1——AppDeployPath：分发部署目录
	#   $2——ftp服务器上存取app集合包包名（不含后缀）
	#   $3——ftp_ip：ftp IP地址
	#   $4——ftp_user：ftp用户名
	#   $5——ftp_pwd：ftp用户密码
	#   $6——ftp_dir：ftp上的存包目录
	echo sh  $WORKSPACE/Autoscript/script/get_ftp.sh $AppDeployPath $pkg_name $ftp_ip "$ftp_user" "$ftp_pwd" $ftp_dir
	sh  $WORKSPACE/Autoscript/script/get_ftp.sh $AppDeployPath $pkg_name $ftp_ip "$ftp_user" "$ftp_pwd" $ftp_dir
elif [[ "$1" == "update_conffile" ]]; then
	echo Step4、根据前台传入的配置文件路径，版本包名分发部署软件版本
	# 部署参数说明：
	#   $1——分发部署配置文件文本参数
	echo sh  $WORKSPACE/Autoscript/script/update_conffile.sh "$DeployConf_txt"
	sh  $WORKSPACE/Autoscript/script/update_conffile.sh "$DeployConf_txt"
	if [ $? -ne 0 ]; then
		echo "[ERROR] 部署配置文件二次处理执行失败，请核查！！！"
		exit 1
	fi
elif [[ "$1" == "deploy" ]]; then
	echo Step4、根据前台传入的配置文件路径，版本包名分发部署软件版本
	# 部署参数说明：
	#   $1——部署包下载存放目录(分发部署目录):$WORKSPACE/deploy
	#   $2——部署包名:ebap_sit_201808060935_1049
	#   $3——部署配置文件目录
	#   $4——部署配置文件名字
	#   $5——app部署入口脚本：/home/app/run/deployStart.sh
	echo sh  $WORKSPACE/Autoscript/script/deploy.sh
	sh  $WORKSPACE/Autoscript/script/deploy.sh
	if [ $? -ne 0 ]; then
		echo "[ERROR] 部署流程执行失败，请核查！！！"
		exit 1
	fi
fi




