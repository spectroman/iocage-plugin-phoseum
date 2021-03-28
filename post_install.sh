#!/bin/sh

PHOSEUM_DATA="/usr/local/www/phoseum/"
PHOSEUM_HOSTNAME=`hostname`
PHOSEUM_IP=`ifconfig | grep broad | awk '{print $2}'`

# Make the default DATA  dir
mkdir -p $PHOSEUM_DATA

# Create user
pw user add phoseum -c "Phoseum" -d /nonexistent -s /usr/bin/nologin -w no

# Download and install Phoseum
curl --output /tmp/phoseum-truenas-artifacts.tgz http://download.phoseum.org/phoseum-truenas-artifacts.tgz
cd /tmp && tar -zxvf phoseum-truenas-artifacts.tgz
mv phoseum-truenas-artifacts/* $PHOSEUM_DATA
rm -rf /tmp/phoseum-truenas-artifacts
chown -R phoseum $PHOSEUM_DATA

# Enable the services
sysrc -f /etc/rc.conf apache24_enable="YES"
sysrc -f /etc/rc.conf phoseum_enable="YES"

# Install RUBYGEM Dependencies
gem install yaml
gem install jwt
gem install webrick
gem install json
gem install cgi
gem install mini_magick
gem install fileutils
gem install bcrypt
gem install sqlite3

# Generate ServerSide Secret
cd $PHOSEUM_DATA && ./phoseum-api.rb -n
/usr/local/bin/phoseumset adduser admin true mustchange

# Config OS, Apache and VHOST for Phoseum
echo -e "\n$PHOSEUM_IP  self.phoseum.org" >> /etc/hosts
echo -e "\nServerName \"$PHOSEUM_HOSTNAME\"" >> /usr/local/etc/apache24/httpd.conf

sed -i "" "s,DocumentRoot ###DATA###,DocumentRoot $PHOSEUM_DATA," /usr/local/etc/apache24/Includes/phoseum.conf
sed -i "" "s,Directory ###DATA###,Directory $PHOSEUM_DATA," /usr/local/etc/apache24/Includes/phoseum.conf
sed -i "" "s,ServerName ###IP###,ServerName $PHOSEUM_IP," /usr/local/etc/apache24/Includes/phoseum.conf
sed -i "" "s/ServerAlias ###HOSTNAME###/ServerAlias $PHOSEUM_HOSTNAME/" /usr/local/etc/apache24/Includes/phoseum.conf

sed -Ei "" "s/^Listen [[:digit:]]{1,5}(.*)/Listen 2708/" /usr/local/etc/apache24/httpd.conf
sed -i "" "s/^#LoadModule proxy_module/LoadModule proxy_module/" /usr/local/etc/apache24/httpd.conf
sed -i "" "s/^#LoadModule proxy_http_module/LoadModule proxy_http_module/" /usr/local/etc/apache24/httpd.conf
sed -i "" "s/^#LoadModule ssl_module/LoadModule ssl_module/" /usr/local/etc/apache24/httpd.conf
sed -i "" "s/^#LoadModule vhost_alias_module/LoadModule vhost_alias_module/" /usr/local/etc/apache24/httpd.conf
sed -i "" "s/^#LoadModule rewrite_module/LoadModule rewrite_module/" /usr/local/etc/apache24/httpd.conf

# Start the services
if $(service phoseum start 2>/dev/null >/dev/null) ; then
    echo "Starting phoseum."
fi
if $(service apache24 start 2>/dev/null >/dev/null) ; then
    echo "Starting Apache24."
fi
