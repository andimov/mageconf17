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
			}
		}
		stage("Testing") {
			parallel {
				stage("ServerSide Tests") {
					steps {
                    sh '/var/lib/jenkins/apache-jmeter-3.1/bin/jmeter -n -t /var/lib/jenkins/apache-jmeter-3.1/bin/benchmark.jmx -j results/jmeter/benchmark.log -l results/jmeter/benchmark-results.jtl -e -o results/report/ -Jhost=<projectid>.dummycachetest.com -Jrequest_protocol=http -Jbase_path=/index.php -Jadmin_path=admin/admin -Jadmin_user=admin -Jadmin_password=123123q -JfrontendPoolUsers=1 -Jloops=5'
                    }
                }
				stage("ClientSide Tests") {
					steps {
                      sh 'docker run --shm-size=1g --rm --privileged -v "$(pwd)"/results:/sitespeed.io sitespeedio/sitespeed.io:7.6.3 -b chrome  --video --speedIndex http://<projectid>.dummycachetest.com/ -n1 '
                      }
				}
			}
		}
		stage("Pubblish") {
			steps {
				archiveArtifacts allowEmptyArchive: true, artifacts: 'results/**'
			}
		}
	}
}```

Click **Save** and **Build now**


## Step #3: create basic performance test

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
			}
		}
		stage("Performance Measurements") {
			parallel {
				stage("ServerSide Tests") {
					steps {
                    sh '/var/lib/jenkins/apache-jmeter-3.1/bin/jmeter -n -t /var/lib/jenkins/apache-jmeter-3.1/bin/benchmark.jmx -j results/benchmark.log -l results/benchmark-results.jtl -e -o results/report/ \
                    -Jhost=${MagentoHost} \
                    -Jrequest_protocol=https \
                    -Jbase_path=/ \
                    -Jadmin_path=admin \
                    -Jadmin_user=admin \
                    -Jadmin_password=123123q \
                    -JfrontendPoolUsers=${FrontendPullUsers} \
                    -Jloops=${Loops}\
                    -Jjmeter.save.saveservice.url=true'
                    }
                }
				stage("ClientSide Tests") {
					steps {
                      sh 'docker run --shm-size=1g --rm --privileged -v "$(pwd)"/results:/sitespeed.io  sitespeedio/sitespeed.io:7.6.3 --outputFolder=results -b chrome  --video --speedIndex https://${MagentoHost} -n${Loops} '
                      }
				}
			}
		}
		stage("Pubblish") {
			steps {
				archiveArtifacts allowEmptyArchive: true, artifacts: 'results/**'
			}
		}
	}
}```


Click **Save** and **Build now**.
Click **Build with parameters**.
Specify parameters and click **Build**.



## Step #4: Analize results
