pipeline {
    agent any
    stages {
        stage('Build Image') {
            steps {
                script {
                    sh 'oc start-build user-service --from-dir=. --follow'
                }
            }
        }
        stage('Security Scan') {
            steps {
                script {
                    // Mengunduh dan menginstal Trivy secara dinamis di dalam pipeline
                    sh '''
                    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
                    trivy image --exit-code 1 user-service:latest
                    '''
                }
            }
        }
        stage('Deploy to OpenShift') {
            steps {
                // Perintah untuk deploy ke OpenShift tanpa SSH
                sh 'oc apply -f k8s-manifest.yaml'
            }
        }
    }
}