pipeline {
    agent any

    environment {
        AWS_CREDENTIALS = credentials('AWS_CREDENTIALS')
        EC2_IP = "EC2_IP"
        SSH_KEY = credentials('ec2-ssh-key')
    }

    stages {
        stage('Provision Infrastructure with Terraform') {
            steps {
                dir('terraform') {
                    script {
                        withAWS(credentials: 'AWS_CREDENTIALS', region: 'ap-south-1') {
                            sh 'terraform init'
                            sh 'terraform apply -auto-approve'
                            EC2_IP = sh(script: "terraform output -raw ec2_ip_address", returnStdout: true).trim()
                        }
                    }
                }
            }
        }

        stage('Install Docker on EC2') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no ec2-user@${EC2_IP} << EOF
                    sudo apt-get update
                    sudo apt-get install -y docker.io docker-compose
                    EOF
                    '''
                }
            }
        }

        stage('Deploy Drupal using Docker Compose') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh '''
                    scp docker-compose.yml ec2-user@${EC2_IP}:/home/ec2-user/
                    ssh ec2-user@${EC2_IP} 'docker-compose up -d'
                    '''
                }
            }
        }


        stage('Health Check & Rollback') {
            steps {
                script {
                    def response = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://${EC2_IP}", returnStdout: true)
                    if (response != '200') {
                        echo "Deployment failed, initiating rollback..."
                        sshagent(['ec2-ssh-key']) {
                            sh '''
                            ssh ec2-user@${EC2_IP} 'docker-compose down'
                            ssh ec2-user@${EC2_IP} 'docker-compose -f docker-compose-stable.yml up -d'
                            '''
                        }
                    } else {
                        echo "Deployment successful"
                    }
                }
            }
        }
    }
}
