#!/bin/bash

# Requirements: 
#       ROOT access to the server.
#
# How to use the script:
#       Download the script as ROOT user, chmod it to 755 and then execute it. Wait for magic to happen :)
#
#       The 'wget' way to do this is:
#       wget https://www.zhaklilo.info/scripts/apc.sh && chmod 755 apc.sh && ./apc.sh
#       And again wait for magic to happen :)
#
##############################
# * Created by ZhL - Zhak Lilo
# * Date: 16/03/2019
# * Last update: 27/10/2019
# * Version: 1.0 - Initial release
# * Version: 1.3 - Added CentOS 7.x support
# * Purpose: This script is created to ease and automate the installation of APCu on CentOS 6.x and CentOS 7.x
##############################
#
#We will perform YUM install now as it is required in both CentOS 6.x and CentOS 7.x
#Installing the development tools (Headers, libraries for dynamic linking, etc) for Perl Compatible Regular Expressions (PCRE)
yum -y install pcre-devel

echo 'Checking your OS version ...';

version=$(rpm -E %{rhel})

case $version in

    '6')
        echo 'Your CentOS version is 6.x';
        echo 'Starting the installation of APCu PHP extension:';

        #We will install the APCu PHP extensions separately for for PHP 5.x and 7.x

		#We will start with APCu for PHP 5.x
		for apcphp in 54 55 56; do
		printf "no" | /opt/cpanel/ea-php$apcphp/root/usr/bin/pecl install channel://pecl.php.net/APCu-4.0.10
		done;

		#Proceeding with the APCu installation for PHP 7.x
		for apcuphp in 70 71 72 73; do
		printf "no" | /opt/cpanel/ea-php$apcuphp/root/usr/bin/pecl install apcu
		done;

		#Once all of the installations are done we will restart the Apache and PHP-FPM services
		/scripts/restartsrv_httpd
		/scripts/restartsrv_apache_php_fpm

		#Lastly we will print the APC and APCu PHP extension in order to verify them
		echo -e 'Verifying the APCu PHP extension installation:\n';
		for phpcheck in 54 55 56 70 71 72 73; do
		echo -n "PHP $phpcheck: " ; /opt/cpanel/ea-php$phpcheck/root/usr/bin/php -m | grep apcu
		done;
    ;;
   '7')
        echo 'Your CentOS version is 7.x';
        echo 'Starting the installation of APCu PHP extension:';

        #We will install the APC PHP extensions separately for for PHP 5.x and 7.x

		#We will start with APCu for PHP 5.x
		for apcphp in 54 55 56; do
		printf "no" | /opt/cpanel/ea-php$apcphp/root/usr/bin/pecl install channel://pecl.php.net/APCu-4.0.10
		done;

		#Let's add the apcu.so extension manually for PHP 5.6 as it is not added by default
		echo 'extension=apcu.so' >> /opt/cpanel/ea-php56/root/etc/php.d/zzzzzzz-pecl.ini

		#Proceeding with the APCu installation for PHP 7.x
		for apcuphp in 70 71 72 73; do
		printf "no" | /opt/cpanel/ea-php$apcuphp/root/usr/bin/pecl install apcu
		done;

		#Once all of the installations are done we will restart the Apache and PHP-FPM services
		/scripts/restartsrv_httpd
		/scripts/restartsrv_apache_php_fpm

		#Lastly we will print the APC and APCu PHP extension in order to verify them
		echo -e 'Verifying the APCu PHP extension installation:\n';
		for phpcheck in 54 55 56 70 71 72 73; do
		echo -n "PHP $phpcheck: " ; /opt/cpanel/ea-php$phpcheck/root/usr/bin/php -m | grep apcu
		done;
    ;;
    *)
        echo 'This is not CentOS and I am created only for CentOS 6.x and 7.x. Please execute me on server with such OS.';
    ;;
esac
