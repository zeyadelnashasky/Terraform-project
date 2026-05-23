pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-north-1'
        ECR_REPO = 'my-registry'
        AWS_ACCOUNT_ID = '200098097766'

        IMAGE_TAG = "${BUILD_NUMBER}"

        ECR_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
    }

    stages {

        stage('Clone Repository') {
            steps {
                git branch: 'main',
                url: 'https://github.com/zeyadelnashasky/Terraform-project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t shopflow ./application'
            }
        }

        stage('AWS Operations') {
            steps {

                withAWS(credentials: 'aws-credential', region: 'eu-north-1') {

                    sh 'aws sts get-caller-identity'

                    sh '''
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin \
                    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                    '''

                    sh '''
                    docker tag shopflow:latest $ECR_URI:$IMAGE_TAG
                    docker tag shopflow:latest $ECR_URI:latest
                    '''

                    sh '''
                    docker push $ECR_URI:$IMAGE_TAG
                    docker push $ECR_URI:latest
                    '''

                    sh 'terraform init'
                    sh 'terraform validate'
                    sh 'terraform plan'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment completed successfully.'
        }

        failure {
            echo 'Pipeline failed.'
        }
    }
}
