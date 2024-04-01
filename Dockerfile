FROM ghcr.io/sonroyaalmerol/steamcmd-arm64:root-bullseye

COPY install-wine.sh /install-wine.sh
RUN chmod +x /install-wine.sh
RUN /install-wine.sh

COPY install-winetricks.sh /install-winetricks.sh
RUN chmod +x /install-winetricks.sh
RUN /install-winetricks.sh

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*