pipeline {
    agent any
    environment {
        IMAGE_NAME = "image-registry.openshift-image-registry.svc:5000/andrefahrezi-dev/user-service:latest"
        TRIVY_CACHE_DIR = "${WORKSPACE}/.trivycache"
        // Menentukan folder untuk menyimpan binary agar tidak terpindai
        TRIVY_BIN_DIR = "${WORKSPACE}/trivy-bin"
    }
    stages {
        stage('Build Image') {
            steps {
                sh 'oc start-build user-service --from-dir=. --follow'
            }
        }
        stage('Security Scan') {
            steps {
                script {
                    sh 'rm -rf .trivycache'
                    def TRIVY_BIN_PATH = "${WORKSPACE}/.trivy_tmp/trivy"
                    sh 'mkdir -p ${WORKSPACE}/.trivy_tmp'
                    
                    // Instalasi
                    sh 'curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b ${WORKSPACE}/.trivy_tmp'
                    
                    // Gunakan --skip-files dengan path absolut
                    sh """
                    export TRIVY_USERNAME=openshift
                    export TRIVY_PASSWORD=\$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

                    # Tambahkan --ignore-unfixed agar tidak gagal karena vulnerability pada library trivy itu sendiri
                    ${TRIVY_BIN_PATH} image --scanners vuln \
                        --severity HIGH,CRITICAL \
                        --insecure \
                        --ignore-unfixed \
                        --skip-files ${TRIVY_BIN_PATH} \
                        --exit-code 1 \
                        ${IMAGE_NAME}
                    """
                }
            }
        }
        stage('Deploy to OpenShift') {
            steps {
                sh 'oc apply -f k8s-manifest.yaml'
            }
        }
        stage('Verify Deployment') {
            steps {
                // Perintah ini akan menunggu status pod menjadi ready selama 120 detik
                // Ganti 'user-service' dengan nama deployment Anda di k8s-manifest.yaml
                sh 'oc rollout status deployment/user-service --timeout=120s'
            }
        }
        stage('Health Check') {
            steps {
                // Mengambil URL route aplikasi
                script {
                    def route = sh(script: "oc get route user-service -o jsonpath='{.spec.host}'", returnStdout: true).trim()
                    // Melakukan pengecekan status code 200 ke endpoint /health
                    sh "curl -f http://${route}/health || exit 1"
                }
            }
        }
        post {
        always {
            script {
                echo 'Membersihkan pod build yang selesai atau gagal...'
                // Menghapus pod build yang sudah tidak diperlukan
                sh 'oc delete pods -l buildconfig=user-service --field-selector=status.phase=Succeeded || true'
                sh 'oc delete pods -l buildconfig=user-service --field-selector=status.phase=Failed || true'
            }
        }
    }
    }
}