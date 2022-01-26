FROM golang:1.17-bullseye as build

RUN go install github.com/wealdtech/ethereal/v2@latest

RUN go install github.com/protolambda/eth2-val-tools@latest

FROM debian:bullseye-slim

RUN apt update && apt install -y --no-install-recommends jq bash ca-certificates

COPY --from=build /go/bin/eth2-val-tools /usr/local/bin/
COPY --from=build /go/bin/ethereal /usr/local/bin/ 

COPY exec_deposits.sh /usr/local/bin/
COPY kintsugi.env /usr/local/bin/

ENTRYPOINT ["eth2-val-tools"]
