FROM ghcr.io/stefan-hoeck/idris2-pack:nightly-240625

# install packages required to run the tests
RUN apt-get update && apt-get install --yes jq
RUN pack install tester

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
