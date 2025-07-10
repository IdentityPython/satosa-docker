#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh".
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM python:3.13-alpine3.22

# runtime dependencies
RUN set -eux; \
	addgroup --gid 1000 satosa; \
	adduser -D -G satosa --uid 1000 satosa; \
	apk add --no-cache \
		bash \
		jq \
		libxml2-utils \
		openssl \
		xmlsec \
	; \
	pip install --no-cache-dir \
		yq \
	;

ENV SATOSA_VERSION=8.4.0
RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		bluez-dev \
		bzip2-dev \
		cargo \
		coreutils \
		dpkg-dev dpkg \
		expat-dev \
		findutils \
		gcc \
		gdbm-dev \
		libc-dev \
		libffi-dev \
		libnsl-dev \
		libtirpc-dev \
		linux-headers \
		make \
		musl-dev \
		ncurses-dev \
		openssl-dev \
		pax-utils \
		python3-dev \
		readline-dev \
		sqlite-dev \
		tcl-dev \
		tk \
		tk-dev \
		util-linux-dev \
		xz-dev \
		zlib-dev \
	; \
	pip install --no-cache-dir \
		satosa[idpy_oidc_backend,ldap,pyop_mongo,pyop_redis]==${SATOSA_VERSION} \
	; \
	find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec scanelf --needed --nobanner --format '%n#p' '{}' ';' \
		| tr ',' '\n' \
		| sort -u \
		| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
		| fgrep -v libgcc_s- \
		| fgrep -v libc.so \
		| xargs -rt apk add --no-network --virtual .satosa-rundeps \
	; \
	apk del --no-network .build-deps; \
	mkdir /etc/satosa; \
	chown -R satosa:satosa /etc/satosa

# example configuration
RUN set -eux; \
	python -c 'import urllib.request; urllib.request.urlretrieve("https://github.com/IdentityPython/SATOSA/archive/refs/tags/v'${SATOSA_VERSION%%[a-z]*}'.tar.gz","/tmp/satosa.tgz")'; \
	mkdir /usr/share/satosa; \
	tar --extract --directory /usr/share/satosa --strip-components=1 --file /tmp/satosa.tgz SATOSA-${SATOSA_VERSION%%[a-z]*}/example/; \
	rm /tmp/satosa.tgz

WORKDIR /etc/satosa

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 8080
USER satosa:satosa
CMD ["gunicorn","-b0.0.0.0:8080","satosa.wsgi:app"]
