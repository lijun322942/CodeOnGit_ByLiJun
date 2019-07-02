#!/bin/bash
# 根据前台传入的参数,执行版本升级($1=sysinfo;stop;backup;update;start;)或回退($1=sysinfo;stop;rollback;start;)
# sh ./WeblogicDeploy.sh "stop" $app $VersionDate
#[脚本说明] :
#1、常规war应用部署(全量部署)包含如下流程:
# 1.1 应用服务器软件包备份、移除 
# 1.2 应用服务器停服务 
# 1.3 替换本次发布版本文件到部署目录下
# 1.4 清理缓存（如果涉及） 
# 1.5 应用服务器启动服务 
# 1.6 应用服务器服务进程检查
#2、常规war应用回退包含如下流程:
# 2.1 应用服务器停服务
# 2.2 回退上次发布前备份的版本到部署目录下
# 2.3 清理缓存（如果涉及） 
# 2.4 应用服务器启动服务 
# 2.5 应用服务器服务进程检查 

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
# 生效当前用户的环境变量(当前用户内包含了部分自有配置)，该部分配置仅对当前用户有效
if [ -f ~/.bash_profile ]; then
	. ~/.bash_profile
fi
#设置JAVA环境变量
if [ -z ${JAVA_HOME} ]; then
	echo "[ERROR]" "JAVA_HOME 环境变量不存在！请核查..."
	exit 1
else
	java=${JAVA_HOME}/bin/java
	echo [INFO]:java值为 ${java}
fi
#应用字符集
export CHARSET=UTF-8
#系统日期
export date=$(date +%Y-%m-%d)
#应用运行内存设置
export JAVA_MEM_OPTS="-Xms1024M -Xmx2048M -XX:MetaspaceSize=512m -XX:MaxMetaspaceSize=1024m"
#Ifsp目录
ifspHome=/home/app
#基于传参获得软件名称(不带版本和扩展名),例：cust
APP_NAME=`echo $2 | awk -F"-" '{print $1}'`
#基于传参获得软件名称(不带版本和扩展名),例：cust
APP_FILENAME=`echo $2 | awk -F"-" '{print $1}'`.war 
#应用主目录,例：#/data/home/app/deploy
APP_HOME=${ifspHome}/deploy
#依赖包,例：#/data/home/app/deploy/cust/lib
APP_LIB_PATH=${APP_HOME}/lib
#启动
IfspRun=com.scrcu.ebank.ebap.startup.IfspRun
#日志
ifspstartlog=${ifspHome}/logs

if [ "$1" = "sysinfo" ]; then
	#打印系统环境
	echo "[INFO]: ==============================="
	echo "[INFO]: date=${date}"
	echo "[INFO]: JAVA_HOME=${JAVA_HOME}"  
	echo "`${JAVA_HOME}/bin/java -version`"
	echo "[INFO]: CHARSET=${CHARSET}"  
	echo "[INFO]: APP_HOME=${APP_HOME}"
	echo "[INFO]: APP_NAME=${APP_NAME}"
	echo "[INFO]: APP_FILENAME=${APP_FILENAME}"
	echo "[INFO]: APP_MAINCLASS=${APP_LIB_PATH}"  
	echo "[INFO]: CLASSPATH=${CLASSPATH}" 
	echo "[INFO]: IfspRun=${IfspRun}"
	echo [INFO]:java值为 ${java}
	echo "[INFO]: ==============================="
elif [ "$1" = "start" ]; then
	#指定服务启动$1,$2
	echo "[INFO]: ========${APP_NAME} has start begin========"
	#例:/home/app/deploy/order/order.jar
	RUM_MAIN=${APP_HOME}/${APP_FILENAME}
	#启动检查是否已经存在服务
	PIDS=`ps -ef | grep "${RUM_MAIN} ${IfspRun}" | grep -v "grep" | awk '{print $2}'`
	if [ -n "$PIDS" ]; then
		echo "[ERROR]: 已经有应用[${APP_FILENAME}]在运行，请先停止该服务(进程ID:${PIDS})，再行启动!";
		exit 1
	else 
		echo "[INFO]: 应用[${APP_FILENAME}]初始化完毕."
	fi 
	#依赖资源
	for cdir in ${APP_LIB_PATH}/*.jar
	do
		CLASSPATH=${CLASSPATH}:${cdir}
		export CLASSPATH
	done
	#启动服务
	nohup ${java} ${JAVA_MEM_OPTS} -Dappname=${APP_FILENAME} -Dfile.encoding=${CHARSET} -classpath ${CLASSPATH}:${RUM_MAIN} ${IfspRun} >"$ifspstartlog/${APP_NAME}-${date}.log" 2>"$ifspstartlog/${APP_NAME}-${date}_err.log" &
	sleep 2
	echo "[INFO]: 服务启动命令已启动..." 
	sleep 1
	echo "[INFO]: 日志输出目录[$ifspstartlog/]"
	echo "[INFO]: ========${APP_NAME} has start end========"
elif [ "$1" = "stop" ]; then
	#指定服务停用$1,$2
	RUM_MAIN=${APP_HOME}/${APP_FILENAME}
	PIDS=`ps -ef | grep "${RUM_MAIN} ${IfspRun}" | grep -v "grep"|awk '{print $2}'`
	if [ -n "$PIDS" ]; then
	   for PID in $PIDS ; do
			echo "[INFO]: ========${APP_NAME}(pid=$PID) has stopped begin========"
			kill -9 $PID 1>/dev/null 2>&1
			echo "[INFO]: ========${APP_NAME}(pid=$PID) has stopped end========"
	   done
	else 
	   echo "[INFO]: ${APP_NAME} has stopped !!"
	fi
elif [ "$1" = "backup" ]; then
	#执行基础版本文件备份
	RUM_MAIN=${APP_HOME}/${APP_FILENAME}
	if [ -e ${APP_HOME}/${APP_FILENAME}.JksBak_$3 ]; then
		echo "[INFO]:备份目标文件 ${APP_HOME}/${APP_FILENAME}.JksBak_$3 已存在，跳过备份！"
	else
		mv ${APP_HOME}/${APP_FILENAME} ${APP_HOME}/${APP_FILENAME}.JksBak_$3
		echo "[INFO]:备份目标文件 ${APP_HOME}/${APP_FILENAME}.JksBak_$3 备份完毕！"		
	fi  
elif [ "$1" = "update" ]; then
	#将待发布版本替换到版本发布目录下
	RUM_MAIN=${APP_HOME}/${APP_FILENAME}
	cp ~/JenkinsAutodeploy/update/$3/war/$2 ${APP_HOME}/${APP_FILENAME}
	is_suc "cp ~/JenkinsAutodeploy/update/$3/war/$2 ${APP_HOME}/${APP_FILENAME}"
elif [ "$1" = "rollback" ]; then
	#将已备份的目标版本文件替换到版本发布目录下
	RUM_MAIN=${APP_HOME}/${APP_FILENAME}
	if [ -e ${APP_HOME}/${APP_FILENAME}.JksBak_$3 ]; then
		cp ${APP_HOME}/${APP_FILENAME}.JksBak_$3 ${APP_HOME}/${APP_FILENAME}
		is_suc "cp ${APP_HOME}/${APP_FILENAME}.JksBak_$3 ${APP_HOME}/${APP_FILENAME}"
	else
		echo "[INFO]:用于回退的版本文件(${APP_HOME}/${APP_FILENAME}.JksBak_$3)不存在，请核查! "
		exit 1	
	fi 
else
	echo "[ERROR] command must be: sysinfo|start|stop|backup|update|rollback" 
	exit 1
fi
