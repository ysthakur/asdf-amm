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
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

# Make a query to the GitHub API
gh_query() {
  local url="$1"
  curl "${curl_opts[@]}" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/$OWNER/$REPO/$url"
}

# Argument is the key whose value to get, JSON is gotten from stdin
get_str_value_from_json() {
  grep -Po "(?<=\"$1\":)\s*\".*?\"" | cut -d '"' -f 2
}

get_num_value_from_json() {
  grep -Po "(?<=\"$1\":)\s\d+" | sed "s/^ \+//g" # Trim whitespace
}

# Get the tag names from a list of releases (or a single release) provided by
# the GitHub API. Reads from stdin.
tag_names() {
  get_str_value_from_json "tag_name"
}

list_github_tags() {
  gh_query "releases" | tag_names
}

# Given a tag, list its scala-ammonite versions
list_assets() {
  local tag="$1"
  local id=$(gh_query "releases/tags/$tag" | get_num_value_from_json "id" | head -n 1)
  gh_query "releases/$id/assets" | get_str_value_from_json "name" | cut -d '-' -f 1,2
}

list_all_versions() {
  # While loop from https://superuser.com/a/284226
  while IFS= read tag || [[ -n $tag ]]; do
    list_assets "$tag"
  done < <(list_github_tags)
}

# The Ammonite version is <scala-version>-<ammonite tag>
tag_from_version() {
  cut -d "-" -f 2 <<< "$1"
}

download_release() {
  local version filename url
  version="$1"
  filename="$2"

  # TODO: Adapt the release URL convention for amm
  url="$GH_REPO/archive/${tag_from_version version}.tar.gz"

  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
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

    # TODO: Assert amm executable exists.
    local tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
    test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error occurred while installing $TOOL_NAME $version."
  )
}
