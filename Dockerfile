FROM ghcr.io/stefan-hoeck/idris2-pack:nightly-261112-resolute AS builder

# Install the libraries used by the test runner.
# Remove the idris2 compiler-as-a-library package
RUN pack install contrib tester \
    && rm -r /root/.local/state/pack/install/*/idris2/idris2-0.8.0/idris2-0.8.0 \
    && rm -r /root/.cache/pack/git

# Final image on the shared, pinned ubuntu base.
# The idris2-pack base is itself Ubuntu, keeping the versions matched.
FROM ubuntu:26.04@sha256:6a06111c3b0a8600feadb270aec771dc239bf407b25625f93f44ab00e11f4d3c

# Same runtime deps idris2-pack installs (gcc/make/chezscheme/libgmp3-dev/git) plus jq.
RUN apt-get update \
    && apt-get install --yes --no-install-recommends chezscheme gcc jq libgmp3-dev make \
    && apt-get purge --auto-remove -y \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /usr/share/icons /usr/share/doc /usr/share/man

ENV PACK_USER_DIR=/root/.config/pack \
    PACK_STATE_DIR=/root/.local/state/pack \
    PACK_CACHE_DIR=/root/.cache/pack \
    PACK_BIN_DIR=/root/.local/bin \
    PATH=/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin

COPY --from=builder /root/.local/bin        /root/.local/bin
COPY --from=builder /root/.config/pack      /root/.config/pack
COPY --from=builder /root/.local/state/pack /root/.local/state/pack
COPY --from=builder /root/.cache/pack       /root/.cache/pack

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
