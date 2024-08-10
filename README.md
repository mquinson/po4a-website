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

To rebuild the website, just type `01-build-pages.sh` and you can
inspect the result in `html/`.  If the environment variable `UPDATE`
is set to `no`, updates from remote repositories can be skipped.

Be sure to set the appropriate version in the `VERSION` file.

### Uploading

Just type `02-upload.sh` after rebuilding it.

### Developing

You can setup a local development environment with `docker compose up`.
Then open <http://localhost:8000> in a web browser.

You can run tests against local and production environments by typing
`03-tests.sh`.  By default, the local environment is targeted.  To
target the production environment, set the environment variable
`SITE_ENV` to `production`.

### TODO

The website uses php to allow switching to other languages, and to
have a common header. Since we compile the pages anyway, it'd be good
to not use php. Viewing the result for verification before uploading
would be easier this way.
