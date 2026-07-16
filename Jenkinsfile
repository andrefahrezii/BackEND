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
                // Di sini Anda akan menggunakan Trivy untuk scan image
                // Jika ditemukan kerentanan (vulnerability), pipeline akan berhenti otomatis
                sh 'trivy image --exit-code 1 user-service:v1'
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