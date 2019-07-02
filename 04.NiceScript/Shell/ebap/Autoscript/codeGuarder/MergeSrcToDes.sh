#!/bin/bash
#该任务用于源端分支(feature)最新代码合并到主干(develop)
#设置代码库工作目录

#设置源端代码库分支
SrcCodeBranch=$SrcCodeBranch

#设置目标端代码库分支
DesCodeBranch=$DesCodeBranch

echo [INFO:]执行fetch拉取最新的代码到本地缓存
cd $CodeWorkSpace
git fetch -v --progress "origin"

echo [INFO:]switch/checkout到目标分支
git checkout -B $DesCodeBranch remotes/origin/$DesCodeBranch --

echo [INFO:]打印当前仓库分支地址:
git branch

echo [INFO:]pull最新代码到本地
git pull --progress -v --no-rebase "origin"

echo [INFO:]执行源端分支代码合并到目标端
git merge -m "[代码门禁系统]Merge branch '$SrcCodeBranch' into '$DesCodeBranch'" $SrcCodeBranch

if [ $? -eq 0 ]; then
	echo "${SrcCodeBranch} 代码合并 ${DesCodeBranch} 成功！！！"
else
	echo "${SrcCodeBranch} 代码合并 ${DesCodeBranch} 失败，请检视！！！"
	exit 1
fi

echo [INFO:]执行推送
git push --progress "origin" $DesCodeBranch:$DesCodeBranch
if [ $? -eq 0 ]; then
	echo "${SrcCodeBranch} 代码推送 ${DesCodeBranch} 成功！！！"
	exit 0	
else
	echo "${SrcCodeBranch} 代码推送 ${DesCodeBranch} 失败，请检视！！！"
	exit 1
fi

