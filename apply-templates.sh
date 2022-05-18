#!/usr/bin/env bash
set -Eeuo pipefail

if [ ! -f versions.json ]; then
	echo run \"versions.sh\" first
	exit 1
fi

jqt='.jq-template.awk'
if [ -n "${BASHBREW_SCRIPTS:-}" ]; then
	jqt="$BASHBREW_SCRIPTS/jq-template.awk"
elif [ "$BASH_SOURCE" -nt "$jqt" ]; then
	# https://github.com/docker-library/bashbrew/blob/master/scripts/jq-template.awk
	wget -qO "$jqt" 'https://github.com/docker-library/bashbrew/raw/1da7341a79651d28fbcc3d14b9176593c4231942/scripts/jq-template.awk'
fi

if [ "$#" -eq 0 ]; then
	versions="$(jq -r 'keys | map(@sh) | join(" ")' versions.json)"
	eval "set -- $versions"
fi

generated_warning() {
	cat <<-EOH
		#
		# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh".
		#
		# PLEASE DO NOT EDIT IT DIRECTLY.
		#

	EOH
}

for version; do
	export version

	# reset all the generated Dockerfile
	rm -rf "$version/"

	variants="$(jq -r '.[env.version].variants | map(@sh) | join(" ")' versions.json)"
	eval "variants=( $variants )"

	for dir in "${variants[@]}"; do
		variant="$(basename "$dir")" # "pyX.YY-buster", "pyX.YY-windowsservercore-1809", etc.
		export variant

		case "$dir" in
			windows/*)
				windowsVariant="${variant%%-*}"               # "windowsservercore", "nanoserver"
				windowsRelease="${variant#$windowsVariant-}"  # "ltsc2022", "1809", etc.
				windowsVariant="${windowsVariant#windows}"    # "servercore", "nanoserver"
				export windowsVariant windowsRelease
				template='Dockerfile-windows.template'
				;;

			*)
				template='Dockerfile-linux.template'
				;;
		esac

		echo "processing $version/$dir ..."
		mkdir -p "$version/$dir"

		{
			generated_warning
			gawk -f "$jqt" "$template"
		} > "$version/$dir/Dockerfile"

		cp -a docker-entrypoint.sh "$version/$dir/"
	done
done
