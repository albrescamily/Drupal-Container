# Criar página de documentação com conteúdo completo em HTML
DOC_NODE_ID=$(drush eval "
use Drupal\node\Entity\Node;

\$html = '
<h1>📄 Documentação Rápida do Projeto Drupal com Docker</h1>

<h2>1. Criação do Dockerfile</h2>
<p>Usamos a imagem oficial do Drupal como base e adicionamos:</p>
<ul>
  <li>Instalação do cliente MySQL.</li>
  <li>Instalação do Composer e do Drush.</li>
  <li>Cópia dos scripts <code>configure.sh</code> e <code>create-node.sh</code>.</li>
  <li>Permissões de execução para os scripts.</li>
</ul>
<pre><code>FROM drupal:latest

RUN apt-get update && apt-get install -y default-mysql-client

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer require drush/drush
RUN drush --version

COPY ./scripts/configure.sh /opt/drupal/
COPY ./scripts/create-node.sh /opt/drupal/

RUN chmod +x /opt/drupal/configure.sh
RUN chmod +x /opt/drupal/create-node.sh

CMD [\"apache2-foreground\"]</code></pre>

<h2>2. Criação dos Scripts</h2>
<h3>configure.sh</h3>
<p>Este script configura a base de dados e instala o Drupal via Drush.</p>
<ul>
  <li>Aguarda o MySQL estar pronto.</li>
  <li>Garante que Composer e Drush estejam instalados.</li>
  <li>Instala o Drupal e limpa o cache.</li>
</ul>

<h3>create-node.sh</h3>
<p>Cria automaticamente duas páginas no Drupal:</p>
<ul>
  <li>Uma página de apresentação.</li>
  <li>Uma página com a documentação do projeto.</li>
</ul>

<h2>3. docker-compose.yml</h2>
<p>Define dois containers e uma rede compartilhada.</p>

<h3>Serviço Drupal</h3>
<ul>
  <li>Construído com o Dockerfile personalizado.</li>
  <li>Exposto na porta <code>8080</code>.</li>
  <li>Utiliza volumes e variáveis de ambiente.</li>
</ul>

<h3>Serviço MySQL</h3>
<ul>
  <li>Imagem oficial <code>mysql:latest</code>.</li>
  <li>Banco de dados e usuário com senha configurados.</li>
</ul>

<pre><code>services:
  drupal:
    build:
      context: .
      dockerfile: Dockerfile.drupal
    container_name: drupal-t1
    ports:
      - \"8080:80\"
    depends_on:
      - mysql
    environment:
      DB_HOST: db
      DB_NAME: drupal
      DB_USER: drupaluser
      DB_PASS: drupalpass
      ADMIN_USER: admin
      ADMIN_PASS: admin
      SITE_NAME: \"Cloud Computing\"
    volumes:
      - drupal-volume:/opt/drupal/
    networks:
      - drupal-network

  mysql:
    image: mysql:latest
    container_name: mysql
    environment:
      MYSQL_ROOT_PASSWORD: drupal
      MYSQL_DATABASE: drupal
      MYSQL_USER: drupaluser
      MYSQL_PASSWORD: drupalpass
    volumes:
      - mysql-volume:/var/lib/mysql
    networks:
      - drupal-network

volumes:
  drupal-volume:
  mysql-volume:

networks:
  drupal-network:
    driver: bridge</code></pre>

<h2>4. Construção e Execução</h2>
<p>Execute o seguinte comando para subir os containers:</p>
<pre><code>docker-compose up --build</code></pre>
<p>O Drupal estará disponível em: <strong>http://localhost:8080</strong></p>

<h3>Execução dos Scripts</h3>
<pre><code>docker exec -it drupal-t1 bash
cd /opt/drupal
./configure.sh
./create-node.sh</code></pre>
';

\$doc_node = Node::create([
  'type' => 'page',
  'title' => 'Documentação do Projeto',
  'body' => [['value' => \$html, 'format' => 'full_html']]
]);
\$doc_node->save();
echo \$doc_node->id();
")

# Criar página principal com link para a página de documentação
MAIN_NODE_ID=$(drush eval "
use Drupal\node\Entity\Node;

\$html = '
<h1>DRUPAL em container</h1>
<h2><strong>DISCIPLINA: CLOUD COMPUTING</strong></h2>
<p><strong>Prof. Luiz A. de P. Lima Jr.</strong></p>
<h3>Equipe:</h3>
<ul>
<li>Camily Pereira Albres</li>

</ul>
<h3>Documentação</h3>
<p>Acesse <a href=\"/node/$DOC_NODE_ID\">aqui</a> a documentação do projeto.</p>
';

\$main_node = Node::create([
  'type' => 'page',
  'title' => 'Prática Containers',
  'body' => [['value' => \$html, 'format' => 'full_html']]
]);
\$main_node->save();
echo \$main_node->id();
")

# Definir página principal como página inicial
drush config:set system.site page.front "/node/$MAIN_NODE_ID" --yes

echo "Páginas criadas com sucesso!"
echo "Página principal: http://localhost:8080/node/$MAIN_NODE_ID"
echo "Página de documentação: http://localhost:8080/node/$DOC_NODE_ID"

