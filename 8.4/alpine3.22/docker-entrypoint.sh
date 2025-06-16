#!/usr/bin/env bash
set -Eeuo pipefail

# usage: file_env VAR [DEFAULT]
#  e.g.: file_env 'XYZ_PASSWORD' 'example'
# (will allow for "$XYZ_PASSWORD_FILE" to fill in the value of
# "$XYZ_PASSWORD" from a file, especially for Docker's secrets
# feature)
function file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

# check to see if this file is being run or sourced from another
# script
function _is_sourced() {
	# https://unix.stackexchange.com/a/215279
	[ "${#FUNCNAME[@]}" -ge 2 ] \
		&& [ "${FUNCNAME[0]}" = '_is_sourced' ] \
		&& [ "${FUNCNAME[1]}" = 'source' ]
}

# usage: _make_conffile DEST_FILE YQ_FILTER
#  e.g.: _make_conffile proxy_conf.yaml
# (if DEST_FILE does not exist, create it from the config example,
# passing it through YQ_FILTER)
function _make_conffile() {
	if [ -f "$1" ]; then return; fi
	mkdir -p "$(dirname "$1")"
	case "$1" in
		*.json)
			jq    "${2:-.}" "/usr/share/satosa/example/$1.example" > "$1"
			;;
		*.xml)
			xq -x "${2:-.}" "/usr/share/satosa/example/$1.example" > "$1"
			;;
		*.yaml | *.yml)
			yq -y "${2:-.}" "/usr/share/satosa/example/$1.example" > "$1"
			;;
		*)
			jq -r "${2}" -n                                        > "$1"
			;;
	 esac
}

# usage: _make_selfsigned DEST_FILE COMMON_NAME
#  e.g.: _make_selfsigned https
# (if DEST_FILE.crt and DEST_FILE.key does not exist, generate a new
# key pair; COMMON_NAME is optional and defaults to the hostname part
# of $BASE_URL)
function _make_selfsigned() {
	if [ ! -f "$1.crt" -a ! -f "$1.key" ]; then
		openssl req -batch -x509 -nodes -days 3650 -newkey rsa:2048 \
			-keyout "$1.key" -out "$1.crt" \
			-subj "/CN=${2:-${HOSTNAME}}"
	fi
}

# load various settings used throughout the script
function docker_setup_env() {
	file_env BASE_URL                 https://example.com
	file_env STATE_ENCRYPTION_KEY     $(python -c 'import random, string; print("".join(random.sample(string.ascii_letters+string.digits,32)))')
	file_env SAML2_BACKEND_DISCO_SRV  https://service.seamlessaccess.org/ds/
	file_env SAML2_BACKEND_CERT       ''
	file_env SAML2_BACKEND_KEY        ''
	file_env SAML2_FRONTEND_CERT      ''
	file_env SAML2_FRONTEND_KEY       ''
	export HOSTNAME="$(echo "${BASE_URL}" | sed -E -e 's/https?:\/\///')"
}

# configure SATOSA initially as an SP-to-IdP proxy using Signet's
# SAMLtest.ID testing service
function docker_create_config() {
	_make_conffile proxy_conf.yaml '
		.BASE = $ENV.BASE_URL
			| .STATE_ENCRYPTION_KEY = $ENV.STATE_ENCRYPTION_KEY
			| .FRONTEND_MODULES = [ "plugins/frontends/saml2_frontend.yaml", "plugins/frontends/ping_frontend.yaml" ]
	'

	_make_conffile internal_attributes.yaml '
		del(.hash, .user_id_from_attrs, .user_id_to_attr)
	'

	_make_conffile plugins/backends/saml2_backend.yaml '
		del(.config.acr_mapping, .config.idp_blacklist_file, .config.sp_config.metadata.local)
			| .config.disco_srv = $ENV.SAML2_BACKEND_DISCO_SRV
			| .config.sp_config.metadata.remote = [{ "url": "https://samltest.id/saml/idp" }]
	'
	if [ -n "${SAML2_BACKEND_CERT}" -a -n "${SAML2_BACKEND_KEY}" ]; then
		_make_conffile backend.crt '$ENV.SAML2_BACKEND_CERT'
		_make_conffile backend.key '$ENV.SAML2_BACKEND_KEY'
	else
		_make_selfsigned backend
	fi

	_make_conffile plugins/frontends/saml2_frontend.yaml '
		del(.config.idp_config.metadata.local)
			| .config.idp_config.metadata.remote = [{ "url": "https://samltest.id/saml/sp" }]
	'
	_make_conffile plugins/frontends/ping_frontend.yaml

	if [ -n "${SAML2_FRONTEND_CERT}" -a -n "${SAML2_FRONTEND_KEY}" ]; then
		_make_conffile frontend.crt '$ENV.SAML2_FRONTEND_CERT'
		_make_conffile frontend.key '$ENV.SAML2_FRONTEND_KEY'
	else
		_make_selfsigned frontend
	fi

	_make_conffile plugins/microservices/static_attributes.yaml
}

function docker_pprint_metadata() {
	if [ \( ! -f backend.key \) -o \( ! -f backend.crt \) -o -f backend.xml -o -f frontend.xml ]; then return; fi

	# use the SAML2 backend keymat to temporarily sign the generated metadata
	touch backend.xml frontend.xml
	satosa-saml-metadata proxy_conf.yaml backend.key backend.crt

	echo -----BEGIN SAML2 BACKEND METADATA-----
	xq -x 'del(."ns0:EntityDescriptor"."ns1:Signature")' backend.xml | tee backend.xml.new
	echo -----END SAML2 BACKEND METADATA-----

	echo -----BEGIN SAML2 FRONTEND METADATA-----
	xq -x 'del(."ns0:EntityDescriptor"."ns1:Signature")' frontend.xml | tee frontend.xml.new
	echo -----END SAML2 FRONTEND METADATA-----

	mv backend.xml.new backend.xml
	mv frontend.xml.new frontend.xml
}

function _main() {
	# if the first arg looks like a flag, assume it's for Gunicorn
	if [ "${1:0:1}" = '-' ]; then
		set -- gunicorn "$@"
	fi

	if [ "$1" = 'gunicorn' ]; then
		docker_setup_env
		docker_create_config
		docker_pprint_metadata
		exec "$@"
	fi

	exec "$@"
}

if ! _is_sourced; then
	_main "$@"
fi
