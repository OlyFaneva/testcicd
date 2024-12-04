pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'olyfaneva/back-end'
        DOCKER_TAG = 'latest'
        REPO_URL = 'https://github.com/OlyFaneva/testcicd.git'
    }

    stages {
        // Étape 1: Cloner le dépôt Git
        stage('Clone Repository') {
            steps {
                script {
                    echo "Cloning repository: ${REPO_URL}"
                    git url: "${REPO_URL}", branch: 'main'
                }
            }
        }

        // Étape 2: Construire l'image Docker
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                }
            }
        }

        // Étape 3: Pousser l'image Docker vers Docker Hub
        stage('Push to Docker Hub') {
            steps {
                script {
                    echo "Pushing Docker image to Docker Hub"
                    withDockerRegistry([credentialsId: 'docker', url: 'https://index.docker.io/v1/']) {
                        sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    }
                }
            }
        }

        stage('Deploy to VPS') {
    steps {
        script {
            echo 'Deploying to VPS'
            withCredentials([usernamePassword(credentialsId: 'vps', usernameVariable: 'SSH_CREDENTIALS_USR', passwordVariable: 'SSH_CREDENTIALS_PSW')]) {
                sh """
                    sshpass -p "${SSH_CREDENTIALS_PSW}" ssh -o StrictHostKeyChecking=no ${SSH_CREDENTIALS_USR}@89.116.111.200 << EOF
                        docker pull ${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker stop backend || true
                        docker rm backend || true
                        docker run -d --name backend -p 8000:8005 ${DOCKER_IMAGE}:${DOCKER_TAG}
EOF
                """
            }
        }
    }
}


        stage('Run Ansible Playbook') {
            steps {
                script {
                    echo "Running Ansible playbook"
                    sh '''
                        ansible-playbook -i hosts.ini deploy.yml
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished"
        }
        success {
            echo "Pipeline succeeded"
        }
        failure {
            echo "Pipeline failed"
        }
    }
}
