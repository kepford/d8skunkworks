#!/bin/sh

ls web &>/dev/null
if [[ $? -ne 0 ]]; then
  echo "Run this script from the project root: ./scripts/install.sh"
  exit 1
fi

echo "Installing composer dependencies..."
composer install

# Check for existing ddev config and put in place if not found.
if [[ ! -f docroot/sites/default/settings.ddev.php ]]; then
  ddev config --project-type drupal8 --php-version 7.3
fi

# Check for local settings and copy if not found.
if [[ ! -f docroot/sites/default/settings.local.php ]]; then
  cp docroot/sites/example.settings.local.php docroot/sites/default/settings.local.php
fi

# Remember if the user had an existing install with xdebug enabled so it can be
# re-enabled after the new install.
ddev . php --info | grep "xdebug support => enabled"
XDEBUG_ENABLED=$?
if [[ "XDEBUG_ENABLED" -eq 0 ]]; then
  echo "Xdebug is enabled in your current installation and will be re-enabled after this script completes."
fi

echo "Starting ddev..."
ddev start

echo "Installing site with: ddev . drush site-install [options]..."
ddev . drush -y site-install standard\
  --site-mail=admin@example.com \
  --account-mail=admin@example.com \
  --account-name=admin \
  --account-pass=admin
ddev . drush cr

# echo "Importing YAML Content..."
# ddev . drush ycip mag_profile

if [[ "$XDEBUG_ENABLED" -eq 0 ]]; then
  echo "Re-enabling Xdebug because it was enabled when you ran the install."
  ddev . enable_xdebug
fi
