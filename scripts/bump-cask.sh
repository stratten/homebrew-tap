#!/usr/bin/env bash
# Updates Casks/basil.rb to the latest stable Basil release, but only after the release checks out.
#
# It reads the latest stable release (never a pre-release), downloads Basil.dmg and SHA256SUMS.txt, confirms the
# DMG matches the published checksum, confirms the build-provenance attestation names the Basil repository's own
# validate.yml workflow, and only then rewrites the version and sha256 lines. It never moves the cask backward.
#
# Requires the GitHub CLI (gh) with a token in GH_TOKEN, plus ruby. When run by the workflow it writes
# "version=<new version>" to $GITHUB_OUTPUT if the cask changed.

set -euo pipefail

readonly SOURCE_REPO="stratten/Basil_OS"
readonly SIGNER_WORKFLOW="${SOURCE_REPO}/.github/workflows/validate.yml"

cd "$(dirname "${BASH_SOURCE[0]}")/.."
readonly CASK="Casks/basil.rb"

fail() { printf 'bump-cask: %s\n' "$*" >&2; exit 1; }

sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{ print $1 }'
    else
        shasum -a 256 "$1" | awk '{ print $1 }'
    fi
}

tag="$(gh api "repos/${SOURCE_REPO}/releases/latest" --jq .tag_name)"
[[ "$tag" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)$ ]] || fail "The latest release tag '$tag' is not a plain vX.Y.Z version."
version="${BASH_REMATCH[1]}"

current="$(sed -n 's/^  version "\(.*\)"$/\1/p' "$CASK")"
[[ -n "$current" ]] || fail "Could not read the current version from $CASK."

if [[ "$current" == "$version" ]]; then
    echo "The cask is already at the latest stable release, $version."
    exit 0
fi

newest="$(printf '%s\n%s\n' "$current" "$version" | sort -V | tail -n 1)"
if [[ "$newest" != "$version" ]]; then
    echo "The latest stable release, $version, is older than the cask's $current. Leaving the cask alone."
    exit 0
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "Downloading Basil $version to verify it..."
gh release download "$tag" --repo "$SOURCE_REPO" --pattern Basil.dmg --pattern SHA256SUMS.txt --dir "$work"

expected="$(awk '$2 == "Basil.dmg" { print $1 }' "$work/SHA256SUMS.txt" | head -n 1)"
[[ "$expected" =~ ^[0-9a-f]{64}$ ]] || fail "SHA256SUMS.txt has no valid checksum for Basil.dmg."
actual="$(sha256_of "$work/Basil.dmg")"
[[ "$expected" == "$actual" ]] || fail "Basil.dmg does not match SHA256SUMS.txt (expected $expected, got $actual)."

echo "Verifying the build-provenance attestation..."
gh attestation verify "$work/Basil.dmg" --repo "$SOURCE_REPO" --signer-workflow "$SIGNER_WORKFLOW" >/dev/null \
    || fail "The attestation for Basil.dmg did not verify."

sed -i.bak -e "s/^  version \".*\"\$/  version \"${version}\"/" -e "s/^  sha256 \".*\"\$/  sha256 \"${actual}\"/" "$CASK"
rm -f "$CASK.bak"
ruby -c "$CASK" >/dev/null || fail "The rewritten cask is not valid Ruby."

echo "Bumped the cask from $current to $version."
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    echo "version=${version}" >> "$GITHUB_OUTPUT"
fi
