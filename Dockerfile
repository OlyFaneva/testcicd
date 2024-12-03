# Étape de construction
FROM php:8.2-fpm-alpine AS builder

WORKDIR /app

# Installer les dépendances nécessaires pour composer
RUN apk add --no-cache git curl libpng-dev libjpeg-turbo-dev libwebp-dev zlib-dev \
    && docker-php-ext-configure gd --with-jpeg --with-webp \
    && docker-php-ext-install gd pdo pdo_mysql

# Copier les fichiers nécessaires pour Composer
COPY composer.json composer.lock ./

# Installer les dépendances PHP
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer install --no-dev --ignore-platform-reqs

# Copier les fichiers du projet
COPY . .

# Étape de production
FROM php:8.1-fpm-alpine

WORKDIR /app

# Copier les dépendances depuis le builder
COPY --from=builder /app /app

# Installer les dépendances système nécessaires
RUN apk add --no-cache \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    zlib-dev \
 && docker-php-ext-configure gd --with-jpeg --with-webp \
 && docker-php-ext-install gd pdo pdo_mysql

# Exposer le port utilisé par PHP-FPM
EXPOSE 9000

# Commande pour lancer le serveur
CMD ["php-fpm"]
