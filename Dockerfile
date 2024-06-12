# 使用官方PHP 8.1.28-fpm镜像作为基础镜像
FROM php:8.1.28-fpm

LABEL Maintainer="Henry.zhang <767684610@qq.com>"

# 定义环境变量，设置时区时使用
ENV TIME_ZONE Asia/Shanghai

# 安装必要的依赖
RUN apt-get update && apt-get install -y \
    git vim openssl \
    unzip \
    libevent-dev \
    pkg-config \
    libssl-dev \
	libz-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libwebp-dev \
    libxpm-dev \
    libmagickwand-dev \
	supervisor \
	&& echo "${TIME_ZONE}" > /etc/timezone \
	&& ln -sf /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime

# 安装 sockets 扩展
RUN docker-php-ext-install pcntl sockets mysqli opcache \
    && docker-php-ext-enable opcache

# 安装 GD 扩展
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm \
    && docker-php-ext-install gd

# 安装 Imagick 扩展
RUN pecl install imagick && docker-php-ext-enable imagick

# 安装 Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 安装PHP扩展，event扩展需优先加载sockets，否则报错
RUN pecl install redis && docker-php-ext-enable redis \
    && pecl install mongodb && docker-php-ext-enable mongodb \
    && pecl install event-3.1.3 && docker-php-ext-enable event \
    && pecl install swoole && docker-php-ext-enable swoole \
	&& echo "extension=event.so" >> /usr/local/etc/php/conf.d/docker-php-ext-sockets.ini \
	&& echo ";extension=event.so" > /usr/local/etc/php/conf.d/docker-php-ext-event.ini

# 清理
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /var/www/html

# 将当前目录内容复制到容器中
# COPY . /var/www/html

# 暴露端口（如需要）
EXPOSE 9000

# 启动PHP-FPM
CMD ["php-fpm"]

# 构建镜像命令
# docker build -t xiaoyuan136/php:8.1-fpm .
# 运行容器
# docker run --name php -d xiaoyuan136/php:8.1-fpm