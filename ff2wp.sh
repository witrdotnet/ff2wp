#!/bin/bash

wordpress_dir=${1:-/var/www/html}
posts_dir=${2:-/var/posts}

echo "about to import ff to wp .."
echo "wordpress dir: $wordpress_dir"
echo "posts dir: $posts_dir"

cd $wordpress_dir

ls $posts_dir | while read postYear; do
  echo "== $postYear"
  ls $posts_dir/$postYear | while read postId; do
    echo " - import $postId"

    grep 'post_categories ' $posts_dir/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' | sed 's/,/\n/g' | while read post_categ; do
      echo "    try to create category: $post_categ"
      wp term create category "$post_categ" 2>/dev/null
    done

    post_author=1
    post_date="$(grep 'post_date ' $posts_dir/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' )"
    post_title="$(grep 'post_title ' $posts_dir/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' )"
    post_status="$(grep 'post_status ' $posts_dir/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' )"
    tags_input=$(grep 'post_tags ' $posts_dir/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' )
    post_category=$(grep 'post_categories ' $posts_dir/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' )

    echo "about to create post: $post_title ($post_status)"

    wp post create \
	    --post_date="$post_date" \
	    --post_title="$post_title" \
	    --post_status="$post_status" \
	    --tags_input=$tags_input \
	    --post_category=$post_category \
	    --post_author=$post_author \
	    $posts_dir/$postYear/$postId/content.md
  done
done
