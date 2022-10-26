FROM crashvb/x11:202210200146@sha256:4fd2382c64bad5335d971d69aa47c867a7b4e32d097467bff73ba8133bab1c26 as builder
RUN docker-apt build-essential cmake git kodi-addons-dev libssh-dev libssl-dev pkg-config && \
	git clone --depth 1 --branch 19.4-Matrix https://github.com/xbmc/xbmc.git && \
	git clone --depth 1 --branch 19.0.1-Matrix https://github.com/xbmc/vfs.sftp.git && \
	cd vfs.sftp && mkdir -p build && cd build && \
	cmake -DADDONS_TO_BUILD=vfs.sftp -DADDON_SRC_PREFIX=/ -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=/xbmc/addons -DPACKAGE_ZIP=1 /xbmc/cmake/addons && \
	make

FROM crashvb/x11:202210200146@sha256:4fd2382c64bad5335d971d69aa47c867a7b4e32d097467bff73ba8133bab1c26
ARG org_opencontainers_image_created=undefined
ARG org_opencontainers_image_revision=undefined
LABEL \
	org.opencontainers.image.authors="Richard Davis <crashvb@gmail.com>" \
	org.opencontainers.image.base.digest="sha256:4cdc03ef7ddb904bc3989e9acc504367e8fef60510dbdf9c02bb397112e9d32e" \
	org.opencontainers.image.base.name="crashvb/supervisord:202204100124" \
	org.opencontainers.image.created="${org_opencontainers_image_created}" \
	org.opencontainers.image.description="Image containing kodi." \
	org.opencontainers.image.licenses="Apache-2.0" \
	org.opencontainers.image.source="https://github.com/crashvb/kodi-docker" \
	org.opencontainers.image.revision="${org_opencontainers_image_revision}" \
	org.opencontainers.image.title="crashvb/kodi" \
	org.opencontainers.image.url="https://github.com/crashvb/kodi-docker"

# Install packages, download files ...
RUN docker-apt gnupg && \
	echo "deb http://ppa.launchpad.net/team-xbmc/ppa/ubuntu $(cat /etc/os-release | grep ^VERSION_CODENAME | awk -F= '{print $2}') main" > "/etc/apt/sources.list.d/team-xbmc-ubuntu-ppa.list" && \
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6D975C4791E7EE5E && \
	apt-get update && \
	docker-apt \
		--no-install-recommends \
		ca-certificates \
		kodi-eventclients-kodi-send \
		#kodi-inputstream-rtmp \
		#kodi-inputstream-adaptive \
		#kodi-pvr-* \
		kodi-vfs-sftp \
		kodi \
		#pulseaudio \
		tzdata

# HACK: TODO: Figure out publickey auth failes for kodi-vfs-sftp unless we built it from (the same) source?!?
COPY --from=builder /xbmc/addons/vfs.sftp/vfs.sftp.so.19.0.1 /usr/lib/x86_64-linux-gnu/kodi/addons/vfs.sftp/

# Configure: kodi
ENV KODI_DATA=/home/kodi/.kodi KODI_GID=1000 KODI_UID=1000 X11_GNAME=kodi X11_UNAME=kodi
RUN groupadd --gid=${KODI_GID} kodi && \
	useradd --create-home --gid=${KODI_GID} --groups=ssl-cert --home-dir=/home/kodi --shell=/bin/bash --uid=${KODI_UID} kodi && \
	install --directory --group=kodi --mode=0755 --owner=kodi /home/kodi/.ssh/
	#wget --directory-prefixt=/usr/local/bin --quiet https://raw.github.com/MilhouseVH/texturecache.py/master/texturecache.py && \
	#chmod 0755 /usr/loca/bin/texturecache.py

# Configure: supervisor
COPY kodi-wrapper /usr/local/bin/
COPY supervisord.kodi.conf /etc/supervisor/conf.d/40kodi.conf

# Configure: entrypoint
COPY entrypoint.kodi /etc/entrypoint.d/kodi

# Configure: healthcheck
COPY healthcheck.kodi /etc/healthcheck.d/kodi

VOLUME ${KODI_DATA}
