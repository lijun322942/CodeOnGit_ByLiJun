Jenkinsfile (Declarative Pipeline)
pipeline {
    stages {
        stage('Build') { 
            steps { 
			    label 'winAgent'
                bat echo %date%_%time% > log\Build.log				
            }
        }
    }
}