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

# determine latest Python container version and supported variants
eval $(
	curl -s https://raw.githubusercontent.com/docker-library/python/master/versions.json \
		| jq -r '
			. as $versions
			| [ $versions|keys[] | select(contains("-rc") | not) ] | sort_by(split(".") | map(tonumber)) | last as $latest
			| [ $versions | .[$latest].variants[] | select(test("alpine3.18|slim-bookworm")) ] | join(" ") as $variants
			| @sh "export python_version=\($latest) variants=\($variants)"
		'
)

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

	# pick the latest tagged release
	fullVersion="${possibles[0]}"

	# generate the versions.json entry for this SATOSA release
	echo "$version: $fullVersion"
	export fullVersion
	json="$(jq <<<"$json" -c '
		.[env.version] = {
			variants: env.variants | sub("slim-"; "") | split(" "),
			version: env.fullVersion,
			python_version: env.python_version,
		}
	')"
done

jq <<<"$json" -S . > versions.json
