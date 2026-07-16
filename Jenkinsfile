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
                    sh '''
                    export TRIVY_CACHE_DIR=.trivycache
                    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b .
                    
                    # Gunakan alamat internal registry OpenShift
                    # Format: <registry-service>:<port>/<project>/<image>:<tag>
                    ./trivy image --exit-code 1 image-registry.openshift-image-registry.svc:5000/andrefahrezi-dev/user-service:latest
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