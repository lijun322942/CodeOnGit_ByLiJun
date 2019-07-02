#!/bin/bash
# 该脚本为全局参数脚本
# 其他脚本在执行过程中先执行该脚本，获取全局参数变量，被后续脚本使用
# $1: jenkins slave节点工作目录(内置变量:$WORKSPACE):
#	  
# ftp存包地址，后续上传下载均会使用到该参数
export ftp_ip=10.16.1.23

# ftp存包地址认证账户
export ftp_user=upload

# ftp存包地址认证账户‘s密码
export ftp_pwd=upload