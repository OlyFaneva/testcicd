pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'olyfaneva/projectlaravel'
        DOCKER_TAG = 'latest'
        REPO_URL = 'https://github.com/OlyFaneva/ProjetFullPHP.git'
        SSH_CREDENTIALS = credentials('vps')
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    echo "Cloning repository: ${REPO_URL}"
                    git url: "${REPO_URL}", branch: 'main'
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    echo "Installing Laravel dependencies"
                    sh '''
                        docker run --rm \
                        -v $(pwd):/app \
                        -w /app composer:latest composer install --no-dev --optimize-autoloader
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    sh '''
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    echo "Pushing Docker image to Docker Hub"
                    withDockerRegistry([credentialsId: 'docker', url: 'https://index.docker.io/v1/']) {
                        sh '''
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        '''
                    }
                }
            }
        }

        stage('Deploy to VPS') {
            steps {
                script {
                    echo "Deploying to VPS"
                    sh '''
                        sshpass -p "${SSH_CREDENTIALS_PSW}" ssh -o StrictHostKeyChecking=no ${SSH_CREDENTIALS_USR}@89.116.111.200 << EOF
                            docker pull ${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker stop my-laravel-app || true
                            docker rm my-laravel-app || true
                            docker run -d --name my-laravel-app \
                                -p 80:80 \
                                -e APP_ENV=production \
                                -e APP_KEY=base64:your-base64-key-here \
                                -v /path/to/storage:/app/storage \
                                ${DOCKER_IMAGE}:${DOCKER_TAG}
                        EOF
                    '''
                }
            }
        }

        stage('Run Migrations') {
            steps {
                script {
                    echo "Running database migrations"
                    sh '''
                        sshpass -p "${SSH_CREDENTIALS_PSW}" ssh -o StrictHostKeyChecking=no ${SSH_CREDENTIALS_USR}@89.116.111.200 << EOF
                            docker exec my-laravel-app php artisan migrate --force
                        EOF
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Please check the logs for more details."
        }
    }
}
