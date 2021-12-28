# website1

My personal website, live at https://ear7h.net/~julio/

The website is static and generated with Dhall and 
[buildsys3](https://github.com/ear7h/buildsys3) . At some point I'll make
a more in-depth blog post about it.

## Deployment

The command to run this in "production" is:

```
# trailing slash, and lack thereof, is important
ROOT=/~julio BUILD_DIR=~/public/html/ buildsys3
```

## TODO
* Use only a single dhall implementation
* use single convention for paths
  * html links are created with `"${root}/path"` while files are done with
    `BUILD_DIR ++ path`
