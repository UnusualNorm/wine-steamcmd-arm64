# NOTE: Bookworm is currently broken with unwrapped time64 glibc functions: https://github.com/ptitSeb/box86/issues/600
FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget ca-certificates gpg \
    xvfb xauth

COPY install-box.sh /install-box.sh
RUN chmod +x /install-box.sh && /install-box.sh && rm /install-box.sh

COPY install-wine.sh /install-wine.sh
RUN chmod +x /install-wine.sh && /install-wine.sh && rm /install-wine.sh

RUN apt-get -y autoremove \
 && apt-get clean autoclean \
 && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists

ENTRYPOINT ["/usr/local/bin/box64", "/usr/local/bin/wine64"]