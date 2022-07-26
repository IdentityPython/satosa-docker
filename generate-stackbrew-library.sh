#!/usr/bin/env bash
set -Eeuo pipefail

declare -A aliases=(
	[8.1]='8 latest'
)

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

if [ "$#" -eq 0 ]; then
	versions="$(jq -r 'keys | map(@sh) | join(" ")' versions.json)"
	eval "set -- $versions"
fi

# sort version numbers with highest first
IFS=$'\n'; set -- $(sort -rV <<<"$*"); unset IFS

# get the most recent commit which modified any of "$@"
fileCommit() {
	git log -1 --format='format:%H' HEAD -- "$@"
}

# get the most recent commit which modified "$1/Dockerfile" or any file COPY'd from "$1/Dockerfile"
dirCommit() {
	local dir="$1"; shift
	(
		cd "$dir"
		files="$(
			git show HEAD:./Dockerfile \
				| awk '
					toupper($1) == "COPY" {
						for (i = 2; i < NF; i++) {
							if ($i ~ /^--from=/) {
								next
							}
							print $i
						}
					}
					'
			 )"
		fileCommit Dockerfile $files
	)
}

getArches() {
	# exclude this image (e.g., oneself) from the architecture lookup
	local repo="$1"; shift
	# search this place for information on parent images
	local officialImagesUrl='https://github.com/docker-library/official-images/raw/master/library/'

	# loop through the generated Dockerfiles and grab the list of
	# suported hardware architectures of the parent image (excluding
	# 'scratch' and $repo)
	eval "declare -g -A parentRepoToArches=(
		$(
			find -name 'Dockerfile' -exec awk '
				toupper($1) == "FROM" && $2 !~ /^('"$repo"'|scratch|.*\/.*)(:|$)/ {
					print "'"$officialImagesUrl"'" $2
				}
				' '{}' + \
				| sort -u \
				| xargs bashbrew cat --format '[{{ .RepoName }}:{{ .TagName }}]="{{ join " " .TagEntry.Architectures }}"'
		)
	)"
}
getArches 'satosa'

cat <<-EOH
# This file is generated via https://github.com/IdentityPython/satosa-docker/blob/$(fileCommit "$self")/$self

Maintainers: Matthew X. Economou <economoum@niaid.nih.gov> (@niheconomoum)
GitRepo: https://github.com/IdentityPython/satosa-docker.git
GitFetch: refs/heads/main
EOH

# prints "$2$1$3$1...$N"
join() {
	local sep="$1"; shift
	local out; printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

for version; do
	export version
	variants="$(jq -r '.[env.version].variants | map(@sh) | join(" ")' versions.json)"
	eval "variants=( $variants )"

	fullVersion="$(jq -r '.[env.version].version' versions.json)"

	versionAliases=(
		$fullVersion
		$version
		${aliases[$version]:-}
	)

	defaultDebianVariant="$(jq -r '
				.[env.version].variants
				| map(select(
						startswith("alpine")
						or startswith("slim-")
						| not
				))
				| .[0]
		' versions.json)"
	defaultAlpineVariant="$(jq -r '
				.[env.version].variants
				| map(select(
						startswith("alpine")
				))
				| .[0]
		' versions.json)"

	for v in "${variants[@]}"; do
		dir="$version/$v"
		[ -f "$dir/Dockerfile" ] || continue
		variant="$(basename "$v")"

		commit="$(dirCommit "$dir")"

		variantAliases=( "${versionAliases[@]/%/-$variant}" )
		case "$variant" in
			*-"$defaultDebianVariant") # slim-xxx -> slim
				variantAliases+=( "${versionAliases[@]/%/-${variant%-$defaultDebianVariant}}" )
				;;
			"$defaultAlpineVariant")
				variantAliases+=( "${versionAliases[@]/%/-alpine}" )
				;;
		esac
		variantAliases=( "${variantAliases[@]//latest-/}" )

		case "$v" in
			windows/*)
				variantArches='windows-amd64'
				;;

			*)
				variantParent="$(awk 'toupper($1) == "FROM" { print $2 }' "$dir/Dockerfile")"
				variantArches="${parentRepoToArches[$variantParent]}"
				;;
		esac

		case "$v" in
			alpine*)
				# https://github.com/IdentityPython/satosa-docker/issues/1
				variantArches="$(sed <<<" $variantArches " -e 's/ s390x / /g')"
				;;
		esac

		sharedTags=()
		for windowsShared in windowsservercore nanoserver; do
			if [[ "$variant" == "$windowsShared"* ]]; then
				sharedTags=( "${versionAliases[@]/%/-$windowsShared}" )
				sharedTags=( "${sharedTags[@]//latest-/}" )
				break
			fi
		done

		if [ "$variant" = "$defaultDebianVariant" ] || [[ "$variant" == 'windowsservercore'* ]]; then
			sharedTags+=( "${versionAliases[@]}" )
		fi

		echo
		echo "Tags: $(join ', ' "${variantAliases[@]}")"
		if [ "${#sharedTags[@]}" -gt 0 ]; then
			echo "SharedTags: $(join ', ' "${sharedTags[@]}")"
		fi
		cat <<-EOE
			Architectures: $(join ', ' $variantArches)
			GitCommit: $commit
			Directory: $dir
		EOE
		if [[ "$v" == windows/* ]]; then
			echo "Constraints: $variant"
		fi
	done
done
