FROM prom/prometheus

COPY ./*-prom.yml /etc/prometheus/
COPY ./none.yml /etc/prometheus
COPY ./choose-config.sh /usr/local/bin/choose-config.sh

# For reference and local testing with docker; this is otherwise set by docker-compose
ENV CLIENT=lh-base

ENTRYPOINT choose-config.sh
CMD ["/bin/prometheus", "--storage.tsdb.path=/prometheus", "--web.console.libraries=/usr/share/prometheus/console_libraries", "--web.console.templates=/usr/share/prometheus/consoles"]
