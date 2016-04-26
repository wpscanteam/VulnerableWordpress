FROM ubuntu:trusty
MAINTAINER WPScan Team <team@wpscan.org>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -qy dist-upgrade

RUN { \
		echo mysql-community-server mysql-community-server/data-dir select ''; \
		echo mysql-community-server mysql-community-server/root-pass password ''; \
		echo mysql-community-server mysql-community-server/re-root-pass password ''; \
		echo mysql-community-server mysql-community-server/remove-test-db select false; \
	} | debconf-set-selections
RUN apt-get -qy install wget ed sed curl apache2 mysql-server php5-mysql php5 libapache2-mod-php5 php5-mcrypt php5-gd unzip

# setup mysql
RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf

# extract wordpress
#ADD https://wordpress.org/latest.tar.gz /wordpress.tar.gz
COPY latest.tar.gz /wordpress.tar.gz
RUN rm -rf /var/www/
RUN tar xvzf /wordpress.tar.gz
RUN mv /wordpress /var/www/

# configure wordpress
RUN mv /var/www/wp-config-sample.php /var/www/wp-config.php
RUN sed -i -r "s/define\('DB_NAME', '[^']+'\);/define\('DB_NAME', 'wordpress'\);/g" /var/www/wp-config.php
RUN sed -i -r "s/define\('DB_USER', '[^']+'\);/define\('DB_USER', 'wordpress'\);/g" /var/www/wp-config.php
RUN sed -i -r "s/define\('DB_PASSWORD', '[^']+'\);/define\('DB_PASSWORD', 'wordpress'\);/g" /var/www/wp-config.php
RUN printf '%s\n' "g/put your unique phrase here/d" a "$(curl -sL https://api.wordpress.org/secret-key/1.1/salt/)" . w | ed -s /var/www/wp-config.php
ADD files/vhost.conf /etc/apache2/sites-available/000-default.conf
RUN chown -R www-data:www-data /var/www
RUN sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 20M/" /etc/php5/apache2/php.ini

# make it vulnerable
## TODO
# wp-config backup
RUN ["/bin/bash", "-c", "for f in wp-config.{php~,php.save,old,txt} ; do cp /var/www/wp-config.php /var/www/$f ; done"]
# robots.txt
ADD files/robots.txt /var/www/robots.txt
ADD files/debug.log /var/www/wp-content/debug.log
ADD files/searchreplacedb2.php /var/www/searchreplacedb2.php
RUN a2enmod headers
ADD files/header.conf /etc/apache2/conf-enabled/header.conf

# run
EXPOSE 80
EXPOSE 3306
VOLUME ["/var/lib/mysql", "/var/www"]

ADD start.sh /start.sh
RUN chmod 755 /start.sh
CMD ["/bin/bash", "/start.sh"]
