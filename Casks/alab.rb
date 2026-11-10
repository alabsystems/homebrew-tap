cask "alab" do
  version "0.193.0"
  sha256 "4a1d9128c8e95b33ee4c7580dc5262084bf0c32ce0dd1c49bf31ff30105f6ec3"

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
