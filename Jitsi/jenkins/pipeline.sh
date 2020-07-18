    // #############################################################
    // #              O                                            #
    // #       /~~~|#|]|=\|---\__                                  #
    // #     |-=_____________  |\\ ,             O       O         #
    // #    I|_/,-.-.-.-.-,-.\_|='(             T/\     /\=,---.   #
    // #       ( o )( o )( o )     \            U /\   /\   `O'    #
    // #        `-'-'-'-'-`-'                                      #
    // #                                                           #
    // #                                                           #
    // #              Pipeline under construction                  #
    // #                                                           #
    // #                                                           #
    // #############################################################


    GIT_URL             = "http://portal-developers.amxdigital.net/MCP_Ecuador/EC-ReactAPP.git";
    MAIN_PROJ_SONAR_TAG = "amx.mcp-ec.react-front"
    HEALTHCHECK_COMMAND = "/usr/bin/curl --fail http://localhost:8761/health"
    JNKS_PROP_MAX_ARTEF = 1
    RUN_ON_PORT=9080
    REMOTE_RO_REGISTRY  = "dockeregistry.amovildigitalops.com"
    CONTAINER_NAME="ec-reactapp"

    properties([    buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: "${JNKS_PROP_MAX_ARTEF}")), 
                    disableConcurrentBuilds(),
                    gitLabConnection(''),
                    [$class: 'GitlabLogoProperty', repositoryName: ''],
                    parameters([ 
                        string(defaultValue: 'master', description: 'Compile with git branch:', name: 'USERPARAM_GIT_BRANCH', trim: false),
                ])])

    node('rh7-jenkins-slave-docker-node10') {
        step([$class: 'WsCleanup'])
        stage('Pull git code') {
            git branch: "${USERPARAM_GIT_BRANCH}", credentialsId: 'git-jenkins-amx', url: "${GIT_URL}"
        }
        stage('set npm new registry'){
            sh 'npm config set registry http://nexus.amx-dev.amxdigital.net/repository/npm-registry'
        }

        stage('npm build'){
            
            sh """#!/bin/bash -x

                    npm install react-scripts
                    npm run build
                    """
        }

        stage('Save artifacts'){
            sh """#!/bin/bash -x
            echo "Will stash:"
            cd build/ 
            ls
            """
            dir('build/'){
                stash includes: '**', name: 'proj-stash', excludes: 'build.xml,** /node_modules/*,.scanner-work/'
                archiveArtifacts artifacts: '**', excludes: 'build.xml,** /node_modules/*,.scanner-work/'
            }
        }   

        stage('Sonar Qube automated Testing'){
            withSonarQubeEnv('amx.sonarqube') {
                withEnv(['random_var=true']) {                
                    try{                    
                        dir("${MAIN_PROJ_DIRECTORY}"){
                            sh """#!/bin/bash -x
                            bash /opt/sonar-scanner-3.2.0.1227/bin/sonar-scanner -X -Dsonar.projectKey=${MAIN_PROJ_SONAR_TAG} -Dsonar.sources=\$(pwd) -Dsonar.projectVersion=${BUILD_NUMBER} -Dsonar.exclusions=\"**/node_modules/*\"
                            """
                        }
                    }catch(all){
                        //input 'debug here'
                    }
                }        
            }
        } // End stage Sonar Qube automated Testing
    } // End node('rh7-jenkins-slave-docker-node10')

    node('docker-docker-jnlp-slave'){
        stage('Build Docker image'){
            unstash 'proj-stash'
            sh "tar czf mcp-ec.tar.gz *"
            sh """#!/bin/bash -x
                echo target
                mkdir target
                cat > default.conf <<XXEOFXX
server {
    listen       8080 default;
    server_name  _;    
    access_log  /var/log/nginx/access.log;
    error_log   /var/log/nginx/error.log;
    root   /var/www/sites/default/web/;
    location / {        
        index  index.html index.htm;
        try_files \\\$uri \\\$uri/ /index.html\$is_args\$args =404;
        error_page 404 =200 /index.html;
        add_header Cache-Control no-cache;
    }
}
XXEOFXX
                            
                cat > Dockerfile <<XXEOFXX
FROM ${REMOTE_RO_REGISTRY}/atomic-rhel7-nginx
ADD mcp-ec.tar.gz /var/www/sites/default/web/
ADD default.conf /etc/nginx/conf.d/
LABEL Description='Built with Jenkins job_name=${JOB_NAME} build_number=${BUILD_NUMBER}'
HEALTHCHECK --interval=60s --timeout=10s --retries=4 CMD ${HEALTHCHECK_COMMAND}
ENTRYPOINT ["/sbin/docker-entrypoint.sh"]
XXEOFXX
            """
            withDockerServer([uri: 'AMXDVMKBLD-1.amx-dev.amxdigital.net:2376']) {
                withDockerRegistry(credentialsId: 'amxdigital-docker-nexus-user', url: 'http://dockeregistry.amovildigitalops.com') {
                    sh """#!/bin/bash -x                                    
                        docker build -t docker-nxr.amx-dev.amxdigital.net/${JOB_NAME}:${BUILD_NUMBER} . \
                    """
                }
                    
                withDockerRegistry(credentialsId: 'docker-nxr-amxdigital-docker-nexus-user', url: 'http://docker-nxr.amx-dev.amxdigital.net') {
                    sh """#!/bin/bash -x                                    
                        docker push docker-nxr.amx-dev.amxdigital.net/${JOB_NAME}:${BUILD_NUMBER} \
                        && docker rmi docker-nxr.amx-dev.amxdigital.net/${JOB_NAME}:${BUILD_NUMBER}
                            
                    """
                }
            }
        } // End stage build docker image

        stage('Deploy and run Docker container dev'){
            withDockerServer([uri: 'AMXDEVUAPP1-1.amx-dev.amxdigital.net:2376']) {
                withDockerRegistry(credentialsId: 'docker-nxr-amxdigital-docker-nexus-user', url: 'http://docker-nxr.amx-dev.amxdigital.net') {
                    sh """#!/bin/bash -x                                    
                        docker pull docker-nxr.amx-dev.amxdigital.net/${JOB_NAME}:${BUILD_NUMBER}
                        docker rm -f ${CONTAINER_NAME} || true
                        docker run -td --name=${CONTAINER_NAME} --dns=172.26.127.206 -p ${RUN_ON_PORT}:8080 \
                            docker-nxr.amx-dev.amxdigital.net/${JOB_NAME}:${BUILD_NUMBER} \
                        docker image prune -a  -f
                    """
                            
                }
            }
        }
    }


    /*input message: '¿Deploy to QA environment?', ok: 'Go! and notify QA team'

    stage('Confirm deploy to QA'){
        //NGINX (HAY QA?)
    }
    stage('Automatic QA testing'){
        //PROBABLEMENTE NO SE PUEDAN REALIZAR. ¿APLICAR CURL? SI NO FUNCIONA, THEN ROLLBACK
    }
    */

    def qaPromotionAutorization=""

    stage('Confirm deploy to Prod'){
        //ENVÍO DE CORREO A OTRS PARA QUE SE PROCEDA CON CI-CONSOLE-NG
        //DESIGNAR RESPONSABLE DE VO.BO. POR PASE A PROD. ¿LÍDER DE PROYECTO?
    }


    //node('docker-docker-jnlp-slave'){
        /*stage('Build Docker image'){
            unstash 'jar-stash'
            sh """#!/bin/bash +x        
            mkdir target        
            echo -e \"FROM dockeregistry.amovildigitalops.com/atomic-rhel7-java-8
            ADD target/*.jar /home/jvm/
            LABEL USERVICE_JAR_FILE=`ls target/ | grep "\\.jar"`
            LABEL Description='Built with Jenkins on ${JOB_BASE_NAME} - ${JOB_NAME}#${BUILD_NUMBER}'\" > Dockerfile
            """
            withDockerServer([uri: 'AMXDVMKBLD-1.amx-dev.amxdigital.net:2376']) {
                withDockerRegistry(credentialsId: 'amxdigital-docker-nexus-user', url: 'http://dockeregistry.amovildigitalops.com') {
                    withDockerRegistry(credentialsId: 'docker-nxr-amxdigital-docker-nexus-user', url: 'http://docker-nxr.amx-dev.amxdigital.net') {
                        sh """#!/bin/bash +x                                    
                            docker build -t docker-nxr.amx-dev.amxdigital.net/${JOB_BASE_NAME}:${BUILD_NUMBER} . \
                            && docker push docker-nxr.amx-dev.amxdigital.net/${JOB_BASE_NAME}:${BUILD_NUMBER} \
                            && docker rmi docker-nxr.amx-dev.amxdigital.net/${JOB_BASE_NAME}:${BUILD_NUMBER}
                    
                        """
                    }
                }
            }
        }*/
    //}