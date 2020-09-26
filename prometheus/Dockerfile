FROM prom/prometheus

COPY ./lh-prom.yml /etc/prometheus
COPY ./prysm-prom.yml /etc/prometheus
COPY ./choose-config.sh /usr/local/bin/choose-config.sh

# For reference and local testing with docker; this is otherwise set by docker-compose
ENV CLIENT=lh-base

#What a sane entrypoint might look like if I could pass various CMD from docker-compose based on variables
#ENTRYPOINT ["/bin/prometheus", "--storage.tsdb.path=/prometheus", "--web.console.libraries=/usr/share/prometheus/console_libraries", "--web.console.templates=/usr/share/prometheus/consoles"]
#CMD ["--config.file=/etc/prometheus/prometheus.yml"]

ENTRYPOINT choose-config.sh
CMD ["/bin/prometheus", "--storage.tsdb.path=/prometheus", "--web.console.libraries=/usr/share/prometheus/console_libraries", "--web.console.templates=/usr/share/prometheus/consoles"]
