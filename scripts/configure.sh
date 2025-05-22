#!/bin/bash

# Credenciais fixas definidas no docker-compose.yml
DB_HOST="mysql"
DB_NAME="drupal"
DB_USER="drupaluser"
DB_PASS="drupalpass"

SITE_NAME="Cloud Computing"
ADMIN_USER="admin"
ADMIN_PASS="admin"
MYSQL_ROOT_PASSWORD="drupal"
MYSQL_ROOT_USER="root"
      

PROJECT_DIR="/opt/drupal"

cd $PROJECT_DIR


until mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" -e "SELECT 1;" &> /dev/null; do
  echo "Aguardando MySQL responder consultas..."
  sleep 5
done

echo "MySQL está pronto. Continuando com a instalação do Drupal..."

# Verificar se o Composer está instalado, caso não, instalar
if ! command -v composer &> /dev/null
then
    echo "Composer não encontrado, instalando..."
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
fi

# Instalar dependências do Composer (caso ainda não tenha sido feito)
echo "Instalando dependências do Composer..."
composer install

# Verificar se Drush está instalado, caso contrário, instalar
if ! command -v drush &> /dev/null
then
    echo "Drush não encontrado, instalando..."
    composer require drush/drush
fi

echo "Instalando Drupal com Drush..."
drush site:install standard --db-url=mysql://${DB_USER}:${DB_PASS}@${DB_HOST}/${DB_NAME} --site-name="${SITE_NAME}" --account-name="${ADMIN_USER}" --account-pass="${ADMIN_PASS}" --yes

echo "Limpando cache do Drupal..."
drush cr

echo "Instalação do Drupal concluída!"
