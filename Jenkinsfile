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
        stage ('change manifest file and send') {
            steps {
                sh '''
                    sed -i -e "s/branch/$GIT_BRANCH/" k8s/production/landingpage/landingpage.yml
                    sed -i -e "s/appversion/$BUILD_ID/" k8s/production/landingpage/landingpage.yml
                    sed -i -e "s/branch/$GIT_BRANCH/" k8s/production/sosmed/sosmed.yml
                    sed -i -e "s/appversion/$BUILD_ID/" k8s/production/sosmed/sosmed.yml
                    tar -czvf manifest.tar.gz k8s/*
                '''
                sshPublisher(
                    continueOnError: false, 
                    failOnError: true,
                    publishers: [
                        sshPublisherDesc(
                            configName: "k8s-master",
                            transfers: [sshTransfer(sourceFiles: 'manifest.tar.gz', remoteDirectory: 'jenkins/')],
                            verbose: true
                        )
                    ]
                )
            }
        }
        stage ('deploy to k8s cluster') {
            steps {
                sshagent(credentials : ['k8s-master-farid']){
                    sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id tar -xvzf jenkins/manifest.tar.gz'
                    sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/production/namespace/'
                    sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/production/landingpage/'
                    sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/production/sosmed/'
                    sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/production/wordpress/'
                    sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/ingress/'
                }
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
        stage('Push Notification') {
            steps {
                script{
                    withCredentials([string(credentialsId: 'telegramToken', variable: 'TOKEN'),
                    string(credentialsId: 'telegramChatId', variable: 'CHAT_ID')]) {
                    sh '''
                        curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode="HTML" -d text="<b>Project.</b> : POC \
                        <b>Branch</b>: master \
                        <b>Build </b> : OK \
                        <b>Test suite</b> = Passed"
                        '''
                    }
                }
            }
        }
    }
}