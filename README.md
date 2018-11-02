# MageConf’18  workshop

## Step #1: Connect to instance by ssh
Go to the **Projects** tab and select a project. Connect the instance using ssh link in a web UI:

![Connect to the project](/images/clone_project.png?raw=true)

```
ssh <projectid>-master-7rqtwti--mymagento@ssh.eu-4.magento.cloud
```

## Step #2: Generate performance profile
```
php bin/magento setup:perf:generate-fixtures setup/performance-toolkit/profiles/ee/small.xml
```
## Step #3: Generate performance profile
``` 
php bin/magento indexer:set-mode schedule 
rm -rf pub/static/* var/view_preprocessed/pub
php -f bin/magento setup:store-config:set --admin-use-security-key=0 --use-rewrites=1
php bin/magento config:set --scope default -- admin/security/session_lifetime 7200
php bin/magento config:set --scope default -- admin/security/admin_account_sharing 1
php bin/magento config:set --scope default -- web/seo/use_rewrites 1
php bin/magento config:set --scope default -- admin/security/use_form_key 0
php bin/magento config:set --scope default -- dev/js/merge_files 1
php bin/magento config:set --scope default -- dev/js/enable_js_bundling 1
php bin/magento config:set --scope default -- dev/js/minify_files 1
php bin/magento config:set --scope default -- dev/css/merge_css_files 1
php bin/magento config:set --scope default -- dev/css/minify_files 1
php bin/magento setup:static-content:deploy
php bin/magento cache:flush"
```

## Step #4: Create basic performance test

Sign in into Jenkins provided in access paper, click **Add New Item**, specify name for build and select **Pipeline**. Click **Create**

Specify content from [BasicJenkinsfile](BasicJenkinsfile)

Click **Save** and **Build now**

## Step #5: Create extended performance test

Sign in into Jenkins provided in, click **Add New Item**, specify name for build and select **Pipeline**. Click **Create**

Specify content from [ExtendedJenkinsfile](ExtendedJenkinsfile)

Click **Save** and **Build now**.
Click **Build with parameters**.
Specify parameters and click **Build**.



## Step #6: Analize results
```
http://<JenkinsHost>:3000
http://<JenkinsHost>:8080/job/<BuildName>/<BuildId>/artifact/jmeter-dashboard/
http://<JenkinsHost>:8080/job/<BuildName>/<BuildId>/artifact/sitespeed-result/
```
