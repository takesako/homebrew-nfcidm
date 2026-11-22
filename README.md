# Homebrew Tap for nfcidm

Homebrew formula and prebuilt macOS bottles for [nfcidm](https://github.com/takesako/nfcidm), a command-line utility that reads FeliCa IDm values from supported NFC readers.

## Install

```sh
brew tap takesako/nfcidm
brew trust --tap takesako/nfcidm
brew install --force-bottle takesako/nfcidm/nfcidm
```

`brew trust --tap` trusts all current and future formulae and commands in this third-party tap. `--force-bottle` requires a compatible prebuilt bottle; it does not fall back to building from source.

## Usage

```sh
nfcidm --version
nfcidm --list
nfcidm
```

For supported readers and platform-specific instructions, see the [nfcidm source repository](https://github.com/takesako/nfcidm).

## Maintainer guide: releasing a new version

The application source and release tags live in [takesako/nfcidm](https://github.com/takesako/nfcidm). This tap contains `Formula/nfcidm.rb`, `scripts/update-formula.sh`, and GitHub Actions workflows for building and publishing macOS bottles.

### 1. Publish the upstream release

Release and tag the new version in the source repository *before* updating this tap. The formula uses the GitHub-generated tag archive, not a separately uploaded tarball. For example:

```sh
VERSION=0.5.6  # replace with the next release version
gh release view "v${VERSION}" -R takesako/nfcidm
```

Never move an existing release tag. If the source changes after publication, release a new version.

### 2. Update the formula in a clean branch

In a local clone of `takesako/homebrew-nfcidm`:

```sh
git fetch origin
git switch main
git pull --ff-only
git switch -c "nfcidm-${VERSION}"

bash scripts/update-formula.sh "${VERSION}"
brew style Formula/nfcidm.rb
git diff --check
git diff -- Formula/nfcidm.rb
```

The script downloads the published tag archive, calculates its SHA-256 checksum, and updates the formula's `url` and `sha256`. Do not calculate the checksum from a locally generated archive. The publishing workflow handles bottle checksums.

### 3. Push and create a pull request

```sh
git add Formula/nfcidm.rb
git commit -m "nfcidm ${VERSION}"
git log --oneline origin/main..HEAD
git push -u origin "nfcidm-${VERSION}"

gh pr create \
  --base main \
  --head "nfcidm-${VERSION}" \
  --title "nfcidm ${VERSION}" \
  --body "Update nfcidm to v${VERSION}."
```

Check that `git log --oneline origin/main..HEAD` contains **only commits intended for this release**. In particular, do not carry commits from an older, already integrated PR into the new branch: `brew pr-pull` cherry-picks the PR commits onto `main` and can fail on an already-applied (empty) cherry-pick.

If a PR already exists for the version, update that PR's branch rather than opening a duplicate.

### 4. Check CI and bottle artifacts

```sh
PR=$(gh pr view --json number --jq .number)
gh pr checks "$PR" --watch
```

Ensure that the `tests.yml` jobs for macOS 15 and macOS 26 pass **and** upload their bottle artifacts (currently `bottles_macos-15` and `bottles_macos-26`). Green checks alone do not prove that the required artifacts are available.

To inspect the artifacts, find the latest PR test run ID and query its artifacts:

```sh
gh run list --workflow tests.yml --event pull_request --limit 10
CI_RUN_ID=<run-id>
gh api "repos/takesako/homebrew-nfcidm/actions/runs/${CI_RUN_ID}/artifacts" \
  --jq '.artifacts[].name'
```

Do **not** merge the PR manually before bottle publication.

### 5. Publish the formula and bottles

Once both bottle jobs have succeeded, run `publish.yml` from `main` using the PR's **current** head SHA:

```sh
SHA=$(gh pr view "$PR" --json headRefOid --jq .headRefOid)

gh workflow run publish.yml \
  --ref main \
  -f pull_request="$PR" \
  -f head_sha="$SHA"

gh run list --workflow publish.yml --limit 5
```

Watch the new publishing run with `gh run watch <publish-run-id> --exit-status`. The workflow invokes `brew pr-pull` to import and publish the bottles and integrate the formula changes. Verify both the workflow result and the repository's `main` branch; do not assume publication succeeded merely because the workflow was started.

### 6. Verify the release

```sh
gh pr view "$PR" --json state,mergedAt
brew update
brew info takesako/nfcidm/nfcidm
```

Confirm that `brew info` shows the newly published version. For a fresh installation, use the commands in [Install](#install). For an existing installation, run:

```sh
brew upgrade --force-bottle takesako/nfcidm/nfcidm
nfcidm --version
```

### Troubleshooting publication

- **`The previous cherry-pick is now empty`**: The PR branch contains a commit already applied to `main`. Rebase the unpublished branch onto the latest `origin/main`, verify that only the intended release commits remain, and update the PR. Re-run CI and publish using the new head SHA:

  ```sh
  git fetch origin
  git switch "nfcidm-${VERSION}"
  git rebase origin/main
  git log --oneline origin/main..HEAD
  git push --force-with-lease origin "nfcidm-${VERSION}"
  gh pr checks "$PR" --watch
  ```

- **`No artifacts with pattern bottles{,_*} found`**: Verify that the latest CI run for the *current PR SHA* produced both bottle artifacts. Do not reuse artifacts from an older PR commit.
- **Missing bottle for this macOS version or architecture**: `--force-bottle` intentionally fails rather than building from source. Check the formula's published bottle definitions and the supported runners.

## References

- [nfcidm source repository](https://github.com/takesako/nfcidm)
- [Homebrew: How to Create and Maintain a Tap](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)
- [Homebrew: Tap Trust](https://docs.brew.sh/Tap-Trust)
