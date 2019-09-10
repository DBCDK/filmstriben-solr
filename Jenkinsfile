#!groovy

pipeline {
	agent {label "devel9"}
	environment {
		DOCKER_TAG = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
		GITLAB_PRIVATE_TOKEN = credentials("ai-gitlab-api-token")
	}
	triggers {
		pollSCM("H/02 * * * *")
		cron("0 23 * * 7")
	}
	stages {
		stage("docker build model") {
			steps {
				script {
					image = docker.build("docker-xp.dbc.dk/filmstriben-solr:${DOCKER_TAG}", "--no-cache .")
					image.push()
					if(env.BRANCH_NAME == "master") {
						image.push("latest")
					}
				}
			}
		}
	}
}
