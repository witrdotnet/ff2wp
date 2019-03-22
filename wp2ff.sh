#!/bin/bash

function usage {
  echo -e "======================\n"
  echo " $0 <wordpress dir> <backup dir>"
  echo ""
}

if [ "$#" -lt 1 ]; then
  echo -e "\n======================"
    echo "ERROR: Illegal number of parameters"
    usage
    exit 1
fi

wordpress_dir=$1
BACKUP_DIR=${2:-./}/posts-backup-$(date +%Y%m%d%H%M)}
mkdir -p $BACKUP_DIR

cd $wordpress_dir

# export no posts
wp export --dir=$BACKUP_DIR --post_type__not_in=post,revision --skip_comments

wp post list --post_type=post --field=ID | while read postId; do

  # year of post
  post_year=$(wp post get --field=post_date $postId | cut -d'-' -f1)

  post_dir_name=$postId
  echo "export $postId to $BACKUP_DIR/$post_year/$post_dir_name"

  # create post dir
  BACKUP_POST_DIR=$BACKUP_DIR/$post_year/$post_dir_name
  mkdir -p $BACKUP_POST_DIR

  # export post content
  wp post get $postId --field=post_content > $BACKUP_POST_DIR/content.md

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
  echo "post_date       = $post_date"       >> $BACKUP_POST_DIR/prop.properties
  echo "post_date_gmt   = $post_date_gmt"   >> $BACKUP_POST_DIR/prop.properties
  echo "post_title      = $post_title"      >> $BACKUP_POST_DIR/prop.properties
  echo "post_status     = $post_status"     >> $BACKUP_POST_DIR/prop.properties
  echo "post_author     = $post_author"     >> $BACKUP_POST_DIR/prop.properties
  echo "post_tags       = $post_tags"       >> $BACKUP_POST_DIR/prop.properties
  echo "post_categories = $post_categories" >> $BACKUP_POST_DIR/prop.properties
done

