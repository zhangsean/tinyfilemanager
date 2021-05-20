FROM php:7.4-alpine

RUN	echo "upload_max_filesize = 512M" >> /usr/local/etc/php/conf.d/0-upload_large_dumps.ini \
&&	echo "post_max_size = 512M" >> /usr/local/etc/php/conf.d/0-upload_large_dumps.ini \
&&	echo "memory_limit = 1G" >> /usr/local/etc/php/conf.d/0-upload_large_dumps.ini \
&&	echo "max_execution_time = 600" >> /usr/local/etc/php/conf.d/0-upload_large_dumps.ini \
&&	echo "max_input_vars = 5000" >> /usr/local/etc/php/conf.d/0-upload_large_dumps.ini

STOPSIGNAL SIGINT

WORKDIR /var/www/html

RUN	apk add --no-cache zip libzip openssl bzip2 \
&&	apk add --no-cache --virtual .build-deps libzip-dev openssl-dev bzip2-dev oniguruma-dev openldap-dev build-base autoconf \
&&	pecl install xattr-1.4.0 \
&&	rm -rf /tmp/pear \
&&	docker-php-ext-install zip fileinfo phar bz2 iconv mbstring ldap sockets \
&&	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
&&	apk add --virtual .phpexts-rundeps $runDeps \
&&	apk del .build-deps \
&&	rm -rf /var/cache/apk/*

COPY *.php /var/www/html/
COPY *.json /var/www/html/

RUN ln -sf tinyfilemanager.php index.php

CMD	[ "php", "-S", "[::]:8080", "-t", "/var/www/html" ]

EXPOSE 8080

USER root

