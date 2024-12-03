# Étape de construction  
FROM composer:2.3 AS builder  

# Définir le répertoire de travail  
WORKDIR /app  

# Copier les fichiers composer.json et composer.lock  
COPY composer.json composer.lock ./  

# Installer les dépendances  
RUN composer install  

# Copier le reste des fichiers du projet  
COPY . .  

# Étape de production  
FROM php:8.1-fpm-alpine  

# Définir le répertoire de travail  
WORKDIR /app  

# Installer les extensions nécessaires  
RUN apk add --no-cache \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    zlib-dev \
    curl \
 && docker-php-ext-configure gd --with-jpeg --with-webp \
 && docker-php-ext-install gd pdo pdo_mysql  

# Copier les fichiers nécessaires depuis l'étape de construction  
COPY --from=builder /app ./  

# Exposer le port 9000  
EXPOSE 9000  

# Commande de démarrage pour PHP  
CMD ["php-fpm"]