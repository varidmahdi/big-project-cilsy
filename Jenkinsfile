pipeline {
    agent any
    stages {
        stage ('build landingpage') {
            steps {
                sh '''
                    sudo docker build -t cilsyari/landingpage:$GIT_BRANCH-$BUILD_ID -f landingpage/landingpage.Dockerfile .
                    sudo docker login -u cilsyari -p$DOCKER_TOKEN
                    sudo docker push cilsyari/landingpage:$GIT_BRANCH-$BUILD_ID
                '''
            }
        }
        stage ('change manifest file and send') {
            steps {
                sh '''
                    sed -i -e "s/branch/$GIT_BRANCH/" kube/landing.yml
                    sed -i -e "s/appversion/$BUILD_ID/" kube/landing.yml
                    tar -czvf manifest.tar.gz kube/landing.yml
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
                sshagent(credentials : ['k8s-master-ari']){
                    sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.kubernetes.retiarno.my.id tar -xvzf jenkins/manifest.tar.gz'
                    sh 'ssh -o StrictHostKeyChecking=no ubuntu@api.kubernetes.retiarno.my.id kubectl apply -f kube'
                }
            }
        }
    }
}