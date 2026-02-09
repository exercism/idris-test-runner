FROM ghcr.io/stefan-hoeck/idris2-pack:nightly-260208-jammy

# install packages required to run the tests
RUN apt-get update && apt-get install --yes jq
RUN pack install contrib tester

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
