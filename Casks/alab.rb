cask "alab" do
  version "0.173.0"
  sha256 "20ede2fe8daea2bb06ef3e6b24fea239759c0c172435f2038dc7e86119b34f8e"

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
