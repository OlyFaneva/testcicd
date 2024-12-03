pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'olyfaneva/back-end'
        DOCKER_TAG = 'latest'
        REPO_URL = 'https://github.com/OlyFaneva/testcicd.git'
        SSH_CREDENTIALS = credentials('')  // Jenkins credentials for VPS
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
                    sh '''
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    '''
                }
            }
        }

        // Étape 3: Pousser l'image Docker vers Docker Hub
        stage('Push to Docker Hub') {
            steps {
                script {
                    echo 'Pushing Docker image to Docker Hub'
                    withDockerRegistry([credentialsId: 'dockebcmbm r', url: 'https://index.docker.io/v1/']) {
                        sh '''
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        '''
                    }
                }
            }
        }

        // Étape 4: Déployer sur le VPS
        stage('Deploy to VPS') {
            steps {
                script {
                    echo 'Deploying to VPS'
                    sh '''
                        sshpass -p "${SSH_CREDENTIALS_PSW}" ssh -o StrictHostKeyChecking=no ${SSH_CREDENTIALS_USR}@89.116.111.200 << EOF
                        docker pull ${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker stop back-end || true
                        docker rm back-end || true
                        docker run -d --name back-end -p 8080:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}
EOF
                    '''
                }
            }
        }

        stage('Check Workspace') {
            steps {
                sh 'ls -R'
            }
        }

        // Étape 5: Exécution du Playbook Ansible (facultatif)
        stage('Run Ansible Playbook') {
            steps {
                script {
                    echo 'Running Ansible playbook'
                    sh '''
                            ansible-playbook -i hosts.ini deploy.yml
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check the logs.'
        }
    }
}
