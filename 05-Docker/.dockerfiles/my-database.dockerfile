FROM mysql:latest

COPY sql-init-script/ /docker-entrypoint-initdb.d/

ENV MYSQL_ROOT_PASSWORD password

EXPOSE 3306
EXPOSE 33060

CMD [ "mysqld" ]