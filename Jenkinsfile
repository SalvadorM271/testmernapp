pipeline {
  agent {
    docker { // this agent creates a container per job (job = run, not stage)
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
        sh 'apk add --no-cache docker-cli' // not docker but the cli (im using the host pc docker)
        sh 'apk add --no-cache aws-cli'
        sh 'aws --version'
        sh 'apk add --no-cache curl'
      }
    }
    stage('pre-run set up') {
      // this envs are only available in this stage
      environment {
            AWS_REGION = "us-east-1"
            ECR_REGISTRY_ID = "153042419275"
      }
      steps {
        script {
            env.TAG = sh(script: 'echo "$(date +%Y-%m-%d.%H.%M.%S)-${BUILD_ID}"', returnStdout: true).trim()
            // Log in to ECR and authenticate Docker client (this will remain the same as long as i use the same acc for all envs)
            withCredentials([usernamePassword(credentialsId: 'aws', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
              def ecrLogin = sh(script: "aws ecr get-login --no-include-email --region ${AWS_REGION} --registry-ids ${ECR_REGISTRY_ID}", returnStdout: true).trim()
              //  prevent the Docker login command and authentication token from being displayed in the Jenkins log output
              sh "${ecrLogin} > /dev/null"
            }
        }
      }
    }
    stage('Build and push') {
      // this are share across all no matter conditional
      environment {
            FRONTEND = "153042419275.dkr.ecr.us-east-1.amazonaws.com/eks_mern_frontend"
            FRONTEND_DEV = "153042419275.dkr.ecr.us-east-1.amazonaws.com/eks_mern_frontend_dev"
            FRONTEND_STG = "153042419275.dkr.ecr.us-east-1.amazonaws.com/eks_mern_frontend_staging"
            FRONTEND_PROD = "153042419275.dkr.ecr.us-east-1.amazonaws.com/eks_mern_frontend_prod"
      }
      steps {
        script {
            if (env.BRANCH_NAME.startsWith("feature/")) {
                echo "This is a feature branch: ${env.BRANCH_NAME}"
                // Perform actions specific to feature branches
                sh """
                    echo \"Build started on `date`\"
                    echo Building the Docker image...
                    docker build --tag $FRONTEND:$TAG .
                    echo \"Build completed on `date`\"
                    echo Pushing the Docker image to ECR Repository
                    docker push $FRONTEND:$TAG
                    echo \"Docker Image Push to ECR Completed -  $FRONTEND:$TAG\"
                """
            } else if (env.BRANCH_NAME == 'develop') {
                echo "This is the dev branch"
                // Perform actions specific to dev branch
                sh """
                    echo \"Build started on `date`\"
                    echo Building the Docker image...
                    docker build --tag $FRONTEND_DEV:$TAG .
                    echo \"Build completed on `date`\"
                    echo Pushing the Docker image to ECR Repository
                    docker push $FRONTEND_DEV:$TAG
                    echo \"Docker Image Push to ECR Completed -  $FRONTEND_DEV:$TAG\"
                """
            } else if (env.BRANCH_NAME == 'staging') {
                echo "This is the stg branch"
                // Perform actions specific to stg branch
                sh """
                    echo \"Build started on `date`\"
                    echo Building the Docker image...
                    docker build --tag $FRONTEND_STG:$TAG .
                    echo \"Build completed on `date`\"
                    echo Pushing the Docker image to ECR Repository
                    docker push $FRONTEND_STG:$TAG
                    echo \"Docker Image Push to ECR Completed -  $FRONTEND_STG:$TAG\"
                """
            } else if (env.BRANCH_NAME == 'main') {
                echo "This is the prod branch"
                // Perform actions specific to prod branch
                sh """
                    echo \"Build started on `date`\"
                    echo Building the Docker image...
                    docker build --tag $FRONTEND_PROD:$TAG .
                    echo \"Build completed on `date`\"
                    echo Pushing the Docker image to ECR Repository
                    docker push $FRONTEND_PROD:$TAG
                    echo \"Docker Image Push to ECR Completed -  $FRONTEND_PROD:$TAG\"
                """
            } else {
                echo "This is an unknown branch: ${env.BRANCH_NAME} please follow the guidelines to upload your code"
            }
        }
      }
    }
    stage('Create pull request to the next branch') {
      // this are share across all no matter conditional
      environment {
        GIT_USER_NAME = "SalvadorM271"
        REPO_NAME = "testmernapp" // this is the same repo im monitoring with the pipeline
      }
      steps {
        withCredentials([string(credentialsId: 'github_token', variable: 'GITHUB_TOKEN')]) {
            script {
                if (env.BRANCH_NAME.startsWith("feature/")) {
                    echo "This is a feature branch: ${env.BRANCH_NAME}"
                    // Perform actions specific to feature branches
                    sh """
                        echo "Creating pull request from ${env.BRANCH_NAME} to develop"
                        curl -X POST \
                        -H "Authorization: token $GITHUB_TOKEN" \
                        -H "Accept: application/vnd.github+json" \
                        -d '{\"title\": \"Automated PR from ${env.BRANCH_NAME} to develop\", \"head\": \"${env.BRANCH_NAME}\", \"base\": \"develop\"}' \
                        https://api.github.com/repos/$GIT_USER_NAME/$REPO_NAME/pulls
                        
                    """
                } else if (env.BRANCH_NAME == 'develop') {
                    echo "This is the dev branch"
                    // Perform actions specific to dev branch
                    sh """
                        echo "Creating pull request from ${env.BRANCH_NAME} to staging"
                        curl -X POST \
                        -H "Authorization: token $GITHUB_TOKEN" \
                        -H "Accept: application/vnd.github+json" \
                        -d '{\"title\": \"Automated PR from ${env.BRANCH_NAME} to staging\", \"head\": \"${env.BRANCH_NAME}\", \"base\": \"staging\"}' \
                        https://api.github.com/repos/$GIT_USER_NAME/$REPO_NAME/pulls
                    """
                } else if (env.BRANCH_NAME == 'staging') {
                    echo "This is the stg branch"
                    // Perform actions specific to stg branch
                    sh """
                        echo "Creating pull request from ${env.BRANCH_NAME} to main"
                        curl -X POST \
                        -H "Authorization: token $GITHUB_TOKEN" \
                        -H "Accept: application/vnd.github+json" \
                        -d '{\"title\": \"Automated PR from ${env.BRANCH_NAME} to main\", \"head\": \"${env.BRANCH_NAME}\", \"base\": \"main\"}' \
                        https://api.github.com/repos/$GIT_USER_NAME/$REPO_NAME/pulls
                    """
                } else if (env.BRANCH_NAME == 'main') {
                    echo "This is the prod branch"
                    // Perform actions specific to prod branch
                    sh """
                        echo "no pull request needed"
                    """
                } else {
                    echo "This is an unknown branch: ${env.BRANCH_NAME} please follow the guidelines to upload your code"
                }
            }
        }
      }
    }
    
  }
}