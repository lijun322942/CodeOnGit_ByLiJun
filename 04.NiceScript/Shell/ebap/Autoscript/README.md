1����������Ŀ¼�´�ŵĽű�Ϊɨ��֧����ĿJenkins CI(�������ɽű�)
2������: 18758 �
3��Ŀ¼�ṹ��
.\AutoScript
	|   README.md 					Ŀ¼�����ļ�
	|   
	+---codeGuarder					�����Ž��ű�Ŀ¼
	|   |   MergeSrcToDes.sh
	|   |   run.sh
	|   |   SrcCheckout.sh
	|   |   
	|   \---log
	|           .gitignore
	|           
	+---deployConf					�Զ������������ļ����Ŀ¼����δʹ��
	|       deployConf.ini
	|       deployConf_all.ini
	|       
	+---env							
	|       env.sh					�ű�ȫ�ֱ����ű�
	|       taskStart.sh			����������ڽű�
	|       
	+---remoteDeployScript			Զ��Ӧ�÷���������ʹ�õĽű�
	|       commDeploy.sh
	|       deployStart.sh			
	|       README.txt
	|       weblogicDeploy.sh
	|       weblogicDeploy_dxyh.sh
	|       
	\---script						���ɴ�����Զ�������ű�				
			deploy.sh
			get_ftp.sh
			package.sh
			send_ftp.sh
			update_conffile.sh