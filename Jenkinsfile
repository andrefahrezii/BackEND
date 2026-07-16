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
                    sh 'mkdir -p ${TRIVY_BIN_DIR}'
                    
                    // Instal ke folder lokal yang pasti punya izin akses
                    sh 'curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b ${TRIVY_BIN_DIR}'
                    
                    sh '''
                    export TRIVY_USERNAME=openshift
                    export TRIVY_PASSWORD=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
                    
                    # Jalankan scan dengan mengecualikan folder binary trivy agar tidak kena false positive
                    ${TRIVY_BIN_DIR}/trivy image --scanners vuln --severity HIGH,CRITICAL --insecure --skip-dirs ${TRIVY_BIN_DIR} --exit-code 1 ${IMAGE_NAME}
                    '''
                }
            }
        }
        stage('Deploy to OpenShift') {
            steps {
                sh 'oc apply -f k8s-manifest.yaml'
            }
        }
    }
}