FROM ghcr.io/stefan-hoeck/idris2-pack:nightly-260208-jammy AS builder

# install the libraries exercises test against
RUN pack install contrib tester

# Remove the idris2 compiler-as-a-library package
RUN rm -rf /root/.local/state/pack/install/*/idris2/idris2-0.8.0/idris2-0.8.0

RUN rm -rf /root/.cache/pack/git

# Final image on the shared, pinned ubuntu:22.04 base (the idris2-pack base is
# itself Ubuntu 22.04). Digest below is the 2026-04-10 build of 22.04.
FROM ubuntu:22.04@sha256:962f6cadeae0ea6284001009daa4cc9a8c37e75d1f5191cf0eb83fe565b63dd7

# Same runtime deps idris2-pack installs (gcc/make/chezscheme/libgmp3-dev/git) plus jq.
RUN apt-get update \
    && apt-get install --yes --no-install-recommends gcc make chezscheme libgmp3-dev git jq \
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
