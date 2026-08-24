# How we make and maintain the aterm Homebrew cask

## Where this lives

The **source of truth for the tap's structure** (cask stanzas, workflow, docs)
is `distribution/homebrew-tap/` in the private aterm dev repo — edit there,
ship through review like any other change, then copy the tree into
`alabsystems/homebrew-tap`. The public tap repo self-maintains only the
*version/sha256 bumps* (`bump.yml`); structural edits made directly in the tap
repo will be silently clobbered by the next copy-over.

Two casks, one artifact: `aterm` is canonical; `alab` installs the same zip
(aterm is ALab's front door and casks have no alias mechanism) and conflicts
with `aterm` so nobody double-installs. Every structural rule below applies to
both files.

## One-time setup (human)

1. Create the **public** repo `alabsystems/homebrew-tap` (the `homebrew-` prefix
   is what makes `brew tap alabsystems/tap` resolve to it; taps must be public).
2. Push these files to `main`. No release, no build — a tap is just files.
3. Test end to end:

   ```sh
   brew tap alabsystems/tap
   brew install --cask aterm
   ```

   Confirm `aterm.app` lands in `/Applications` and launches without Gatekeeper
   friction (it should — the zip contains the Developer-ID-signed and notarized
   app, team `A66A9P66Z7`).
4. Nothing to configure for automation: `bump.yml` uses the workflow's own
   `GITHUB_TOKEN` with `contents: write` — no PAT, no secrets. If the repo has
   branch protection on `main`, exempt the workflow or the bump commits will be
   rejected.

### Later, optional: submit to homebrew-cask mainline

Submitting `aterm.rb` to `Homebrew/homebrew-cask` lets users skip the tap
(`brew install --cask aterm`) and reserves the name. Two things to know:

- **Notability**: mainline has acceptance criteria (GitHub stars / download
  counts / general notability). If aterm doesn't clear the bar yet, stay on the
  tap and resubmit later; the tap keeps working regardless.
- **Asset size matters**: the cask points at the 26 MB `aterm-VERSION-mac.zip`,
  not the 1.1 GB DMG. That is what makes the cask acceptable — CI on
  homebrew-cask downloads and installs every submission, and a gigabyte-scale
  artifact would be rejected (and would make every user's install miserable).
  Keep publishing the small zip as a release asset forever.

## Steady state

- **Releases**: nothing to do. The bump workflow polls every 6 hours, ignores
  `atpkg-index-*` releases and the unreliable `latest` pointer, takes the
  numerically greatest `vX.Y.0` tag that carries both the mac zip and
  `aterm-appcast.toml`, cross-checks the appcast's `zip_sha256` against a fresh
  hash of the downloaded zip, and commits the bump to `main`. A hash mismatch
  fails the run loudly instead of shipping a bad cask.
- **If a release changes asset naming** (`aterm-VERSION-mac.zip` or
  `aterm-appcast.toml`): the workflow simply stops seeing new releases — it
  fails safe by doing nothing. Update the asset-name patterns in
  `.github/workflows/bump.yml` *and* the `url` in `Casks/aterm.rb` together,
  and check the `zip_sha256` key name if the appcast schema changed.
- **If automation is down**: three-command manual bump in README.md.
- **Style**: after hand-editing the cask, run
  `brew style --cask Casks/aterm.rb` from inside the tapped checkout.

## Future: push instead of poll

`aterm ship` (the release command in the aterm repo) could fire a
`repository_dispatch` event at this repo the moment a release is published:

```sh
gh api repos/alabsystems/homebrew-tap/dispatches \
  -f event_type=aterm-release -f 'client_payload[version]=X.Y.0'
```

Add `repository_dispatch: { types: [aterm-release] }` to `bump.yml`'s `on:`
block and the same job handles it — the bump lands in seconds instead of up to
six hours, and the schedule stays on as a backstop. Requires a token with write
access to this repo in the ship environment, which is why polling is the
default today.
