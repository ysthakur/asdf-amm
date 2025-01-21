#!/usr/bin/env bash

set -euo pipefail

OWNER="com-lihaoyi"
REPO="Ammonite"
GH_REPO="https://github.com/$OWNER/$REPO"
TOOL_NAME="amm"
TOOL_TEST="amm --version"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: Bearer $GITHUB_API_TOKEN")
fi

sort_versions() {
	# Use - as the delimiter everywhere for sort
	awk -F '[-.]' '{ print $1 "-" $2 "-" $3 "-" $4 "-" $5 }' |
		LC_ALL=C sort -t'-' -k 3,3n -k 4,4n -k 5,5n -k 1,1n -k 2,2n |
		# Put the delimiters back
		awk -F '-' '{ print $1 "." $2 "-" $3 "." $4 "." $5 }' |
		uniq
}

# Make a query to the GitHub API
gh_query() {
	local url_rest="$1"
	curl "${curl_opts[@]}" \
		-H "Accept: application/vnd.github+json" \
		-H "X-GitHub-Api-Version: 2022-11-28" \
		"https://api.github.com/repos/$OWNER/$REPO/$url_rest" || fail "Could not curl $url_rest"
}

# Get the names of assets from stable releases
# Accepts the output of `gh_query releases` as input.
# The releases response also includes all the assets, so we can just use that
# instead of querying the assets for each release separately
filter_stable_versions() {
	# Must not be an M0 version
	grep -oE '"name": "[0-9]+\.[0-9]+-[0-9]+\.[0-9]+\.[0-9]+"' |
		# Extract the asset names
		cut -d '"' -f 4 |
		sort_versions
}

# Get names of assets from unstable releases
# Accepts output of `gh_query "releases"` as input
filter_unstable_assets() {
	grep -oE '"name": "[0-9]+\.[0-9]+-[0-9]+\.[0-9]+\.[0-9]+-[0-9]+-[a-z0-9]+"' |
		# Extract the asset names
		cut -d '"' -f 4
}

# Get latest Ammonite tag (e.g., 3.0.0)
# Accepts output of `gh_query "releases"` as input
latest_tag() {
	grep -oE '"name": "[0-9]+\.[0-9]\.+[0-9]+"' |
		cut -d '"' -f 4 |
		sort -t'.' -k 1,1n -k 2,2n -k 3,3n |
		tail -n 1
}

# Accepts output of `gh_query "releases"` as input
list_all_unstable_versions() {
	filter_unstable_assets |
		cut -d '"' -f 1,2 |
		sort_versions
}

download_release() {
	local version filename tag url latest
	version="$1"
	filename="$2"
	# The Ammonite version is <Scala version>-<Ammonite tag>
	tag=$(cut -d "-" -f 2 <<<"$version")

	releases=$(gh_query "releases")

	if [[ $releases =~ "\"$version\"" ]]; then
		url="$GH_REPO/releases/download/$tag/$version"
	else
		latest=$(
			echo $releases |
				filter_unstable_assets |
				grep $version |
				sort -t'-' -k 3,3n -k 4,4 |
				tail -n 1
		)
		url="$GH_REPO/releases/download/$tag/$latest"
	fi

	echo "* Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" \
		-H "Accept: application/octet-stream" \
		-o "$filename" -C - "$url" ||
		fail "Could not curl $url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

		[ -f /etc/resolv.conf ] || fail "$TOOL_NAME executable does not exist"
		chmod +x "$install_path/$TOOL_NAME"

		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
