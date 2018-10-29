# MageConf’18  workshop

## Preparation
### Add your SSH key
Sign in into [https://magento.cloud](https://magento.cloud), go to **Account settings** tab and add your public SSH key.

![Add SSH key](/images/account_settings.png?raw=true)

If you do not have SSH keys, you can generate a new key pair using the following command:
```
ssh-keygen
```
The new public key will be saved in the ~/.ssh/id_rsa/pub file.


### Clone the project
Go to the **Projects** tab and select a project. Clone the project using a git link in a web UI:

![Clone the project](/images/clone_project.png?raw=true)

```
git clone <projectid>@git.eu-3.magento.cloud:<projectid>.git mageconf2018
cd mageconf2018
```

Rest of commands will be performed from the project directory.


## Step #1: change admin password
A Magento Cloud instance as well as a deployment process can easily be customized through configuration files and environment variables.
The environment variables can be added through web UI or cli utility.

The **ADMIN_PASSWORD** variable controls a password of the admin user. To change the admin's password,
go to the **Configure environment** > **Variables** and add the following environment variable:
```
ADMIN_PASSWORD = mageconf2018
```
![Set admin password](/images/admin_password.png?raw=true)

When you save changes, a deployment process will be started in order to apply the changes.
When it is done, you can sign in to admin backend using password you have set.
You can access the admin backend using a link from web UI + **/admin**

![Access site](/images/access_site.png?raw=true)


## Step #2: create basic performance test

Sign in into Jenkins provided in, click **Add New Item**, specify name for build and select **Pipeline**. Click **Create**

Specify:
```pipeline {
	agent any
	stages {
		stage("Docker Test") {
			steps {
			    sh 'docker -v'
			    cleanWs()
			}
		}
		stage("Testing") {
			parallel {
				stage("ServerSide Tests") {
					steps {
						sh '/var/lib/jenkins/apache-jmeter-3.1/bin/jmeter -n -t /var/lib/jenkins/apache-jmeter-3.1/bin/benchmark.jmx -l ${WORKSPACE}/jmeter-results.jtl \
						-Jhost=<projectid>.dummycachetest.com \
						-Jrequest_protocol=https \
						-Jloops=10 \
						-Jbase_path=/ \
						-Jadmin_path=admin \
						-Jadmin_user=admin \
						-Jadmin_password=123123q \
						-JfrontendPoolUsers=1 \
						-JdeadLocksPoolUsers=0 \
						-JadminPoolUsers=0'
				    }
				}
				stage("ClientSide Tests") {
					steps {
					  sh 'docker run --shm-size=1g --rm --privileged -v "${WORKSPACE}"/results:/sitespeed.io sitespeedio/sitespeed.io:7.6.3 -b chrome  --video false --speedIndex https://<projectid>.dummycachetest.com/ -n1 '
				      }
				}
			}
		}
	}
	post {
		always {
		    archiveArtifacts allowEmptyArchive: true, artifacts: '**'
		}
	}
}
```

Click **Save** and **Build now**


## Step #3: create advanced performance test

Sign in into Jenkins provided in, click **Add New Item**, specify name for build and select **Pipeline**. Click **Create**

Specify:
```pipeline {
    parameters {
        string(
            name: 'MagentoHost',
            description: 'Specify only HOST name where Magento located. Without protocol.'
        )
        string(
            name: 'Loops',
            defaultValue: '20',
            description: 'Loops count for CS and SS testing'
        )
        string(
            name: 'FrontendPullUsers',
            defaultValue: '4',
            description: 'Threads count for ServerSide testing'
        )
    }
	agent any
	stages {
		stage("Docker Test") {
			steps {
				sh 'docker -v'
			    cleanWs()
			}
		}
		stage("Testing") {
			parallel {
				stage("ServerSide Tests") {
					steps {
                    sh '/var/lib/jenkins/apache-jmeter-3.1/bin/jmeter -n -t /var/lib/jenkins/apache-jmeter-3.1/bin/benchmark.jmx -l ${WORKSPACE}/jmeter-results.jtl -e -o ${WORKSPACE}/jmeter-dashboard \
                    -Jhost=${MagentoHost} \
                    -Jrequest_protocol=https \
                    -JfrontendPoolUsers=${FrontendPullUsers} \
                    -Jloops=${Loops} \
                    -Jbase_path=/ \
                    -Jadmin_path=admin \
                    -Jadmin_user=admin \
                    -Jadmin_password=123123q \
                    -JdeadLocksPoolUsers=0 \
                    -JadminPoolUsers=0 \
                    -Jjmeter.save.saveservice.url=true\
                    -Jjmeter.save.saveservice.response_data=true\
                    -Jjmeter.save.saveservice.samplerData=true\
                    -Jjmeter.save.saveservice.requestHeaders=true\
                    -Jjmeter.save.saveservice.url=true\
                    -Jjmeter.save.saveservice.responseHeaders=true'
                    }
                }
				stage("ClientSide Tests") {
					steps {
                      sh 'curl -O https://raw.githubusercontent.com/andimov/mageconf18/master/docker-compose.yml'
					  sh 'docker-compose up -d'
					  sh 'docker-compose run -v "${WORKSPACE}"/results:/sitespeed.io sitespeed.io --video false --speedIndex https://${MagentoHost} https://${MagentoHost}/category-1.html https://${MagentoHost}/simple-product-10.html https://${MagentoHost}/configurable-product-1.html https://${MagentoHost}/catalogsearch/result/?q=simple -n${Loops} --graphite.host=graphite'
                      }
				}
			}
		}
	}
	post {
        always {
            archiveArtifacts allowEmptyArchive: true, artifacts: '**'
        }
	}
}
```
Click **Save** and **Build now**.
Click **Build with parameters**.
Specify parameters and click **Build**.



## Step #4: Analize results
