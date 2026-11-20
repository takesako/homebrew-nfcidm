#!/usr/bin/env bash
# Update the Homebrew formula to a GitHub tag archive.
# Usage: ./scripts/update-formula.sh 0.5.5
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: ${0} VERSION (e.g. 0.5.5)" >&2
  exit 2
fi

version="${1#v}"
if [[ ! "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid version: ${1}" >&2
  exit 2
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
formula="${repo_dir}/Formula/nfcidm.rb"
if [[ ! -f "${formula}" ]]; then
  echo "Formula not found: ${formula}" >&2
  exit 1
fi

url="https://github.com/takesako/nfcidm/archive/refs/tags/v${version}.tar.gz"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

echo "Downloading ${url}"
curl --fail --location --silent --show-error --retry 3 \
  --output "${tmp_dir}/source.tar.gz" "${url}"

if command -v shasum >/dev/null 2>&1; then
  sha="$(shasum -a 256 "${tmp_dir}/source.tar.gz" | awk '{print $1}')"
elif command -v sha256sum >/dev/null 2>&1; then
  sha="$(sha256sum "${tmp_dir}/source.tar.gz" | awk '{print $1}')"
else
  echo "Neither shasum nor sha256sum is installed" >&2
  exit 1
fi

# Update only the source URL and source SHA-256; preserve bottle hashes.
# The explicit version is unnecessary because Homebrew parses the URL.
awk -v new_url="${url}" -v new_sha="${sha}" '
  /^[[:space:]]*url[[:space:]]+"/ && !seen_url {
    sub(/url[[:space:]]+"[^"]*"/, "url \"" new_url "\"")
    seen_url = 1
    print
    next
  }
  /^[[:space:]]*sha256[[:space:]]+"/ && !seen_sha {
    sub(/sha256[[:space:]]+"[^"]*"/, "sha256 \"" new_sha "\"")
    seen_sha = 1
    print
    next
  }
  /^[[:space:]]*version[[:space:]]+"[^"]*"[[:space:]]*$/ && !seen_version {
    seen_version = 1
    next
  }
  { print }
  END {
    if (!seen_url || !seen_sha) {
      print "Could not find source url and sha256 in Formula" > "/dev/stderr"
      exit 1
    }
  }
' "${formula}" > "${tmp_dir}/nfcidm.rb"

mv "${tmp_dir}/nfcidm.rb" "${formula}"
echo "Updated Formula/nfcidm.rb: v${version}"
echo "SHA-256: ${sha}"

if command -v git >/dev/null 2>&1 && git -C "${repo_dir}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "${repo_dir}" diff --check -- Formula/nfcidm.rb
  git -C "${repo_dir}" diff -- Formula/nfcidm.rb || true
fi
