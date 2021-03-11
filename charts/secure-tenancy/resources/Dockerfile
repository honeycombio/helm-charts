FROM debian:stretch-slim

RUN mkdir -p /srv/hny && \
    apt-get update && \
    apt-get install -y ca-certificates openssl bzip2
WORKDIR /srv/hny

# Need to build with tarball (provided by HNY team) adjacent in docker build directory
COPY secure-tenancy.tbz secure-tenancy.tbz
RUN tar --strip-components 1 -xjf secure-tenancy.tbz && \
    rm secure-tenancy.tbz
