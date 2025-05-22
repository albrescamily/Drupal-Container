#!/bin/bash

# Carrega variáveis de ambiente do arquivo .env
export $(cat /var/www/html/.env | grep -v '^#' | xargs)

# Variáveis padrão
DB_HOST=${DRUPAL_DB_HOST:-$MYSQL_HOST}
DB_NAME=${DRUPAL_DB_NAME:-$MYSQL_DATABASE}
DB_USER=${DRUPAL_DB_USER:-$MYSQL_USER}
DB_PASS=${DRUPAL_DB_PASSWORD:-$MYSQL_PASSWORD}
ADMIN_USER=${DRUPAL_ADMIN_USER}
ADMIN_PASS=${DRUPAL_ADMIN_PASSWORD}
SITE_NAME=${DRUPAL_SITE_NAME:-"Drupal Site"}

# Verifica se o Drupal já está instalado
if [ -f sites/default/settings.php ] || drush status | grep -q "Drupal bootstrap: Successful"; then
  echo "Drupal já instalado. Pulando instalação."
  exec apache2-foreground
  exit 0
fi

cd /var/www/html

if [ ! -f web/sites/default/settings.php ]; then
  cp web/sites/default/default.settings.php web/sites/default/settings.php
  chmod 664 web/sites/default/settings.php
fi

mkdir -p web/sites/default/files
chmod 775 web/sites/default/files

# Instalação do Drupal
echo "Instalando Drupal..."
drush site:install standard -y \
  --account-name="$ADMIN_USER" \
  --account-pass="$ADMIN_PASS" \
  --site-name="$SITE_NAME" \
  --db-url="mysql://$DB_USER:$DB_PASS@$DB_HOST/$DB_NAME"

echo "Configurando idioma pt-br..."
drush language:add pt-br -y
drush config:set system.site default_langcode pt-br -y
drush config:set system.site langcode pt-br -y

echo "Configurando o site..."
drush config:set system.site name "$SITE_NAME" -y
drush config:set system.date country.default BR -y
drush config:set system.date timezone.default 'America/Sao_Paulo' -y


# Ativando módulos
echo "Ativando módulos..."
drush en pathauto redirect token -y

# Baixando e ativando temas
echo "Baixando e configurando temas..."
drush pm-enable olivero -y

# Criando conteúdo inicial
echo "Criando páginas iniciais..."
drush -y entity:create node --bundle=page --values='{
  "title": "Página 1", 
  "body": {
    "value": "<p>Bem-vindo ao nosso site. Esta é uma página inicial de exemplo.</p>",
    "format": "full_html"
  },
  "path": {"alias": "/pagina-1"}
}'

drush -y entity:create node --bundle=page --values='{
  "title": "Página 2", 
  "body": {
    "value": "<p>Esta é uma segunda página de exemplo com conteúdo.</p>",
    "format": "full_html"
  },
  "path": {"alias": "/pagina-2"}
}'

# Limpeza de cache
echo "Limpeza de cache..."
drush cr

echo "Instalação do Drupal concluída com sucesso!"

# Inicia o Apache
exec apache2-foreground
