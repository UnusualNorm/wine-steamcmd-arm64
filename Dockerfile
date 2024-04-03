FROM weilbyte/box

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl ca-certificates \
    xvfb

COPY install-wine.sh /install-wine.sh
RUN chmod +x /install-wine.sh
RUN /install-wine.sh
RUN rm /install-wine.sh

RUN apt-get -y autoremove \
 && apt-get clean autoclean \
 && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists

ENTRYPOINT ["/usr/local/bin/box64", "/usr/local/bin/wine64"]