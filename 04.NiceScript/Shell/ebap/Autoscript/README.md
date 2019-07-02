1、概述：该目录下存放的脚本为扫码支付项目Jenkins CI(持续集成脚本)
2、作者: 18758 李俊
3、目录结构：
.\AutoScript
	|   README.md 					目录解释文件
	|   
	+---codeGuarder					代码门禁脚本目录
	|   |   MergeSrcToDes.sh
	|   |   run.sh
	|   |   SrcCheckout.sh
	|   |   
	|   \---log
	|           .gitignore
	|           
	+---deployConf					自动化部署配置文件存放目录，暂未使用
	|       deployConf.ini
	|       deployConf_all.ini
	|       
	+---env							
	|       env.sh					脚本全局变量脚本
	|       taskStart.sh			工程任务入口脚本
	|       
	+---remoteDeployScript			远程应用服务器部署使用的脚本
	|       commDeploy.sh
	|       deployStart.sh			
	|       README.txt
	|       weblogicDeploy.sh
	|       weblogicDeploy_dxyh.sh
	|       
	\---script						集成打包和自动化部署脚本				
			deploy.sh
			get_ftp.sh
			package.sh
			send_ftp.sh
			update_conffile.sh