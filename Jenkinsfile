pipeline {
  agent {
    docker {
      image 'alpine:3.17.3'
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
        //sh 'apk add --no-cache docker'
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
        script {
            env.TAG = sh(script: 'echo "$(date +%Y-%m-%d.%H.%M.%S)-${BUILD_ID}"', returnStdout: true).trim()
            // Log in to ECR and authenticate Docker client
            def ecrCredentials = credentials('aws')
            def ecrLogin = sh(script: "aws ecr get-login --no-include-email --region ${AWS_REGION} --registry-ids ${ECR_REGISTRY_ID}", returnStdout: true).trim()
            //  prevent the Docker login command and authentication token from being displayed in the Jenkins log output
            sh "${ecrLogin} > /dev/null"
        }
      }
    }
    stage('Check Docker status') {
      steps {
        sh 'sudo systemctl status docker || sudo service docker status'
      }
    }
    stage('Build and push') {
      environment {
            FRONTEND = "153042419275.dkr.ecr.us-east-1.amazonaws.com/eks_mern_frontend"
      }
      steps {
        script {
            sh """
              echo \"Build started on `date`\"
              echo Building the Docker image...
              docker build --tag $FRONTEND:$TAG .
              echo \"Build completed on `date`\"
              echo Pushing the Docker image to ECR Repository
              docker push $FRONTEND:$TAG
              echo \"Docker Image Push to ECR Completed -  $FRONTEND:$TAG\"
            """
        }
      }
    }
    
  }
}