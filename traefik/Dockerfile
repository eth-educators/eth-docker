# Add AWS CLI to traefik image
ARG DOCKER_TAG=latest

FROM traefik:${DOCKER_TAG}

RUN apk add --no-cache \
        python3 \
        py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install \
        awscli \
	tzdata \
    && rm -rf /var/cache/apk/*
