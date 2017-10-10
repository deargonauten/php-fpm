FROM php:7.1-fpm

MAINTAINER Jason de Ridder <jason@inktweb.nl>

# Install "software-properties-common" (for the "add-apt-repository")
RUN apt-get update && apt-get install -y \
    software-properties-common locales

RUN locale-gen en_US.UTF-8
RUN locale-gen nl_NL.UTF-8

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=UTF-8
ENV LANG=en_US.UTF-8
ENV TERM xterm

RUN unlink /etc/localtime && ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime

# Install PHP-CLI 7, some PHP extentions and some useful Tools with APT
RUN apt-get update && apt-get install -y --force-yes --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        zlib1g-dev \
        libicu-dev \
        g++ \
        unixodbc-dev \
        libxml2-dev \
        libaio-dev \
        libmemcached-dev \
        freetds-dev \
        libssl-dev \
        openssl \
        git \
        curl \
        vim \
        nano \
        net-tools \
        pkg-config \
        iputils-ping \
        wget

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && pecl install redis \
    && pecl install memcached \
    && pecl install xdebug \
    && docker-php-ext-install \
            iconv \
            mbstring \
            intl \
            mcrypt \
            gd \
            mysqli \
            pdo_mysql \
            soap \
            sockets \
            zip \
            pcntl \
            ftp \
            bcmath \
    && docker-php-ext-enable \
            redis \
            memcached \
            opcache \
            xdebug

# Install APCu and APC backward compatibility
RUN pecl install apcu \
    && pecl install apcu_bc-1.0.3 \
    && docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini \
    && docker-php-ext-enable apc --ini-name 20-docker-php-ext-apc.ini

# Install PHPUnit
RUN wget https://phar.phpunit.de/phpunit.phar -O /usr/local/bin/phpunit \
    && chmod +x /usr/local/bin/phpunit

# Add bin folder of composer to PATH.
RUN echo "export PATH=${PATH}:/srv/vendor/bin:/root/.composer/vendor/bin" >> ~/.bashrc

# Load xdebug Zend extension with phpunit command
RUN echo "alias phpunit='php -dzend_extension=xdebug.so /srv/vendor/bin/phpunit'" >> ~/.bashrc

# Install Composer
RUN curl -s http://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /srv
CMD ["php-fpm"]