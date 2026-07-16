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
                    // Gunakan direktori lokal yang dapat diakses oleh user Jenkins saat ini
                    sh '''
                    export TRIVY_CACHE_DIR=.trivycache
                    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b .
                    ./trivy image --exit-code 1 user-service:latest
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