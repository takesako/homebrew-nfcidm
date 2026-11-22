# Homebrew Tap for nfcidm

Homebrew formula and prebuilt macOS bottles for [nfcidm](https://github.com/takesako/nfcidm), a command-line utility that reads FeliCa IDm values from supported NFC readers.

## Install

```sh
brew tap takesako/nfcidm
brew trust --tap takesako/nfcidm
brew install --force-bottle takesako/nfcidm/nfcidm
```

The `brew trust --tap` command trusts all formulae and commands in this third-party tap. The `--force-bottle` option requires a compatible prebuilt bottle.

## Usage

```sh
nfcidm --version
nfcidm --list
nfcidm
```

For supported devices and other platforms, see the [nfcidm source repository](https://github.com/takesako/nfcidm).

## Maintainer guide: updating nfcidm

This repository contains the Homebrew formula (`Formula/nfcidm.rb`), its update script (`scripts/update-formula.sh`), and GitHub Actions for building and publishing bottles. Application source code and release tags are maintained separately in [takesako/nfcidm](https://github.com/takesako/nfcidm).

### 1. Publish the upstream release first

Commit and tag the new version in `takesako/nfcidm`, then publish its GitHub Release. The formula uses the automatically generated GitHub tag archive rather than a manually uploaded source tarball.

Set the version for this release (example: `0.5.5`) and verify that it is publicly available:

```sh
VERSION=0.5.5
gh release view "v${VERSION}" -R takesako/nfcidm
```

Do not move or reuse a published release tag. If a version has already been released with different source contents, increment the version instead.

### 2. Update the formula in a branch

From a local clone of this tap:

```sh
git switch main
git pull --ff-only
git switch -c "nfcidm-${VERSION}"

bash scripts/update-formula.sh "${VERSION}"
brew style Formula/nfcidm.rb
git diff --check
git diff -- Formula/nfcidm.rb
```

The update script downloads the GitHub tag archive for the chosen version, computes its SHA-256 checksum, and updates the source `url` and `sha256` in `Formula/nfcidm.rb`.

Do not copy the checksum from a locally generated archive. Bottle checksums are managed by the publishing workflow.

### 3. Push and open a pull request

```sh
git add Formula/nfcidm.rb
git commit -m "nfcidm ${VERSION}"
git push -u origin "nfcidm-${VERSION}"

gh pr create \
  --base main \
  --head "nfcidm-${VERSION}" \
  --title "nfcidm ${VERSION}" \
  --body "Update nfcidm to v${VERSION}."
```

If an existing open pull request already updates this release, push changes to that branch instead of creating a duplicate PR.

### 4. Wait for CI and bottle artifacts

The `tests.yml` workflow checks tap syntax and tests formula builds on the configured macOS runners.

Confirm that the macOS 15 and macOS 26 jobs pass and that their bottle artifacts (`bottles_macos-15` and `bottles_macos-26`) have been uploaded.

```sh
PR=$(gh pr view --json number --jq .number)
gh pr checks "$PR" --watch
```

**Do not merge the pull request manually before publishing the bottles.** The publishing workflow uses the PR and its CI artifacts together.

### 5. Publish the formula and bottles

After CI succeeds, run the `publish.yml` workflow from the tap's `main` branch. Pin it to the reviewed PR head commit:

```sh
SHA=$(gh pr view "$PR" --json headRefOid --jq .headRefOid)

gh workflow run publish.yml \
  --ref main \
  -f pull_request="$PR" \
  -f head_sha="$SHA"

gh run list --workflow publish.yml --limit 5
```

The workflow runs `brew pr-pull` to import the bottle artifacts, publish the updated formula, and complete the PR integration.

If it reports `No artifacts with pattern bottles{,_*} found`, ensure that all bottle-build jobs finished successfully and uploaded their artifacts before retrying.

### 6. Verify the published version

On a macOS machine with a compatible bottle:

```sh
brew update
brew install --force-bottle takesako/nfcidm/nfcidm
nfcidm --version
```

For new installations, use the three commands in [Install](#install).

If `brew install --force-bottle` fails because no bottle matches the local system, check the release's supported macOS versions and architectures and the published bottle artifacts.

## References

- [nfcidm source repository](https://github.com/takesako/nfcidm)
- [Homebrew: How to Create and Maintain a Tap](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)
- [Homebrew: Tap Trust](https://docs.brew.sh/Tap-Trust)
