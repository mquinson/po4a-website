FROM ghcr.io/mquinson/po4a:master

ENV LANG C.UTF-8
ENV LANGUAGE en
ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV COLUMNS 120
ENV CI=1

# libxml2-utils provides xmlcatalogs
RUN set -eux; apt-get update; apt-get install -y --no-install-recommends git rsync libxml2-utils man2html

# po4a image has compiled sources available in /srv/po4a

COPY . /srv/website-src
WORKDIR /srv/website-src

RUN sh 01-build-pages.sh
# add common assets
RUN cp -a src/. html/

# move result to be published
# to the OSCI's openshift-apps/php_website role location
RUN mv html /srv/website

# force Content-Type for localized file extensions
#
# Using FileMatch+SetHandler, even with MultiviewsMatch Any did not work with content negociation
WORKDIR /srv/website
RUN for f in index.php.*; do echo "AddType application/x-httpd-php ${f##*.}">>.htaccess; done
