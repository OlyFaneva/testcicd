# Utilisation de l'image de base Jenkins
FROM jenkins/jenkins:lts

# Devenir root pour installer des dépendances
USER root

# Mise à jour et installation de Git et Docker
RUN apt-get update && \
    apt-get install -y git docker.io && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Revenir à l'utilisateur Jenkins après installation
USER jenkins
