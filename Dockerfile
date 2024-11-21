# Utiliser l'image officielle de Jenkins LTS
FROM jenkins/jenkins:lts

# Passer à l’utilisateur root pour installer des dépendances
USER jenkins

# Installer Git, Docker, et nettoyer les fichiers inutiles après installation
RUN apt-get update && \
    apt-get install -y git docker.io && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Revenir à l’utilisateur Jenkins
USER jenkins
