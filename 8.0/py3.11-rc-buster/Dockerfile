#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh".
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM python:3.11-rc-buster

# runtime dependencies
RUN set -eux; \
	useradd -U satosa; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		jq \
		xmlsec1 \
	; \
	rm -rf /var/lib/apt/lists/*; \
	pip install --no-cache-dir \
		yq \
	;

ENV SATOSA_VERSION 8.0.1
RUN set -eux; \
	pip install --no-cache-dir \
		ldap3 \
		satosa==${SATOSA_VERSION} \
	; \
	mkdir /etc/satosa; \
	chown -R satosa:satosa /etc/satosa

# example configuration
RUN set -eux; \
	python -c 'import urllib.request; urllib.request.urlretrieve("https://github.com/IdentityPython/SATOSA/archive/refs/tags/v'${SATOSA_VERSION%%[a-z]*}'.tar.gz","/tmp/satosa.tgz")'; \
	mkdir /tmp/satosa; \
	tar --extract --directory /tmp/satosa --strip-components=1 --file /tmp/satosa.tgz; \
	rm /tmp/satosa.tgz; \
	mkdir -p /usr/share/satosa; \
	cp -a /tmp/satosa/example /usr/share/satosa; \
	rm -rf /tmp/satosa

VOLUME /etc/satosa
WORKDIR /etc/satosa

COPY --chown=satosa:satosa docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 8080
USER satosa:satosa
CMD ["gunicorn","-b0.0.0.0:8080","satosa.wsgi:app"]
