FROM ghcr.io/stefan-hoeck/idris2-pack:nightly-260208-jammy AS builder

# install packages required to run the tests
RUN apt-get update && apt-get install --yes jq && rm -rf /var/lib/apt/lists/*

# install the libraries exercises test against
RUN pack install contrib tester

RUN rm -rf /root/.cache/pack/git

FROM scratch
COPY --from=builder / /
ENV PATH=/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    HOME=/root \
    PACK_USER_DIR=/root/.config/pack \
    PACK_STATE_DIR=/root/.local/state/pack \
    PACK_CACHE_DIR=/root/.cache/pack \
    PACK_BIN_DIR=/root/.local/bin

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
