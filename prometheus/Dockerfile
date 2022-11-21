FROM prom/prometheus

COPY ./*-prom.yml /etc/prometheus/
COPY ./global.yml /etc/prometheus
COPY ./choose-config.sh /usr/local/bin/choose-config.sh
USER root
RUN chown nobody:nobody /etc/prometheus/*.yml
USER nobody

# For reference and local testing with docker; this is otherwise set by docker-compose
ENV CLIENT=lighthouse.yml

ENTRYPOINT choose-config.sh
CMD ["/bin/prometheus", "--storage.tsdb.path=/prometheus", "--web.console.libraries=/usr/share/prometheus/console_libraries", "--web.console.templates=/usr/share/prometheus/consoles"]
