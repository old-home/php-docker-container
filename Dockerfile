FROM php:8.4-cli

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Install apt packages
RUN set -x \
  && apt-get update \
  && apt-get install --no-install-recommends -y \
    wget \
    gnupg \
    gosu \
    git \
    unzip \
    libssl-dev \
    libpq-dev \
    libicu-dev \
    libxml2-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    zlib1g-dev \
    libevent-dev \
    libicu-dev \
    libidn11-dev \
    libidn2-0-dev \
    libgmp-dev \
    ca-certificates \
    curl \
  && install -m 0755 -d /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
  && chmod a+r /etc/apt/keyrings/docker.asc \
  && echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && apt-get update \
  && apt-get install --no-install-recommends -y docker-ce-cli docker-buildx-plugin docker-compose-plugin \
  ;

# Install PHP extensions
RUN docker-php-ext-install \
    bcmath \
    intl \
    pdo_pgsql \
    opcache \
    simplexml \
    xml \
    mbstring \
    sockets \
    gmp \
    pcntl \
  ;
RUN pecl install xdebug event \
    && pecl install ast && docker-php-ext-enable ast \
    && pecl install raphf && docker-php-ext-enable raphf \
    && docker-php-ext-enable xdebug \
    && docker-php-ext-enable event --ini-name zz-event.ini \
    ;

# Remove unrequired packages
RUN apt-get remove -y wget \
    && apt-get autoremove -y \
    && rm -rf /root/.gnupg \
    && apt-get upgrade -y \
  ;

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && echo "xdebug.mode=coverage" >> /usr/local/etc/php/php.ini \
  ;

WORKDIR /app
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
