FROM prom/alertmanager

COPY ./config.yml /etc/alertmanager

CMD ["/bin/alertmanager", "--config.file=/etc/alertmanager/config.yml", "--storage.path=/alertmanager"]
