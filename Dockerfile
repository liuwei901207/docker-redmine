FROM quay.io/sameersbn/ubuntu:14.04.20151013
MAINTAINER sameer@damagehead.com

ENV REDMINE_VERSION=2.6.7 \
    REDMINE_USER="redmine" \
    REDMINE_HOME="/home/redmine" \
    REDMINE_LOG_DIR="/var/log/redmine" \
    SETUP_DIR="/var/cache/redmine" \
    RAILS_ENV=production

ENV REDMINE_INSTALL_DIR="${REDMINE_HOME}/redmine" \
    REDMINE_DATA_DIR="${REDMINE_HOME}/data"

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E1DD270288B4E6030699E45FA1715D88E1DF1F24 \
 && echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv 80F70E11F0F0D5F10CB20E62F5DA5F09C3173AA6 \
 && echo "deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv 8B3981E7A6852F782CC4951600A6F0A3C300EE8C \
 && echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" >> /etc/apt/sources.list \
 && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
 && apt-get update \
 && apt-get install -y supervisor logrotate nginx mysql-client postgresql-client \
      imagemagick subversion git cvs bzr mercurial rsync ruby2.1 locales openssh-client \
      gcc g++ make patch pkg-config ruby2.1-dev libc6-dev zlib1g-dev libxml2-dev \
      libmysqlclient18 libpq5 libyaml-0-2 libcurl3 libssl1.0.0 \
      libxslt1.1 libffi6 zlib1g gsfonts \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && gem install --no-document bundler \
 && rm -rf /var/lib/apt/lists/*

COPY assets/setup/ ${SETUP_DIR}/
RUN bash ${SETUP_DIR}/install.sh

COPY assets/config/ ${SETUP_DIR}/config/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 80/tcp 443/tcp

VOLUME ["${REDMINE_DATA_DIR}", "${REDMINE_LOG_DIR}"]
WORKDIR ${REDMINE_INSTALL_DIR}
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["app:start"]
