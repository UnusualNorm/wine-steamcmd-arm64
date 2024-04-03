#!/bin/bash
set -e

branch="stable"
version="9.0.0.0"
id=""
dist=""
tag="-1"

if [ -z "$id" ]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ -n "$ID" ]; then
            id="$ID"
        fi
    fi
fi

if [ -z "$dist" ]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ -n "$VERSION_CODENAME" ]; then
            dist="$VERSION_CODENAME"
        fi
    fi
fi

WINE32_LINK="https://dl.winehq.org/wine-builds/${id}/dists/${dist}/main/binary-i386/"
WINE32_MAIN_DEB="wine-${branch}-i386_${version}~${dist}${tag}_i386.deb"
WINE32_SUPPORT_DEB="wine-${branch}_${version}~${dist}${tag}_i386.deb"

WINE64_LINK="https://dl.winehq.org/wine-builds/${id}/dists/${dist}/main/binary-amd64/"
WINE64_MAIN_DEB="wine-${branch}-amd64_${version}~${dist}${tag}_amd64.deb"
WINE64_SUPPORT_DEB="wine-${branch}_${version}~${dist}${tag}_amd64.deb"

curl -O ${WINE32_LINK}${WINE32_MAIN_DEB}
curl -O ${WINE32_LINK}${WINE32_SUPPORT_DEB}
curl -O ${WINE64_LINK}${WINE64_MAIN_DEB}
curl -O ${WINE64_LINK}${WINE64_SUPPORT_DEB}

dpkg-deb -x ${WINE32_MAIN_DEB} wine-installer
# dpkg-deb -x ${WINE32_SUPPORT_DEB} wine-installer # Conflicts with wine64 support files
dpkg-deb -x ${WINE64_MAIN_DEB} wine-installer
dpkg-deb -x ${WINE64_SUPPORT_DEB} wine-installer

mv wine-installer/opt/wine* ~/wine
rm -rf wine-installer

get_dependencies() {
    local deb_file="$1"
    local dependencies=$(dpkg -I "$deb_file" | grep -oP ' Depends:.*$')
    IFS=',' read -ra parts <<< "$dependencies"
    local result=()

    for item in "${parts[@]}"; do
        trimmed_item=$(echo "$item" | awk '{$1=$1};1')
        result+=("${trimmed_item%% *}")
    done

    echo "${result[@]:1}"
}

wine32_dependencies=()
wine32_dependencies=($(get_dependencies "$WINE32_MAIN_DEB"))
wine32_dependencies+=($(get_dependencies "$WINE32_SUPPORT_DEB"))
for i in "${!wine32_dependencies[@]}"; do
    wine32_dependencies[$i]="${wine32_dependencies[$i]}:armhf"
    if [[ ${wine32_dependencies[$i]} == *"wine"* ]]; then
        unset wine32_dependencies[$i]
    fi
done

wine64_dependencies=()
wine64_dependencies=($(get_dependencies "$WINE64_MAIN_DEB"))
wine64_dependencies+=($(get_dependencies "$WINE64_SUPPORT_DEB"))
for i in "${!wine64_dependencies[@]}"; do
    wine64_dependencies[$i]="${wine64_dependencies[$i]}:arm64"
    if [[ ${wine64_dependencies[$i]} == *"wine"* ]]; then
        unset wine64_dependencies[$i]
    fi
done

dpkg --add-architecture armhf && apt-get update
apt-get install --no-install-recommends -y ${wine32_dependencies[@]}
apt-get install --no-install-recommends -y ${wine64_dependencies[@]}

rm ${WINE32_MAIN_DEB} ${WINE32_SUPPORT_DEB} ${WINE64_MAIN_DEB} ${WINE64_SUPPORT_DEB}

echo "box86 ~/wine/bin/wine \$@" >> /usr/local/bin/wine
echo "box64 ~/wine/bin/wine64 \$@" >> /usr/local/bin/wine64
ln -s ~/wine/bin/wineboot /usr/local/bin/wineboot
ln -s ~/wine/bin/winecfg /usr/local/bin/winecfg
echo "box64 ~/wine/bin/wineserver \$@" >> /usr/local/bin/wineserver
chmod +x /usr/local/bin/wine /usr/local/bin/wine64 /usr/local/bin/wineboot /usr/local/bin/winecfg /usr/local/bin/wineserver

apt-get install --no-install-recommends -y cabextract
curl -O https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks && mv winetricks /usr/local/bin/winetricks