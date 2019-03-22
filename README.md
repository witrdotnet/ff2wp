# FlatFile 2 WordPress (ff2wp)

Wordpress is cool, but it would be better with git versionned articles. This is fulfilled by FF2WP.

## Start with wordpress on docker

Download wp-cli on root of project
```
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
```
Then start wordpress (with docker compose) `docker-compose up -d` or restart `docker-compose down && sudo rm -rf data/* && docker-compose up -d`.

Finally proceed import posts into wordpress container

```
docker exec -ti --user www-data wordpress bash -c /var/importPosts.sh
```

