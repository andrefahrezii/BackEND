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
                    sh 'rm -rf .trivycache'
                    sh '''
                    export TRIVY_CACHE_DIR=.trivycache
                    # 1. Pastikan Trivy terinstal
                    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b .
                    
                    # 2. Ambil token ServiceAccount untuk autentikasi ke registry
                    export TRIVY_USERNAME=openshift
                    export TRIVY_PASSWORD=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
                    
                    # 3. Jalankan scanning dengan kredensial token
                    ./trivy image --scanners vuln --insecure --exit-code 1 image-registry.openshift-image-registry.svc:5000/andrefahrezi-dev/user-service:latest
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