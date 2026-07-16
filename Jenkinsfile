pipeline {
    agent any
    environment {
        // Mendefinisikan lokasi image
        IMAGE_NAME = "image-registry.openshift-image-registry.svc:5000/andrefahrezi-dev/user-service:latest"
        TRIVY_CACHE_DIR = "${WORKSPACE}/.trivycache"
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
                    // 1. Bersihkan cache lama
                    sh 'rm -rf .trivycache'
                    
                    // 2. Instal Trivy ke /usr/local/bin (di luar direktori proyek)
                    // Menggunakan sudo jika diperlukan, atau langsung ke path yang dapat diakses
                    sh 'curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin'
                    
                    // 3. Autentikasi registry
                    withCredentials([string(credentialsId: 'openshift-token', variable: 'TOKEN')]) { // Opsional: Gunakan Jenkins Credentials jika ada
                        sh '''
                        export TRIVY_USERNAME=openshift
                        export TRIVY_PASSWORD=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
                        
                        # 4. Scan image (tidak akan memindai binary trivy karena berada di /usr/local/bin)
                        # Kita tambahkan --exit-code 1 hanya untuk HIGH dan CRITICAL
                        /usr/local/bin/trivy image --scanners vuln --severity HIGH,CRITICAL --insecure --exit-code 1 ${IMAGE_NAME}
                        '''
                    }
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