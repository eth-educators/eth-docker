FROM wealdtech/ethdo:latest

ARG USER=ethdo
ARG UID=1000

# See https://stackoverflow.com/a/55757473/12429735RUN
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

RUN apt-get update && apt-get install -y gosu jq

RUN mkdir -p /app/wallet
RUN chown -R ${USER}:${USER} /app

COPY ./docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "/app/ethdo" ]
