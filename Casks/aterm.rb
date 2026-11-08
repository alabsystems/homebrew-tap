cask "aterm" do
  version "0.171.0"
  sha256 "f3d594b876b5c2957db4a4466f6c9f3c912ed39fdad62f02aff86a958a2e5f9c"

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
