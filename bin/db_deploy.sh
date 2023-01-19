export DB_NAME='magento_db'
export DB_HOST='127.0.0.1 --port=3380'
export DB_USER='root'
export DB_USER_PASSWORD='root'

export BASE_URL='http://example.com'
# export BASE_URL_ALT='http://alternative.com' # Set store-specific url depending on needed scope_id

mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --execute="DROP DATABASE IF EXISTS $DB_NAME"
mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --execute="CREATE DATABASE IF NOT EXISTS $DB_NAME"
pv "./magento_db.sql.zip" | gunzip -cf | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | sed -e 's/TRIGGER[ ][`][A-Za-z0-9_]*[`][.]/TRIGGER /' | sed -e 's/AFTER[ ]\(INSERT\)\{0,1\}\(UPDATE\)\{0,1\}\(DELETE\)\{0,1\}[ ]ON[ ][`][A-Za-z0-9_]*[`][.]/AFTER \1\2\3 ON /' | grep -v 'mysqldump: Couldn.t find table' | grep -v 'Warning: Using a password' | mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --force $DB_NAME

mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --execute="UPDATE $DB_NAME.core_config_data AS e SET e.value = '0' WHERE e.path IN ('dev/js/minify_files','dev/css/minify_files', 'dev/js/merge_files','dev/css/merge_css_files')"
mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --execute="UPDATE $DB_NAME.core_config_data AS e SET e.value = '0' WHERE e.path IN ('web/secure/use_in_frontend', 'web/secure/use_in_adminhtml', 'admin/security/use_form_key')"
mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --execute="UPDATE $DB_NAME.core_config_data AS e SET e.value = 'localhost' WHERE e.path IN ('catalog/search/elasticsearch7_server_hostname','vsbridge_indexer_settings/es_client/host')"
mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --execute="UPDATE $DB_NAME.core_config_data AS e SET e.value = '9200' WHERE e.path IN ('vsbridge_indexer_settings/es_client/port', 'catalog/search/elasticsearch7_server_port')"
mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --execute="UPDATE $DB_NAME.core_config_data AS e SET e.value = '$BASE_URL/' WHERE e.path IN ('web/unsecure/base_url')"
mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --execute="UPDATE $DB_NAME.core_config_data AS e SET e.value = '$BASE_URL/' WHERE e.path IN ('web/secure/base_url')"
# mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --execute="UPDATE $DB_NAME.core_config_data AS e SET e.value = '$BASE_URL_ALT/' WHERE e.path IN ('web/unsecure/base_url') AND e.scope='websites' AND e.scope_id=1"
# mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --execute="UPDATE $DB_NAME.core_config_data AS e SET e.value = '$BASE_URL_ALT/' WHERE e.path IN ('web/secure/base_url') AND e.scope='websites' AND e.scope_id=1"
mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --execute="DELETE FROM $DB_NAME.core_config_data WHERE path IN ('web/unsecure/base_link_url', 'web/secure/base_link_url')"
mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --execute="DELETE FROM $DB_NAME.core_config_data WHERE path = 'web/cookie/cookie_domain'"
mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --execute="DELETE FROM $DB_NAME.core_config_data WHERE path = 'admin/url/custom'"
mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --execute="UPDATE $DB_NAME.core_config_data SET $DB_NAME.core_config_data.value = '0' WHERE path in ('admin/url/use_custom', 'admin/url/use_custom_path')"
mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --execute="DELETE FROM $DB_NAME.core_config_data WHERE path = 'admin/url/custom_path'"
mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --execute="UPDATE $DB_NAME.core_config_data AS e SET e.value = 1 WHERE e.path = 'system/full_page_cache/caching_application'"
mysql -h$DB_HOST -u$DB_USER -p$DB_USER_PASSWORD --execute="INSERT INTO $DB_NAME.core_config_data (scope, scope_id, path, value) VALUES ('default', 0, 'admin/security/session_lifetime', '31536000') ON DUPLICATE KEY UPDATE value='31536000';"