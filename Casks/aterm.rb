cask "aterm" do
  version "0.200.0"
  sha256 "96e4776b2e948128015cf6891fbcb8c16277c7442dfaf03b79da4777908c0ec2"

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
