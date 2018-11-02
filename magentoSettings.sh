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
php bin/magento cache:flush
