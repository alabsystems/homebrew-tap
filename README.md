# alabsystems/homebrew-tap

Homebrew tap for [aterm](https://alab.systems) — batteries-included terminal for AI.

## Install

```sh
brew install --cask alabsystems/tap/aterm
```

This installs `aterm.app` (Developer-ID-signed and notarized) into `/Applications`.
Requires macOS 11.0 (Big Sur) or later.

`brew install --cask alabsystems/tap/alab` works too and installs the same app —
aterm is ALab's front door, and the toolchain is one
`aterm pkg install --default-set` away. Install one or the other, not both
(the casks conflict on purpose).

## Updates

aterm has its own in-app self-updater, and the cask declares `auto_updates true`
so Homebrew won't fight it: `brew upgrade` skips aterm by default (use
`brew upgrade --cask aterm --greedy` if you insist on updating via brew).

## How this tap stays current

`.github/workflows/bump.yml` runs every 6 hours (and on manual dispatch). It:

1. queries the `alabsystems/aterm` releases API anonymously,
2. picks the numerically greatest tag matching `^v[0-9]+\.[0-9]+\.0$` whose
   assets include both `aterm-VERSION-mac.zip` and `aterm-appcast.toml`
   (`atpkg-index-*` releases and the unreliable `latest` pointer are ignored),
3. verifies the appcast's `zip_sha256` against a fresh hash of the downloaded
   zip (the run fails on mismatch),
4. rewrites `version` and `sha256` in `Casks/aterm.rb` AND `Casks/alab.rb`
   (both pin the same zip) and commits to `main`.

## Manual bump (when automation is down)

```sh
curl -fsSLO https://github.com/alabsystems/aterm/releases/download/vNEW/aterm-NEW-mac.zip
shasum -a 256 aterm-NEW-mac.zip   # put this hash and NEW into Casks/aterm.rb
git commit -am "aterm OLD -> NEW" && git push
```
