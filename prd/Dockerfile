# Utiliser une image Python comme base
FROM python:3.9-slim

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Copier les fichiers nécessaires dans le conteneur
COPY . /app

# Update pip
# RUN pip install --upgrade pip

# Installer les dépendances
# RUN pip install --no-cache-dir -r requirements.txt
RUN pip install -r requirements.txt

# Exposer le port utilisé par Flask
EXPOSE 5001

# Commande pour exécuter l'application Flask
CMD ["python", "app.py"]
