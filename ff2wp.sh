#!/bin/bash

function usage {
  echo -e "\n=========================\n"
  echo "Usage: $0 [-w wordpress directory] [-p posts directory] [-d]"
  echo ""
  echo " -w: requires arg wordpress directory"
  echo " -p: requires arg posts directory"
  echo " -d: no arg required, switch dry run mode"
  echo -e "\n========================="
}

wordpress_dir=""
posts_dir=""
dryrun=false

while getopts ":w:p:dh" opt; do
  case $opt in
    w)
      wordpress_dir=$(realpath $OPTARG)
      ;;
    p)
      posts_dir=$(realpath $OPTARG)
      ;;
    d)
      dryrun=true
      ;;
    h)
      usage
      exit 1
      ;;
    \?)
      echo -e "\nInvalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
    :)
      echo -e "\nOption -$OPTARG requires an argument." >&2
      usage
      exit 1
      ;;
  esac
done

if [ -z "$wordpress_dir" ] || [ -z "$posts_dir" ]; then
  echo -e "\nMissed wordpress directory or posts directory or both."
  usage
  exit 1
fi

echo "about to import ff to wp .."
echo "wordpress dir: $wordpress_dir"
echo "posts dir: $posts_dir"

cd $wordpress_dir

ls $posts_dir | while read postYear; do
  ls $posts_dir/$postYear | while read postId; do
    echo "=== import $postYear : $postId"

    grep 'post_categories ' $posts_dir/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' | sed 's/,/\n/g' | while read post_categ; do
      echo "try to create category: $post_categ"
      wp term create category "$post_categ" 2>/dev/null
    done

    post_author=1
    post_date="$(grep 'post_date ' $posts_dir/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' )"
    post_title="$(grep 'post_title ' $posts_dir/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' )"
    post_status="$(grep 'post_status ' $posts_dir/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' )"
    tags_input=$(grep 'post_tags ' $posts_dir/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' )
    post_category=$(grep 'post_categories ' $posts_dir/$postYear/$postId/prop.properties | awk -F '= ' '{print $2}' )

    echo "about to create post: $post_title ($post_status)"
    echo "  --post_date=\"$post_date\""
    echo "  --post_title=\"$post_title\""
    echo "  --post_status=\"$post_status\""
    echo "  --tags_input=$tags_input"
    echo "  --post_category=$post_category"
    echo "  --post_author=$post_author"

    if [ "$dryrun" = "true" ]; then
      echo ">> mode dryrun.. no updates will take effect"
    else
      wp post create \
	    --post_date="$post_date" \
	    --post_title="$post_title" \
	    --post_status="$post_status" \
	    --tags_input=$tags_input \
	    --post_category=$post_category \
	    --post_author=$post_author \
	    $posts_dir/$postYear/$postId/content.md
    fi
  done
done
