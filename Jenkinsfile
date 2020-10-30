#!groovy

properties([[$class: 'GitLabConnectionProperty', gitLabConnection: 'GitLab']])

serviceName = 'fo-migration'
branchName = env['BRANCH_NAME']
envName = buildUtilities.getEnvironmentName(branchName)

buildUtilities.initVars(branchName, envName)

serviceStartDelay = 60 // seconds 
serviceRetryDelay = 30  // seconds
serviceRetryCount = 15

node {
    gitlabBuilds(builds: buildUtilities.buildsList) {
    	stage('setup') {
			gitlabCommitStatus(name: 'setup') {
                buildUtilities.setup()
    		}
		}
    
        stage('version check') {
            gitlabCommitStatus(name: 'version check') {
                buildUtilities.versionCheck(getCodeVersion())
           }
        }
    
    	stage('verify') {
    		gitlabCommitStatus(name: 'verify') {  		
                buildUtilities.sonarVerify(getProjectVersion(), branchName)
    		}
    	}
    
    	stage('build') {
    		gitlabCommitStatus(name: 'build') {
    			docker.withRegistry(buildUtilities.dockerRepoURI, 'docker-repo-login') {
    				def dockerImage = docker.build(serviceName)
    				def taggedImageName = dockerImage.tag(getProjectVersion())
    				sh "docker push ${taggedImageName}"
    				sh "docker rmi -f ${taggedImageName}"
    			}
    		}
    	}
    
        if (branchName.startsWith('dv') || branchName == 'master') {
            stage('automated-tests') {
                gitlabCommitStatus(name: 'automated-tests') {
                    buildUtilities.deployToEnvironment(envName, serviceName, branchName, getProjectVersion())
                    if (buildUtilities.ensureDeploymentIsReady(envName, serviceName, getProjectVersion(), serviceStartDelay, serviceRetryDelay, serviceRetryCount)) {
                        runAutomatedTests(envName)
                    }
                    else {
                        sh "exit 1;"                        
                    }
                }
            
            }
        }

    	if(branchName == 'master')
    	{
    		stage('deploy') {
    			gitlabCommitStatus(name: 'deploy') {
					buildUtilities.deployToAllDevEnvironments(serviceName, branchName, getProjectVersion())    
                    buildUtilities.tagGitRepo(getProjectVersion())
    			}
    		}
    	}
	}
}

String getCodeVersion() {
    def versionProps = readProperties(text: readTrusted('application.properties'))
    return versionProps['app.version']
}

String getProjectVersion() {
    def projectVersion = getCodeVersion()
    if (branchName != 'master') {
        projectVersion += "-${buildUtilities.getGitCommit().take(12)}"
    }
    return projectVersion
}

def runAutomatedTests(String envName) {
    String nodePort = buildUtilities.getNodePort(envName, serviceName)
}