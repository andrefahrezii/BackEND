pipeline {
    agent any
    environment {
        IMAGE_NAME = "image-registry.openshift-image-registry.svc:5000/andrefahrezi-dev/user-service:latest"
        TRIVY_CACHE_DIR = "${WORKSPACE}/.trivycache"
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
                    
                    sh 'curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b ${WORKSPACE}/.trivy_tmp'
                    
                    sh """
                    export TRIVY_USERNAME=openshift
                    export TRIVY_PASSWORD=\$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

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
                sh 'oc rollout status deployment/user-service --timeout=120s'
            }
        }
        stage('Health Check') {
            steps {
                script {
                    def route = sh(script: "oc get route user-service -o jsonpath='{.spec.host}'", returnStdout: true).trim()
                    sh "curl -f http://${route}/health || exit 1"
                }
            }
        }
    } // Akhir dari stages

    // Blok post diletakkan DI LUAR stages
    post {
        always {
            script {
                echo 'Membersihkan pod build yang selesai atau gagal...'
                sh 'oc delete pods -l buildconfig=user-service --field-selector=status.phase=Succeeded || true'
                sh 'oc delete pods -l buildconfig=user-service --field-selector=status.phase=Failed || true'
            }
        }
    }
}