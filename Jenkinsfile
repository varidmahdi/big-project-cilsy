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
        stage ('change manifest file and send') {
            steps {
                sh '''
                    sed -i -e "s/branch/$GIT_BRANCH/" k8s/landingpage.yml
                    sed -i -e "s/appversion/$BUILD_ID/" k8s/landingpage.yml
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
                    sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/namespace/'
                    sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/'
                    sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.lokaljuara.id kubectl apply -f ./k8s/ingress/'
                }
            }
        }
    }
}