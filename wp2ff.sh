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

if [ "$dryrun" = "true" ]; then
  echo ">> mode dryrun.. skip create posts directory, temporary directory will be used instead"
  posts_dir=$(mktemp -d)
else
  echo "About to create if not yet exists posts directory"
  mkdir -p $posts_dir
fi

if [ "$reset" = "true" ]; then
  if [ "$dryrun" = "true" ]; then
    echo ">> mode dryrun.. skip reset posts directory"
  else
    echo "About to delete all contents of posts directory"
    rm -rf $posts_dir/*
  fi
fi

cd $wordpress_dir

# export no posts
echo "export to WXR file all except posts"
wp export --dir=$posts_dir --post_type__not_in=post,revision,page --skip_comments

# export posts
echo "start exporting posts to flat files"
wp post list --post_type=post,page --field=ID | while read postId; do

  # post properties
  post_date="$(wp post get $postId --field=post_date)"
  post_date_gmt="$(wp post get $postId --field=post_date_gmt)"
  post_title="$(wp post get $postId --field=post_title)"
  post_status=$(wp post get $postId --field=post_status)
  post_type=$(wp post get $postId --field=post_type)
  post_author=$(wp post get $postId --field=post_author)

  # post tags
  post_tags=$(wp post term list $postId post_tag --fields=name --format=csv | tail -n +2 | tr '\n' ',' | sed 's/,$//')

  # post categories
  post_categories=$(wp post term list $postId category --fields=name --format=csv | tail -n +2 | tr '\n' ',' | sed 's/,$//')

  # post target directory name
  # it's the post title devoid of all chars except dash, spaces and alphanumeric. And then all spaces replaced with dash. And truncated to 100 chars
  post_dir_name=$(echo "$post_title" | sed "s/[^-[:space:][:alnum:]]//g" | sed -E "s/\s+/-/g" | cut -c 1-100)
  if [ "$post_dir_name" = "" ]; then
    post_dir_name="post-no-title"
  fi
  post_year=$(echo "$post_date" | cut -d'-' -f1)
  if [ "$post_type" = "post" ]; then
    post_subdir="$post_year"
  else
    post_subdir="pages"
  fi
  current_post_dir=$posts_dir/$post_subdir/$post_dir_name
  if [ -d "$current_post_dir" ]; then
    post_dir_name="$post_dir_name-$postId"
    current_post_dir=$posts_dir/$post_subdir/$post_dir_name
  fi
  mkdir -p $current_post_dir
  echo "=== export $postId to $current_post_dir"

  # export post content
  wp post get $postId --field=post_content > $current_post_dir/content.md

  # export properties to properties file
  echo "post_date       = $post_date"       >> $current_post_dir/prop.properties
  echo "post_date_gmt   = $post_date_gmt"   >> $current_post_dir/prop.properties
  echo "post_title      = $post_title"      >> $current_post_dir/prop.properties
  echo "post_status     = $post_status"     >> $current_post_dir/prop.properties
  echo "post_type       = $post_type"       >> $current_post_dir/prop.properties
  echo "post_author     = $post_author"     >> $current_post_dir/prop.properties
  echo "post_tags       = $post_tags"       >> $current_post_dir/prop.properties
  echo "post_categories = $post_categories" >> $current_post_dir/prop.properties
done

