cask "basil" do
  version "1.0.0"
  sha256 "d7d62d2abb3f8b32fcb3d4e682d14476fe0a977197d169e90768f349d208c5b5"

  url "https://github.com/stratten/Basil_OS/releases/download/v#{version}/Basil.dmg"
  name "Basil"
  desc "Local-first AI assistant for your Mac"
  homepage "https://basil.ac"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: ">= :ventura"

  app "Basil.app"

  zap trash: "~/Library/Application Support/Basil"
end
