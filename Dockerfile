FROM alpine:3.10
MAINTAINER wiserain

RUN \
	echo "**** install frolvlad/alpine-python3 ****" && \
	apk add --no-cache python3 && \
	python3 -m ensurepip && \
	rm -r /usr/lib/python*/ensurepip && \
	pip3 install --upgrade pip setuptools && \
	if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
	if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
	echo "**** install plugin: telegram ****" && \
	apk add --no-cache py3-cryptography && \
	pip install --upgrade python-telegram-bot && \
	echo "**** install plugins: cfscraper ****" && \
	apk add --no-cache --virtual=build-deps g++ gcc python3-dev libffi-dev openssl-dev && \
	pip install --upgrade cloudscraper && \
	apk del --purge --no-cache build-deps && \
	echo "**** install plugins: convert_magnet ****" && \
	apk add --no-cache boost-python3 libstdc++ && \
	echo "**** install plugin: misc ****" && \
	pip install --upgrade \
		transmissionrpc \
		deluge_client \
		irc_bot && \
	echo "**** install flexget ****" && \
	pip install --upgrade --force-reinstall \
		flexget && \
	echo "**** system configurations ****" && \
	apk --no-cache add shadow tzdata && \
	sed -i 's/^CREATE_MAIL_SPOOL=yes/CREATE_MAIL_SPOOL=no/' /etc/default/useradd && \
	echo "**** cleanup ****" && \
	rm -rf \
		/tmp/* \
		/root/.cache

# copy local files
COPY files/ /

# copy libtorrent libs
COPY --from=emmercm/libtorrent:1.2.2-alpine /usr/lib/libtorrent-rasterbar.so.10 /usr/lib/
COPY --from=emmercm/libtorrent:1.2.2-alpine /usr/lib/python3.7/site-packages/libtorrent*.so /usr/lib/python3.7/site-packages/
COPY --from=emmercm/libtorrent:1.2.2-alpine /usr/lib/python3.7/site-packages/python_libtorrent-*.egg-info /usr/lib/python3.7/site-packages/

# add default volumes
VOLUME /config /data
WORKDIR /config

# expose port for flexget webui
EXPOSE 3539 3539/tcp

# run init.sh to set uid, gid, permissions and to launch flexget
RUN chmod +x /scripts/init.sh
CMD ["/scripts/init.sh"]
