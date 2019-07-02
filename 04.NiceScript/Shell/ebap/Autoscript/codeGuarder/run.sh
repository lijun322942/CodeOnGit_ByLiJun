#!/bin/bash
#该任务用于源端分支(feature)最新代码合并到主干(develop)门禁系统入口脚本
#设置代码库工作目录
para=$1
echo "当前工作目录为: "`pwd`
cd $WORKSPACE

# 设置代码合并、检出工作目录,创建该目录
export CodeWorkSpace=$WORKSPACE/CodeWorkSpace

# 设置git工具变量
#export GitTools=/usr/local/bin/git

#Step1:执行feature分支代码拉取到最新
if [[ "$para" == "SrcCheckout" ]]; then
	echo [DATE:]`date`
	echo [INFO:]执行$SrcCodeBranch分支代码拉取
	sh $WORKSPACE/ebap_AotoProj/codeGuarder/SrcCheckout.sh	
	if [ $? -eq 0 ]; then
		echo "执行$SrcCodeBranch分支代码拉取失败，请核查！！！"
	fi
fi

#Step2:执行feature分支代码合并到develop
if [[ "$para" == "MergeSrcToDes" ]]; then
	echo [DATE:]`date`
	echo [INFO:]执行分支合并:$SrcCodeBranch->$DesCodeBranch
	sh $WORKSPACE/ebap_AotoProj/codeGuarder/MergeSrcToDes.sh
	if [ $? -eq 0 ]; then
		echo "执行分支合并:$SrcCodeBranch->$DesCodeBranch失败，请核查！！！"
	fi
fi
