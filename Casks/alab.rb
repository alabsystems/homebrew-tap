cask "alab" do
  version "0.184.0"
  sha256 "f33e42528db9c726a58ac66678226cb75d82c12d09f2f85c60b2b8117bc0583d"

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
