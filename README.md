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

`pub tap`, run by a person from the publication engine. There is deliberately
**no GitHub Actions workflow** here — no `.github/`, nothing scheduled, nothing
on GitHub.

```sh
pub tap          # what this tap serves vs the newest eligible aterm release
pub tap --bump   # verify, rewrite both casks, push
```

`--bump` refuses unless THREE independent sources agree on the zip's sha256:
`zip_sha256` in the release's `aterm-appcast.toml`, the
`aterm-VERSION-mac.zip.sha256` sidecar, and `shasum -a 256` of the zip it
actually downloaded. It selects the numerically greatest tag matching
`^v[0-9]+\.[0-9]+\.0$` whose assets include both `aterm-VERSION-mac.zip` and
`aterm-appcast.toml` (`atpkg-index-*` releases and the unreliable `latest`
pointer are never selected), and rewrites `version` and `sha256` in
`Casks/aterm.rb` AND `Casks/alab.rb` together, since both pin the same zip.

A cask whose `sha256` does not match the artifact tells every `brew install`
that the download was corrupted, so a mismatch is a refusal, not a warning.

If this tap ever looks stale, run `pub tap`: it exits non-zero and says how far
behind the casks are. That check has to be RUN — a tap is just files, so a stale
one looks exactly like a current one.

## Manual bump (when `pub tap` is unavailable)

```sh
curl -fsSLO https://github.com/alabsystems/aterm/releases/download/vNEW/aterm-NEW-mac.zip
shasum -a 256 aterm-NEW-mac.zip   # put this hash and NEW into Casks/aterm.rb
git commit -am "aterm OLD -> NEW" && git push
```
