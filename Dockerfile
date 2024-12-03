# Étape de construction  
FROM php:8.2-fpm-alpine

WORKDIR /app  

# Copier les fichiers nécessaires  
COPY composer.json composer.lock ./  

# Mettre à jour les dépendances pour assurer la compatibilité  
RUN composer update --no-dev --ignore-platform-reqs  

# Copier le reste des fichiers du projet  
COPY . .  

# Étape de production  
FROM php:8.1-fpm-alpine  

WORKDIR /app  

RUN apk add --no-cache \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    zlib-dev \
    curl \
 && docker-php-ext-configure gd --with-jpeg --with-webp \
 && docker-php-ext-install gd pdo pdo_mysql  

COPY --from=builder /app ./  

EXPOSE 9000  

CMD ["php-fpm"]
