pipeline {
  agent {
    docker {
      image 'crimson2022/test:2'
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock' // mount Docker socket to access the host's Docker daemon
    }
  }
  stages {
    stage('Checkout') {
      steps {
        // since i have configure branch discovery this is not needed
        sh 'echo passed'
      }
    }
    stage('Install dependencies') {
      steps {
        sh 'apk add --no-cache docker'
        sh 'apk add --no-cache aws-cli'
        sh 'aws --version'
      }
    }
    stage('pre-run set up') {
      environment {
            AWS_REGION = "us-east-1"
            ECR_REGISTRY_ID = "153042419275"
      }
      steps {
        // using script so this value can be use in other stages
        script {
            sh 'TAG="$(date +%Y-%m-%d.%H.%M.%S)-${BUILD_ID}"'
            // Log in to ECR and authenticate Docker client
            def ecrCredentials = credentials('aws-creds')
            def ecrLogin = sh(script: "aws ecr get-login --no-include-email --region ${AWS_REGION} --registry-ids ${ECR_REGISTRY_ID}", returnStdout: true).trim()
            //  prevent the Docker login command and authentication token from being displayed in the Jenkins log output
            sh "${ecrLogin} > /dev/null"
        }
      }
    }
    stage('Build and push') {
      environment {
            FRONTEND = "153042419275.dkr.ecr.us-east-1.amazonaws.com/eks_mern_frontend"
      }
      steps {
        script {
            sh '''
              echo "Build started on `date`"
              Building the Docker image...
              docker build --tag $FRONTEND:$TAG .
              echo "Build completed on `date`"
              echo "Pushing the Docker image to ECR Repository"
              docker push $FRONTEND:$TAG
              echo "Docker Image Push to ECR Completed -  $FRONTEND:$TAG"
            '''
        }
      }
    }
    
  }
}