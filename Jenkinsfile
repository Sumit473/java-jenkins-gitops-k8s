pipeline {
  agent {
    docker {
      image 'sumitdev151301/jenkins-ci-agent:latest'
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock' // mount Docker socket to access the host's Docker daemon
    }
  }
  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/Sumit473/Java-App'
      }
    }
    stage('Build and Test') {
      steps {
        // build the project and create a JAR file
        sh 'mvn clean package'
      }
    }
    stage('Static Code Analysis') {
      environment {
        SONAR_URL = "http://13.48.149.204:9000"
      }
      steps {
        withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_AUTH_TOKEN')]) {
          sh 'mvn sonar:sonar -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.host.url=${SONAR_URL}'
        }
      }
    }
    stage('Build and Push Docker Image') {
      environment {
        DOCKER_IMAGE = "sumitdev151301/cicd:${BUILD_NUMBER}"
        REGISTRY_CREDENTIALS = credentials('docker-hub')
      }
      steps {
        script {
            sh 'docker build -t ${DOCKER_IMAGE} .'
            def dockerImage = docker.image("${DOCKER_IMAGE}")
            docker.withRegistry('https://index.docker.io/v1/', "docker-hub") {
                dockerImage.push()
            }
        }
      }
    }
    stage('Checkout Manifests') {
      steps {
        git branch: 'main', url: 'https://github.com/Sumit473/Manifests'
      }
    }
    stage('Update Deployment File') {
        environment {
            GIT_REPO_NAME = "Manifests"
            GIT_USER_NAME = "Sumit473"
        }
        steps {
            withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                sh '''
                    git config --global user.email "sumitgargofficial@gmail.com"
                    git config --global user.name "Sumit Garg"
                    git config --global --add safe.directory /var/lib/jenkins/workspace/cicd
                    sed -i "s/replaceImageTag/${BUILD_NUMBER}/g" deployment.yaml
                    git add deployment.yaml
                    git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                    git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
                '''
            }
        }
     }
  }
}
