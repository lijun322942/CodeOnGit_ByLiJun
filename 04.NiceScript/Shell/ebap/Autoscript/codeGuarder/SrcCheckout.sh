#!/bin/bash
#该任务拉取更新到源端分支(feature)最新代码,为后续分支合并到主干(develop)做准备
#设置代码库工作目录

# 设置代码合并、检出工作目录,创建该目录
#if [ -e ${CodeWorkSpace} ]; then
	#rm -rf ${CodeWorkSpace}
	#echo "mkdir -p ${CodeWorkSpace}"
	#mkdir -p ${CodeWorkSpace}
#else
	#echo "mkdir -p ${CodeWorkSpace}"
	#mkdir -p ${CodeWorkSpace}
#fi

# 校验设置代码合并、检出工作目录是否存在
#if [ ! -e ${CodeWorkSpace} ]; then
	#echo ${CodeWorkSpace} 路径不存在！请核查...
	#exit 1
#fi

#设置代码库URL地址18758:asdf1234@
#SrcCodeURL = "http://10.16.9.5:8001/tfs/DefaultCollection/%E7%A7%BB%E5%8A%A8%E6%94%AF%E4%BB%98%EF%BC%88%E6%89%AB%E7%A0%81%E6%94%AF%E4%BB%98%EF%BC%89%E9%A1%B9%E7%9B%AE/_git/ebap"

#设置源端代码库分支
echo SrcCodeBranch=$SrcCodeBranch
SrcCodeBranch=$SrcCodeBranch

echo [INFO:][LINE $LINENO]执行代码clone
#echo [INFO:] git clone --progress -v ${SrcCodeURL} ${CodeWorkSpace}
#git clone --progress -v ${SrcCodeURL} ${CodeWorkSpace}

echo [INFO:]执行fetch拉取最新的代码到本地缓存
cd ${CodeWorkSpace}
echo [INFO:] git fetch -v --progress "origin"
git fetch -v --progress "origin"

echo [INFO:]switch、checkout到目标分支
echo [INFO:] git checkout -B ${SrcCodeBranch} remotes/origin/${SrcCodeBranch} --
git checkout -B ${SrcCodeBranch} remotes/origin/${SrcCodeBranch} --

echo [INFO:]打印当前仓库分支地址:
echo [INFO:] git branch
git branch

echo [INFO:]pull最新代码到本地
echo [INFO:] git pull --progress -v --no-rebase origin
git pull --progress -v --no-rebase "origin"

echo [INFO:]拉取源端分支:${SrcCodeBranch}代码到本地执行完毕,退出任务!
exit 0
