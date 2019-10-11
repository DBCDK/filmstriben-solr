#!groovy

workerNode = "devel9"

pipeline {
	agent {label workerNode}
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
					solr_container = docker.build("filmstriben-solr", "--no-cache .").run("-P")
					recommender_image = docker.image("docker.dbc.dk/dbc-filmstriben-recommender-new:indexer-test-1")
					// Run the container like this to be able to run it in the foreground
					docker.script.sh(script: "docker run --rm -e LOWELL_URL=${LOWELL_URL} --net host ${recommender_image.id} filmstriben-index http://${solr_container.port(8983)}/solr/filmstriben", returnStdout: true).trim()
					sh "rm -r data"
					// take data from the temporary solr container to include in the final solr image
					docker.script.sh(script: "docker cp ${solr_container.id}:/opt/solr/server/solr/filmstriben/data data")
					image = docker.build("docker-xp.dbc.dk/filmstriben-solr:${DOCKER_TAG}", "--no-cache .")
					image.push()
					if(env.BRANCH_NAME == "master") {
						image.push("latest")
					}
					// clean up indexed data to avoid it being used in the next build
					sh "rm -r data"
					solr_container.stop()
				}
			}
		}
		stage("update staging version number") {
			agent {
				docker {
					label workerNode
					image "docker.dbc.dk/build-env"
					alwaysPull true
				}
			}
			when {
				branch "master"
			}
			steps {
				dir("deploy") {
					sh "set-new-version filmstriben-solr-1-0.yml ${env.GITLAB_PRIVATE_TOKEN} ai/filmstriben-solr-secrets ${env.DOCKER_TAG} -b staging"
				}
				build job: "ai/filmstriben-solr-deploy/staging", wait: true
			}
		}
	}
}
