#!/bin/bash

function usage {
  echo -e "\n=========================\n"
  echo "Usage: $0 [-w wordpress directory] [-p posts directory] [-d] [-r]"
  echo ""
  echo " -w: wordpress directory"
  echo " -p: posts directory"
  echo " -d: dry-run mode (no changes will be applied)"
  echo " -r: reset (deletes all contents of posts directory), ignored in dry-run mode"
  echo -e "\n========================="
}

wordpress_dir=""
posts_dir=""
dryrun=false
reset=false

while getopts ":w:p:drh" opt; do
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
    r)
      reset=true
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

echo -e "\nabout to export wp to ff..\n"
echo "  wordpress dir : $wordpress_dir"
echo "  posts dir     : $posts_dir"
echo "  mode dry-run  : $dryrun"
echo "  reset         : $reset"
echo ""
read -n 1 -s -r -p "Press any key to continue (ctrl-c to abort) ..."
echo -e "\n\n"

echo "About to create if not yet exists posts directory"
mkdir -p $posts_dir

cd $wordpress_dir

if [ "$reset" = "true" ]; then
  if [ "$dryrun" = "true" ]; then
    echo ">> mode dryrun.. requested reset is ignored"
  else
    echo "About to delete all contents of posts directory"
    rm -rf $posts_dir
  fi
fi

# export no posts
wp export --dir=$posts_dir --post_type__not_in=post,revision --skip_comments

wp post list --post_type=post --field=ID | while read postId; do

  post_year=$(wp post get --field=post_date $postId | cut -d'-' -f1)
  post_dir_name=$postId
  echo "=== export $postId to $posts_dir/$post_year/$post_dir_name"
  current_post_dir=$posts_dir/$post_year/$post_dir_name
  mkdir -p $current_post_dir

  # export post content
  wp post get $postId --field=post_content > $current_post_dir/content.md

  # post properties
  post_date="$(wp post get $postId --field=post_date)"
  post_date_gmt="$(wp post get $postId --field=post_date_gmt)"
  post_title="$(wp post get $postId --field=post_title)"
  post_status=$(wp post get $postId --field=post_status)
  post_author=$(wp post get $postId --field=post_author)

  # post tags
  post_tags=$(wp post term list $postId post_tag --fields=name --format=csv | tail -n +2 | tr '\n' ',' | sed 's/,$//')

  # post categories
  post_categories=$(wp post term list $postId category --fields=name --format=csv | tail -n +2 | tr '\n' ',' | sed 's/,$//')

  # export properties to properties file
  echo "post_date       = $post_date"       >> $current_post_dir/prop.properties
  echo "post_date_gmt   = $post_date_gmt"   >> $current_post_dir/prop.properties
  echo "post_title      = $post_title"      >> $current_post_dir/prop.properties
  echo "post_status     = $post_status"     >> $current_post_dir/prop.properties
  echo "post_author     = $post_author"     >> $current_post_dir/prop.properties
  echo "post_tags       = $post_tags"       >> $current_post_dir/prop.properties
  echo "post_categories = $post_categories" >> $current_post_dir/prop.properties
done

