# This is taken from NM github, just ETH1_NETWORK is custom 
FROM ubuntu:18.04 AS clone

WORKDIR /src

RUN apt-get update -y && apt-get install -y git
RUN git clone https://github.com/NethermindEth/nethermind
# custom in order to get latest tag
RUN git config advice.detachedHead false && git fetch --all --tags && git checkout ${BUILD_TARGET}
# end of custom
RUN cd nethermind && git -c submodule."src/tests".update=none submodule update --init

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS builder

COPY --from=clone /src .

RUN cd nethermind/src/Nethermind/Nethermind.Runner && \
    dotnet publish -c release -o out

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1

RUN apt-get update -y && apt-get install -y libsnappy-dev libc6-dev libc6 unzip

COPY --from=builder /nethermind/src/Nethermind/Nethermind.Runner/out .

# This is no longer from NM github

ARG ETH1_NETWORK

ENV ASPNETCORE_ENVIRONMENT docker
ENV NETHERMIND_CONFIG "${ETH1_NETWORK}"
ENV NETHERMIND_DETACHED_MODE true
ENV NETHERMIND_URL http://*:8645

ARG BUILD_TARGET
ARG USER
ARG UID

RUN adduser \
    --disabled-password \
    --gecos "" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

RUN mkdir -p /var/lib/nethermind && chown ${USER}:${USER} /var/lib/nethermind
RUN mkdir -p /etc/nethermind && chown ${USER}:${USER} /etc/nethermind

RUN mkdir /logs && chown ${USER}:${USER} /logs
RUN mkdir /keystore && chown ${USER}:${USER} /keystore
RUN mkdir /Nethermind && chown -R ${USER}:${USER} /Nethermind
RUN mkdir /nethermind_db && chown -R ${USER}:${USER} /nethermind_db

COPY --from=builder /nethermind/src/Nethermind/Nethermind.Runner/out /usr/local/bin/

# Use an unprivileged user.
USER ${USER}:${USER}

ENTRYPOINT dotnet Nethermind.Runner.dll
