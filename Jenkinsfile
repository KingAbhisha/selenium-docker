pipeline{

    agent any

    stages{

        stage('Build-Jar'){
            steps{
                bat "mvn clean package -DskipTests"
            }
        }

        stage('Build-Docker-Images'){

            steps{
                bat "docker build -t=kingabhisha/selenium-docker-runnerfile:latest ."
            }
        }

        stage('Push-Image'){
			environment{
				DOCKER_HUB = credentials('docker-hub-credentials')
			}
            steps{
				bat 'docker login -u %DOCKER_HUB_USR% -p %DOCKER_HUB_PSW%'
                bat "docker push kingabhisha/selenium-docker-runnerfile:latest"
                bat "docker tag kingabhisha/selenium-docker-runnerfile:latest kingabhisha/selenium-docker-runnerfile:${env.BUILD_NUMBER}"
                bat "docker push kingabhisha/selenium-docker-runnerfile:${env.BUILD_NUMBER}"
            }
        }
    }
    
    post{
		always{
			bat "docker logout"
		}
	}
}