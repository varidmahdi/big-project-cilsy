pipeline {
    agent any
    stages {
        stage ('build landingpage') {
            steps {
                sh '''
                    sudo docker build -t varidmahdi/landingpage:$GIT_BRANCH-$BUILD_ID -f landingpage/ops/Dockerfile.landingpage .
                    sudo docker login -u varidmahdi -p$DOCKER_TOKEN
                    sudo docker push varidmahdi/landingpage:$GIT_BRANCH-$BUILD_ID
                '''
            }
        }
        stage ('build sosmed') {
            steps {
                sh '''
                    sudo docker build -t varidmahdi/sosmed:$GIT_BRANCH-$BUILD_ID -f sosmed/ops/Dockerfile.sosmed .
                    sudo docker login -u varidmahdi -p$DOCKER_TOKEN
                    sudo docker push varidmahdi/sosmed:$GIT_BRANCH-$BUILD_ID
                '''
            }
        }
        stage ('clean workspace') {
            steps {
                sshagent(credentials : ['k8s-master-farid']){
                    sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id rm -rf k8s/'
                    sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id rm -rf jenkins/'
                }
            }
        }
        stage ('change manifest file and send') {
            parallel {
                stage ('for production') {
                    when {
                        branch 'main'
                    }
                    steps {
                        sh '''
                            sed -i -e "s/branch/$GIT_BRANCH/" k8s/production/landingpage/landingpage.yml
                            sed -i -e "s/appversion/$BUILD_ID/" k8s/production/landingpage/landingpage.yml
                            sed -i -e "s/branch/$GIT_BRANCH/" k8s/production/sosmed/sosmed.yml
                            sed -i -e "s/appversion/$BUILD_ID/" k8s/production/sosmed/sosmed.yml
                            tar -czvf manifest-production.tar.gz k8s/production/ k8s/ingress/
                        '''
                        sshPublisher(
                            continueOnError: false, 
                            failOnError: true,
                            publishers: [
                                sshPublisherDesc(
                                    configName: "k8s-master",
                                    transfers: [sshTransfer(sourceFiles: 'manifest-production.tar.gz', remoteDirectory: 'jenkins/')],
                                    verbose: true
                                )
                            ]
                        )
                    }
                }
                stage ('for staging') {
                    when {
                        branch 'staging'
                    }
                    steps {
                        sh '''
                            sed -i -e "s/branch/$GIT_BRANCH/" k8s/staging/landingpage/landingpage.yml
                            sed -i -e "s/appversion/$BUILD_ID/" k8s/staging/landingpage/landingpage.yml
                            sed -i -e "s/branch/$GIT_BRANCH/" k8s/staging/sosmed/sosmed.yml
                            sed -i -e "s/appversion/$BUILD_ID/" k8s/staging/sosmed/sosmed.yml
                            tar -czvf manifest-staging.tar.gz k8s/staging/ k8s/ingress/
                        '''
                        sshPublisher(
                            continueOnError: false, 
                            failOnError: true,
                            publishers: [
                                sshPublisherDesc(
                                    configName: "k8s-master",
                                    transfers: [sshTransfer(sourceFiles: 'manifest-staging.tar.gz', remoteDirectory: 'jenkins/')],
                                    verbose: true
                                )
                            ]
                        )
                    }
                }
            }
            
        }
        stage ('deploy to k8s cluster') {
            parallel {
                stage ('for production') {
                    when {
                        branch 'main'
                    }
                    steps {
                        sshagent(credentials : ['k8s-master-farid']){
                            sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id tar -xvzf jenkins/manifest-production.tar.gz'
                            sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/production/namespace/'
                            sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/production/landingpage/'
                            sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/production/sosmed/'
                            sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/production/wordpress/'
                            sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/ingress/'
                        }
                    }
                }
                stage ('for staging') {
                    when {
                        branch 'staging'
                    }
                    steps {
                        sshagent(credentials : ['k8s-master-farid']){
                            sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id tar -xvzf jenkins/manifest-staging.tar.gz'
                            sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/staging/namespace/'
                            sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/staging/landingpage/'
                            sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/staging/sosmed/'
                            sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/staging/wordpress/'
                            sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/ingress/'
                        }
                    }
                }
            }
        }
        stage('Push Notification') {
            steps {
                script{
                    withCredentials([string(credentialsId: 'telegramToken', variable: 'TOKEN'),
                    string(credentialsId: 'telegramChatId', variable: 'CHAT_ID')]) {
                    sh '''
                        curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode="HTML" -d text="<b>Project</b> : Big Project Cilsy %0A<b>Branch</b> : $GIT_BRANCH %0A<b>Deploying</b> : Success"
                        '''
                    }
                }
            }
        }
    }
}