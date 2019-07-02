#!/bin/bash
# 注释说明
# 1.生效当前用户的环境变量
# 2.检查并生成deploy目录
# 3.打包
#	package.sh "ifsp-file" "pom" $softwareUsefor $WORKSPACE/package $WORKSPACE/appCode
#   参数说明：$1——项目名app名
#             $2——打包类型(war/jar/pom)
#             $3——打包软件用途类型(dev/sit/product/uat/pet)
#             $4——打包完成后存包目录：$WORKSPACE/package
#             $5——项目源码码存放目录：$WORKSPACE/SCAVENGING_PAYMENT_PACKAGE

echo "StartTime:"+`date`
# 参数校验(-z 检测字符串长度是否为0，为零返回true)
if [ -z $1 ]; then
    echo "项目名为空"
    exit 1
fi
if [ -z $2 ]; then
    echo "打包类型为空"
    exit 1
fi
if [ -z $3 ]; then
    echo "环境为空"
    exit 1
fi
if [ -z $4 ]; then
    echo "存包目录为空"
    exit 1
fi
if [ -z $5 ]; then
    echo "项目源码码存放目录为空"
    exit 1
fi
if [ ! -z $6 ]; then
    echo "打包后交付件涉及二级目录，该参数校验区别归档"
fi

# 生效当前用户的环境变量(当前用户内包含了部分自有配置)，该部分配置仅对当前用户有效
#PATH=/opt/oracle/lib:$HOME/jdk1.8.0_172/bin:$HOME/maven-3.2.3/bin:/home/make/ebmp/apache-ant-1.9.11/bin:/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/ebap/.local/bin:/home/ebap/bin
#export JAVA_HOME=/home/ebap/jdk1.8.0_172
#export JRE_HOME=/home/ebap/jdk1.8.0_172/jre
#export CLASSPATH=/home/ebap/jdk1.8.0_172/lib:/home/ebap/jdk1.8.0_172/jre/lib
# 1、java版本：$HOME/jdk1.8.0_172
# 2、maven版本：$HOME/maven-3.2.3/bin:
# 3、..
. $HOME/.bash_profile

# 打包
# 检查存放项目根目录是否存在
if [ ! -e $5 ]; then
    echo "存放项目根目录["${5}"]不存在"
    exit 1
fi
# 检查项目目录是否存在
if [ -e ${5}/${1} ]; then
    cd ${5}/${1}
	echo "当前工作目录为:"+`pwd`
    mvn -U clean install -Dmaven.test.skip=true -Dmaven.test.failture.ignore=true -P $3
	#、归档规则pom-->(jar,war),(jar-->jar)(war-->war)，pom也涉及二级目录
    if [ "$2" = "pom" ]; then
		cp ./*/target/*.jar ${4}/jars
		if [ $? -ne 0 ]; then
			echo "[ERROR] [LINE $LINENO] 打包[${1}]失败,请检视！！！"
			exit 1
		fi
		cp ./*/target/*.war ${4}/wars
		if [ $? -ne 0 ]; then
			echo "[ERROR] [LINE $LINENO] 打包[${1}]失败,请检视！！！"
			exit 1
		fi 
	#、部分maven打包后交付件涉及二级目录，新增参数校验区别归档,$6为二级拷贝标志
	elif [[ "${2}" = "jar" && "x${6}" = "xSencondPath" ]]; then
		cp ./*/target/*.${2} ${4}/${2}s
		if [ $? -ne 0 ]; then
			echo "[ERROR] [LINE $LINENO] 打包[${1}]失败,请检视！！！"
			exit 1
		fi 
	elif [[ "${2}" = "war" && "x${6}" = "xSencondPath" ]]; then
		cp ./*/target/*.${2} ${4}/${2}s
		if [ $? -ne 0 ]; then
			echo "[ERROR] [LINE $LINENO] 打包[${1}]失败,请检视！！！"
			exit 1
		fi 
	#、常规拷贝只有一级目录
	else	
        cp ./target/*.${2} ${4}/${2}s
        if [ $? -ne 0 ]; then
            echo "[ERROR] [LINE $LINENO] 打包[${1}]失败,请检视！！！"
            exit 1
        fi 
    fi    
else
    echo "项目目录["${5}"/"${1}"]不存在,请检视！！！"
    exit 1
fi

# echo "EndTime:"+`date`
# exit 0

