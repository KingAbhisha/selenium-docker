pipeline{

    agent any

    stages{

        stage('stage-1'){
            steps{
                echo "mvn clean"
                echo "mvn package"
            }
        }

        stage('stage-2'){

            steps{
                echo "build docker image"
            }
        }

        stage('stage-3'){
            steps{
                echo "push docker image"
            }
        }
    }

    post{
        always{
            echo "clean-up"
        }
    }

}