FROM ghcr.io/mquinson/po4a:publish_image

ENV LANG C.UTF-8
ENV LANGUAGE en
ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV COLUMNS 120

RUN set -eux; apt-get update; apt-get install -y --no-install-recommends git rsync

# po4a image has compiled sources available in /srv/po4a

COPY . /srv/website-src
WORKDIR /srv/website-src
RUN git remote add salsa https://salsa.debian.org/mquinson/po4a-website.git

RUN sh 01-build-pages.sh
# add common assets
RUN cp -a src/. html/

# move result to be published
# to the OSCI's openshift-apps/php_website role location
RUN mv html /srv/website
