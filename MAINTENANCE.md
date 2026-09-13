# How we make and maintain the aterm Homebrew cask

## Where this lives

The **source of truth for the tap's structure** (cask stanzas, docs)
is `distribution/homebrew-tap/` in the private aterm dev repo — edit there,
ship through review like any other change, then copy the tree into
`alabsystems/homebrew-tap`. The public tap repo carries NO automation: version/sha256 bumps are made by
`pub tap --bump` in the publication engine, by a person. Structural edits made
directly in the tap repo will be silently clobbered by the next copy-over.

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
4. Nothing to configure: `pub tap --bump` pushes with the operator's own
   credential. No Actions, no `GITHUB_TOKEN`, no secrets stored in this repo —
   GitHub Actions are excluded from this org by policy, and the machine
   credentials deliberately lack `workflow` permission.

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

- **Releases**: run `pub tap`. It reports what this tap serves against the
  newest eligible release and exits non-zero when the casks are behind;
  `pub tap --bump` lands it. The selection ignores `atpkg-index-*` releases and
  the unreliable `latest` pointer, takes the numerically greatest `vX.Y.0` tag
  carrying both the mac zip and `aterm-appcast.toml`, and cross-checks the
  zip's sha256 against THREE sources — the appcast's `zip_sha256`, the
  `.sha256` sidecar, and a local hash of the download. Any disagreement is a
  refusal, not a warning.
- **Nothing polls.** This is deliberate: a tap is just files, so a stale one is
  indistinguishable from a current one, and a scheduled job that quietly stops
  running looks exactly like one with nothing to do. This repo pinned aterm
  0.49.0 through v0.84.0 — 35 releases — while these docs described an automatic
  bump that had never been copied in. A check that must be RUN cannot fail that
  way unnoticed.
- **If a release changes asset naming** (`aterm-VERSION-mac.zip` or
  `aterm-appcast.toml`): `pub tap` stops seeing new releases and fails safe by
  doing nothing. Update the asset-name patterns in `bin/pub-tap` *and* the `url`
  in `Casks/aterm.rb` together, and check the `zip_sha256` key name if the
  appcast schema changed.
- **If `pub tap` is unavailable**: bump by hand per README.md — but never skip
  the sha256 cross-check.
- **Style**: after hand-editing the cask, run
  `brew style --cask Casks/aterm.rb` from inside the tapped checkout.

## Why not have the release trigger it

The obvious next step — `aterm ship` firing a `repository_dispatch` at this repo
so the bump lands in seconds — needs a workflow here to receive the event. There
will not be one. The release path already knows when it publishes, so if the gap
between a release and a tap bump ever matters, the fix is to call
`pub tap --bump` from the ship path directly, with the operator's credential and
the same three-way sha256 check. That keeps the verification and the authority in
one place a person can run and read, instead of in a scheduled job whose silence
means nothing in particular.
