# Start ff2wp on docker compose

## TL;DR

run `./startup.sh`

## Details

Download wp-cli on root of current project

```
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
```

Then start wordpress (with docker compose) `docker-compose up -d`

Configure wordpress (http://localhost:8080) :

```
docker exec -ti --user www-data wordpress bash -c "wp core install --title=ff2wp --admin_user=admin --admin_password=admin --admin_email=user@domain.com --skip-email --url=http://localhost:8080"
```

Install wp-markdown plugin

```
wget https://downloads.wordpress.org/plugin/wp-markdown.1.6.1.zip
docker cp wp-markdown.1.6.1.zip wordpress:/var/
docker exec -ti --user www-data wordpress bash -c "wp plugin install /var/wp-markdown.1.6.1.zip --activate"
```

Enable markdown manually in Wordpress settings: see [how to enable](https://en.support.wordpress.com/wordpress-editor/blocks/markdown-block/#enabling-markdown)

Finally proceed import posts into wordpress container

```
docker exec -ti --user www-data wordpress bash -c "/var/ff2wp.sh -w /var/www/html -p /var/posts" -r
```

