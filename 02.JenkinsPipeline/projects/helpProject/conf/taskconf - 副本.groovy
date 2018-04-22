Jenkinsfile (Declarative Pipeline)
pipeline {

    stages {
	    stage('CheakoutCode') { 
            steps { 
			    label 'winAgent'
                git 'https://github.com/lijun322942/CodeOnGit_ByLiJun.git' 			
            }
        }
		
        stage('Build') { 
            steps { 
			    label 'winAgent'
                bat echo %date%_%time% > log\Build.log				
            }
        }
    }
}