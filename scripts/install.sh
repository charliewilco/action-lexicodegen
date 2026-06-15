#!/usr/bin/env bash
set -euo pipefail

repo="charliewilco/Lexicodegen"
requested_version="${INPUT_VERSION:-latest}"
install_dir="${INPUT_INSTALL_DIR:-${RUNNER_TEMP:-/tmp}/lexicodegen}"
github_token="${INPUT_GITHUB_TOKEN:-}"
verify="${INPUT_VERIFY:-true}"

curl_headers=(-H "Accept: application/vnd.github+json")
if [[ -n "$github_token" ]]; then
	curl_headers+=(-H "Authorization: Bearer $github_token")
fi

case "${RUNNER_OS:-$(uname -s)}" in
	Linux | linux)
		os="linux"
		;;
	macOS | Darwin | darwin)
		os="darwin"
		;;
	*)
		echo "Unsupported runner OS: ${RUNNER_OS:-$(uname -s)}" >&2
		exit 1
		;;
esac

case "${RUNNER_ARCH:-$(uname -m)}" in
	X64 | x86_64 | amd64)
		arch="amd64"
		;;
	ARM64 | arm64 | aarch64)
		arch="arm64"
		;;
	*)
		echo "Unsupported runner architecture: ${RUNNER_ARCH:-$(uname -m)}" >&2
		exit 1
		;;
esac

resolve_latest_tag() {
	local response
	response="$(curl -fsSL "${curl_headers[@]}" "https://api.github.com/repos/${repo}/releases/latest")"
	printf "%s\n" "$response" | sed -n 's/^[[:space:]]*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1
}

if [[ "$requested_version" == "latest" ]]; then
	tag="$(resolve_latest_tag)"
	if [[ -z "$tag" ]]; then
		echo "Could not resolve latest lexicodegen release tag." >&2
		exit 1
	fi
elif [[ "$requested_version" == v* ]]; then
	tag="$requested_version"
else
	tag="v${requested_version}"
fi

version="${tag#v}"
asset="lexicodegen_${version}_${os}_${arch}.tar.gz"
download_base="https://github.com/${repo}/releases/download/${tag}"

tmp_dir="$(mktemp -d)"
cleanup() {
	rm -rf "$tmp_dir"
}
trap cleanup EXIT

echo "Installing lexicodegen ${tag} for ${os}/${arch}"
curl -fsSL "${curl_headers[@]}" -o "${tmp_dir}/${asset}" "${download_base}/${asset}"
curl -fsSL "${curl_headers[@]}" -o "${tmp_dir}/checksums.txt" "${download_base}/checksums.txt"

(
	cd "$tmp_dir"
	shasum -a 256 -c checksums.txt --ignore-missing
)

mkdir -p "$install_dir"
tar -xzf "${tmp_dir}/${asset}" -C "$install_dir" lexicodegen
chmod +x "${install_dir}/lexicodegen"

if [[ -n "${GITHUB_PATH:-}" ]]; then
	echo "$install_dir" >> "$GITHUB_PATH"
fi

version_output="$("${install_dir}/lexicodegen" --version)"
if [[ "$verify" == "true" ]]; then
	echo "$version_output"
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
	echo "path=${install_dir}/lexicodegen" >> "$GITHUB_OUTPUT"
	echo "version=${version_output}" >> "$GITHUB_OUTPUT"
fi
