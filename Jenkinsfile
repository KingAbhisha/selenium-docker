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
                bat "docker build -t=kingabhisha/selenium-docker-runnerfile ."
            }
        }

        stage('Push-Inage'){
            steps{
                bat "docker push kingabhisha/selenium-docker-runnerfile"
            }
        }
    }
}