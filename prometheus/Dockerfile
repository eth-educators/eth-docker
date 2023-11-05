FROM prom/prometheus:latest

COPY ./*-prom.yml /etc/prometheus/
COPY ./rootless/*.yml /etc/prometheus/rootless/
COPY --chown=nobody:nobody ./make-config.sh /usr/local/bin/
COPY --chown=nobody:nobody ./rootless/choose-config.sh /usr/local/bin/
# Belt and suspenders
RUN chmod -R 755 /usr/local/bin/*
USER root
RUN chown nobody:nobody /etc/prometheus/*.yml
RUN chown nobody:nobody /etc/prometheus/rootless/*.yml
USER nobody

ENTRYPOINT make-config.sh
CMD ["/bin/prometheus", "--storage.tsdb.path=/prometheus", "--web.console.libraries=/usr/share/prometheus/console_libraries", "--web.console.templates=/usr/share/prometheus/consoles"]
