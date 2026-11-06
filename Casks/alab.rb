cask "alab" do
  version "0.158.0"
  sha256 "8e80b461af1cf5919e7a3eceff5bb1991a8bb452bbd2ae96b7baa4685d2a0488"

  url "https://github.com/alabsystems/aterm/releases/download/v#{version}/aterm-#{version}-mac.zip"
  name "ALab"
  desc "Verification toolchain and AI terminal from ALab"
  homepage "https://alab.systems/"

  # Same artifact as the `aterm` cask on purpose: aterm IS ALab's front door —
  # the toolchain is one `aterm pkg install --default-set` away, and `brew
  # install alab` should land people there. Casks have no alias mechanism, so
  # this is a real cask; the conflict keeps the two from double-installing.
  livecheck do
    cask "aterm"
  end

  auto_updates true
  conflicts_with cask: "aterm"
  depends_on macos: :big_sur

  app "aterm.app"

  zap trash: [
    "~/Library/Application Support/aterm",
    "~/Library/Caches/aterm",
  ]
end
