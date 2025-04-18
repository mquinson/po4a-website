# Sources of the po4a website

This repository contains everything needed to generate the 
[po4a website](https://po4a.org/). Most of its content
is translated, using po4a of course.

The build scripts are not very advanced for now, and you must clone
this repository in a directory containing an uptodate checkout of po4a
(the source code repository). That other repo *must* be called `po4a`.

The build scripts also require that man2html be available in your path.

### Editing

The source files are located in `src/`.

### Building

The website is rebuilt with the `01-build-pages.sh` script. Once it's
run, you can inspect the result in `html/`

### Uploading

There is a webhook on github, to trigger a rebuild (using the same
script) on OpenShift on push events.


### TODO

The website uses php to allow switching to other languages, and to
have a common header. Since we compile the pages anyway, it'd be good
to not use php. Viewing the result for verification before uploading
would be easier this way.
