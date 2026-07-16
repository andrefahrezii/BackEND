stage('Security Scan') {
            steps {
                script {
                    sh 'rm -rf .trivycache'
                    // 1. Buat folder di luar /app (misalnya di /tmp atau langsung di workspace tapi di folder tersembunyi)
                    def TRIVY_BIN = "${WORKSPACE}/.trivy_tmp/trivy"
                    sh 'mkdir -p ${WORKSPACE}/.trivy_tmp'
                    
                    // 2. Instal ke folder tersebut
                    sh 'curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b ${WORKSPACE}/.trivy_tmp'
                    
                    // 3. Scan dengan menambahkan --skip-files
                    // Kita arahkan trivy untuk skip file binary-nya secara eksplisit
                    sh '''
                    export TRIVY_USERNAME=openshift
                    export TRIVY_PASSWORD=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
                    
                    ${TRIVY_BIN} image --scanners vuln \
                        --severity HIGH,CRITICAL \
                        --insecure \
                        --skip-files ${TRIVY_BIN} \
                        --exit-code 1 \
                        ${IMAGE_NAME}
                    '''
                }
            }
        }