# Source: https://github.com/ptitSeb/box64/blob/main/docs/X64WINE.md
# NOTE: Removed all sudo commands
# NOTE: Changed from Downloads folder to home folder
set -Eeuxo pipefail

apt-get install cabextract -y                                                                        # winetricks needs this installed
# mv /usr/local/bin/winetricks /usr/local/bin/winetricks-old                                           # Backup old winetricks
cd ~/ && wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks          # Download
chmod +x winetricks && mv winetricks /usr/local/bin/                                                 # Install
