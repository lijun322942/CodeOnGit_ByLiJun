#!/bin/bash
# 根据前台传入的配置文件路径，版本包名分发部署软件版本
# update_conffile.sh $DeployConf_txt
# 部署参数说明：
#   $1——分发部署配置文本变量入参

# 参数校验
if [ -z "${1}" ]; then
    echo "[ERROR]" "[LINE $LINENO]分发配置文件文本内容为空"
    exit 1
fi

# 如果不存在分发部署配置文件存放目录，则创建该目录
if [ ! -e $WORKSPACE/Autoscript/deployConf/ ];then
	mkdir $WORKSPACE/Autoscript/deployConf/
fi
cd $WORKSPACE/Autoscript/deployConf/
# 二次处理部署配置文件开始******
# 将页面配置信息写入到配置文件中
echo ${1} > ./deployConf.ini
# 执行操作，将空格提换为换行符，删除“#”号打头的行文件
sed 's/ /\n/g' ./deployConf.ini>./deployConf_bak.ini
sed -i -e '/^#/d' ./deployConf_bak.ini

rm -f ./deployConf.ini
mv ./deployConf_bak.ini ./deployConf.ini

echo "[INFO：重要]=================打印处理后配置文件部署分发信息]================="
cat ./deployConf.ini
# 二次处理部署配置文件结束******

# 校验部署配置文件是否存在
if [ ! -e ./deployConf.ini ]; then
    echo "[ERROR]" "[LINE $LINENO] 部署配置文件["./deployConf.ini"]不存在"
    exit 1
else
	exit 0
fi
