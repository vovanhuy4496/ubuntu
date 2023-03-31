FROM php:8.1.2-fpm
    #Copy composer.lock, composer.json and /var/www/test
    COPY composer.lock composer.json /var/www/test
    #Set working directory
    WORKDIR /var/www/test
    #Install dependencies
    RUN apt-get update && apt-get install -y \
        build-essential \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        locales \
        zip \
        jpegoptim optipng pngquant gifsicle \
        vim \
        unzip \
        git \
        curl

    #Clear cache

    RUN apt-get clean && rm -rf /var/lib/apt/lists/*
    #Install extensions
    RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
    RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ 
    RUN docker-php-ext-install gd
    #Install composer
    RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    #Add user for laravel application
    RUN groupadd -g 1000 root
    RUN useradd -u 1000 -ms /bin/bash -g root root
    #Copy existing application directory contents
    COPY . /var/www/test
    #Copy existing application directory permissions
    COPY --chown=root:root . /var/www/test
    #Change current user to root
    USER root
    EXPOSE 9000
    CMD ["php-fpm"]
