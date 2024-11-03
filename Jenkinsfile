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
                            bat 'terraform destroy -auto-approve'
                        }
                    }
                }
            }
        }
    }
}
