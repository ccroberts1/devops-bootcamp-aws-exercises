pipeline {
    agent any
    tools {
        nodejs "node"
    }
    stages {
        stage('Run tests'){
            steps {
                dir("app"){
                    script {
                        echo "Testing the app..."
                        sh "npm install"
                        sh "npm run test"
                    }
                }
            }
        }
        stage('Increment version') {
            steps {
                dir("app") {
                    script {
                        echo "Incrementing version..."
                        sh "npm version minor"
                        def packageJson = readJSON file: 'package.json'
                        def version = packageJson.version

                        env.IMAGE_NAME = "$version-$BUILD_NUMBER"
                    }
                }
            }
        }
        stage('Build and push Docker image'){
            steps {
                script {
                    echo "Building the Docker image..."
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "docker build -t ccroberts/demo-app:${IMAGE_NAME} ."
                        sh 'echo $PASS | docker login -u ${USER} --password-stdin'
                        sh "docker push ccroberts1/demo-app:${IMAGE_NAME}"
                    }
                }
            }
        }
        stage('deploy to EC2'){
          steps {
            script {
                def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME}"
                def ec2Instance = "ec2-user@44.193.30.29"

                sshagent(['ec2-server-key']) {
                    sh "scp -o StrictHostKeyChecking=no server.cmds.sh ${ec2Instance}:/home/ec2-user"
                    sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                    sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                }
            }
          }
        }
        stage('Commit version update'){
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github-credentials', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh 'git config --global user.email "jenkins@example.com"'
                        sh 'git config --global user.name "jenkins"'

                        sh "git status"
                        sh "git branch"
                        sh "git config --list"

                        sh "git add ."
                        sh 'git commit -m "ci:version bump"'
                        sh "git push https://${USER}:${PASS}@github.com/${USER}/devops-bootcamp-aws-exercises"
                    }
                }
            }
        }
}