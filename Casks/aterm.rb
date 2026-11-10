cask "aterm" do
  version "0.191.0"
  sha256 "f6970fcc6ec34ea8cdce40db66619f5d582ef0b7ab78c4b28ea12bc99c146a4c"

  url "https://github.com/alabsystems/aterm/releases/download/v#{version}/aterm-#{version}-mac.zip"
  name "aterm"
  desc "Batteries-included terminal for AI"
  homepage "https://alab.systems/"

  # App releases are tagged vMAJOR.MINOR.0; `atpkg-index-N` releases interleave
  # in the same repo and the `latest` release pointer is unreliable, so we scan
  # all releases and match only version tags.
  livecheck do
    url :url
    regex(/^v(\d+\.\d+\.0)$/i)
    strategy :github_releases do |json, regex|
      json.filter_map do |release|
        next if release["draft"] || release["prerelease"]

        release["tag_name"]&.[](regex, 1)
      end
    end
  end

  auto_updates true
  depends_on macos: :big_sur

  app "aterm.app"

  zap trash: [
    "~/Library/Application Support/aterm",
    "~/Library/Caches/aterm",
  ]
end
