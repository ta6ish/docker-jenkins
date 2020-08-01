#!/usr/bin/env groovy
pipeline {
  agent any
  stages {

    stage('test') {
      steps {
        sh "docker container run --rm -w /app -v \$(pwd):/app node:10.17.0 bash -c 'npm i -D && npm run test && rm -rf node_modules/'"
      }
    }

    stage('package') {
      steps {
        sh "chmod +x ./scripts/build.sh"
        sh "./scripts/build.sh"
      }
    }

    stage('deploy') {
      steps {
        sh "chmod +x ./scripts/deploy.sh"
        sh "./scripts/deploy.sh"
      }
    }

  }
}
