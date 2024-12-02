pipeline {  
    agent any  

    environment {  
        DOCKER_IMAGE = 'olyfaneva/projetfullphp'  // Change this to your actual image name  
        DOCKER_TAG = 'latest'  
        REPO_URL = 'git@github.com:OlyFaneva/testcicd.git'  // Replace with your repo URL  
        SSH_CREDENTIALS = credentials('vps')  
    }  

    stages {  
        stage('Clone Repository') {  
            steps {  
                script {  
                    echo "Cloning repository: ${REPO_URL}"  
                    // Increase Git buffer size  
                    sh 'git config --global http.postBuffer 524288000' // 500 MB  
                    git url: "${REPO_URL}", branch: 'main'  
                }  
            }  
        }  

        stage('Install Dependencies') {  
            steps {  
                script {  
                    echo "Installing Laravel dependencies"  
                    sh '''  
                        docker run --rm -v "/var/jenkins_home/workspace/Pipeline Back-End":/app -w /app composer:latest composer install --no-dev --optimize-autoloader  
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
                            docker stop my-app || true  
                            docker rm my-app || true  
                            docker run -d --name my-app -p 80:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}  
                        EOF  
                    '''  
                }  
            }  
        }  

        // stage('Run Ansible Playbook') {  
        //     steps {  
        //         script {  
        //             echo "Running Ansible playbook"  
        //             sh '''  
        //                 ansible-playbook -i /path/to/hosts.ini /path/to/deploy.yml   
        //             '''  
        //         }  
        //     }  
        // }  
    }  

    post {  
        always {  
            echo 'Pipeline finished.'  
        }  
        failure {  
            echo 'Pipeline failed. Please check the logs for more details.'  
        }  
    }  
}