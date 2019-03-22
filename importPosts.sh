#!/bin/bash

wordpress_dir=/var/www/html
cd $wordpress_dir

ls /var/posts | while read postYear; do
  echo "== $postYear"
  ls /var/posts/$postYear | while read postId; do
    echo " - import $postId"

    grep 'post_categories ' /var/posts/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' | sed 's/,/\n/g' | while read post_categ; do
      echo "    try to create category: $post_categ"
      wp term create category $post_categ 2>/dev/null
    done

    post_author=1
    wp post create \
	    --post_date="$(grep 'post_date ' /var/posts/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' )" \
	    --post_title="$(grep 'post_title ' /var/posts/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' )" \
	    --post_status="$(grep 'post_status ' /var/posts/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' )" \
	    --tags_input=$(grep 'post_tags ' /var/posts/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' ) \
            --post_category=$(grep 'post_categories ' /var/posts/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' ) \
	    --post_author=$post_author \
	    /var/posts/$postYear/$postId/content.md
  done
done
