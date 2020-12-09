FROM registry.bvds.fr/owncloud-server

VOLUME ["/mnt/data"]
EXPOSE 8080

ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["/usr/bin/owncloud", "server"]

RUN apt-get update -y && apt-get -y install cron
COPY owncloud-cron /etc/cron.d/owncloud-cron
RUN chmod 0644 /etc/cron.d/owncloud-cron
RUN crontab /etc/cron.d/owncloud-cron
RUN touch /var/log/cron.log
