# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.23

# set version label
ARG BUILD_DATE
ARG VERSION
ARG PROWLARR_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Roxedus,thespad"

# environment settings
ARG PROWLARR_BRANCH="nightly"
ENV XDG_CONFIG_HOME="/config/xdg" \
  COMPlus_EnableDiagnostics=0 \
  TMPDIR=/run/prowlarr-temp

RUN \
  echo "**** install packages ****" && \
  apk add -U --upgrade --no-cache \
    icu-libs \
    sqlite-libs \
    xmlstarlet && \
  echo "**** install prowlarr ****" && \
  mkdir -p /app/prowlarr/bin && \
  if [ -z ${PROWLARR_RELEASE+x} ]; then \
    PROWLARR_RELEASE=$(curl -sL "https://prowlarr.servarr.com/v1/update/${PROWLARR_BRANCH}/changes?runtime=netcore&os=linuxmusl" \
    | jq -r '.[0].version'); \
  fi && \
  curl -o \
    /tmp/prowlarr.tar.gz -L \
    "https://prowlarr.servarr.com/v1/update/${PROWLARR_BRANCH}/updatefile?version=${PROWLARR_RELEASE}&os=linuxmusl&runtime=netcore&arch=x64" && \
  tar xzf \
    /tmp/prowlarr.tar.gz -C \
    /app/prowlarr/bin --strip-components=1 && \
  echo -e "UpdateMethod=docker\nBranch=${PROWLARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=[linuxserver.io](https://www.linuxserver.io/)" > /app/prowlarr/package_info && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/prowlarr/bin/Prowlarr.Update \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 9696

VOLUME /config
