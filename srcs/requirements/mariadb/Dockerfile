FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

COPY ./conf/mariadb.conf /etc/mysql/mariadb.conf.d.50-server.conf

COPY /tools/init_db.sh /usr/local/bin/

RUN chmod 755 /usr/local/bin/init_db.sh

EXPOSE 3306

CMD ["init_db.sh"]