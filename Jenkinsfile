#!groovy

pipeline {
	agent {label "devel9"}
	environment {
		DOCKER_TAG = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
		GITLAB_PRIVATE_TOKEN = credentials("ai-gitlab-api-token")
		LOWELL_URL = credentials("lowell_db_connection_string")
	}
	triggers {
		pollSCM("H/02 * * * *")
		cron("0 23 * * 7")
	}
	stages {
		stage("docker build model") {
			steps {
				script {
					solr_container = docker.build("docker-xp.dbc.dk/filmstriben-solr", "--no-cache .").run("-P --rm")
					recommender_image = docker.image("docker.dbc.dk/dbc-filmstriben-recommender-new:indexer-test-1")
					// Run the container like this to be able to run it in the foreground
					docker.script.sh(script: "docker run --rm -e LOWELL_URL=${LOWELL_URL} --net host ${recommender_image.id} filmstriben-index http://${solr_container.port(8983)}/solr/filmstriben", returnStdout: true).trim()
					sh "rm -r data"
					docker.script.sh(script: "docker cp ${solr_container.id}:/opt/solr/server/solr/filmstriben/data data")
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
