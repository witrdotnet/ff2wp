# FlatFile 2 WordPress (ff2wp)

Wordpress is cool, we can not live without, but it could be better with git versioned articles. This need is fulfilled by **ff2wp**.

## Requirements

- Your Wordpress site
- Installed wp-cli on wordpress host (install [from here](https://wp-cli.org/fr/#installation)).
- Installed wp-markdown plugin, activated and enabled (see [how to enable](https://en.support.wordpress.com/wordpress-editor/blocks/markdown-block/#enabling-markdown))

## How To

### Prepare your posts

Clone this project and prepare posts directory like following:

```
posts
├── 2019
│   └── agile-software-development
│       ├── content.md
│       └── prop.properties
├── 2018
│   ├── debug-with-git-bisect
│   │   ├── content.md
│   │   └── prop.properties
│   └── what-is-immutable-infrastructure
│       ├── content.md
│       └── prop.properties
├── pages
│   ├── about-me
│   │   ├── content.md
│   │   └── prop.properties
│   └── contact-me
│       ├── content.md
│       └── prop.properties
```

With:

- content.md: your markdown post content (each content.md is a different article)
- prop.properties: properties of each article must contain:

```
  - post_date       = date of post                // e.g: 2019-03-14 23:55:44
  - post_date_gmt   = gmt date of post            // e.g: 2019-03-14 23:55:44
  - post_title      = title of post               // e.g: Hello World !
  - post_status     = wordpress status of article // possible values: publish, pending, draft
  - post_type       = type of post                // possible values: post, page
  - post_author     = id of wordpress author      // e.g: 1
  - post_tags       = comma separated tags        // e.g: ansible,shell,deployment
  - post_categories = comma separated categories  // e.g: IT,devops
```

> If you have already posts in your wp site then use `wp2ff.sh` to export all these posts into previously described flat file structure.

### Import flat file markdown into Wordpress

Once posts folder is ready:

1. Copy your posts directory into your wordpress host.

2. Copy ff2wp.sh script into your wordpress host and run it:

```
./ff2wp.sh -w <wordpress dir> -p <posts dir>
```

Enjoy !

You may want test this on docker before enjoying:

[Start with ff2wp on docker](./docker)
