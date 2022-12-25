FROM livepeerci/curl-jq

RUN apk update && apk add su-exec
COPY --chown=1000:1000 ./keymanager.sh /usr/local/bin/
# Belt and suspenders
RUN chmod -R 755 /usr/local/bin/*
