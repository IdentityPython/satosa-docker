#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s nullglob

# operate in same directory as this script
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

# when bootstrapping, create a directory for each desired SATOSA
# version, then run this script with no arguments
versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
	json='{}'
else
	json="$(< versions.json)"
fi
versions=( "${versions[@]%/}" )

# grab list of Python container images, filtering out unsupported variants
variants=$(
	curl -s https://raw.githubusercontent.com/docker-library/python/master/versions.json \
		| jq -r 'keys[] as $k | .[$k].variants | map("py\($k)-\(.)") | .[]' \
		| grep -v windows
		)
export variants

for version in "${versions[@]}"; do
	export version

	# find the latest SATOSA point release for this version
	possibles=(
		$(
			git ls-remote --tags https://github.com/IdentityPython/SATOSA.git "refs/tags/v${version}.*" \
				| sed -r 's!^.*refs/tags/v([0-9a-z.]+).*$!\1!' \
				| grep -v -E -- '[a-zA-Z]+' \
				| sort -ruV
		)
	)

	# TODO: confirm with PyPI, but for now pick the latest tagged version
	fullVersion="${possibles[0]}"

	# TODO: filter out unsupported versions of the base container image

	# generate the versions.json entry for this SATOSA release
	echo "$version: $fullVersion"
	export fullVersion
	json="$(jq <<<"$json" -c '
		.[env.version] = {
			variants: env.variants | split("\n"),
			version: env.fullVersion,
		}
	')"
done

jq <<<"$json" -S . > versions.json
