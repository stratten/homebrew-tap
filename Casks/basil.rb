cask "basil" do
  version "1.0.1"
  sha256 "58f4f6266f73b8bd27f486cca1b4ff5ee1b70d6c04f64f218abfb5c0efddaa1d"

  url "https://github.com/stratten/Basil_OS/releases/download/v#{version}/Basil.dmg"
  name "Basil"
  desc "Local-first AI assistant with agents, transcription, and meeting notes"
  homepage "https://basil.ac/"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :ventura

  app "Basil.app"

  zap trash: "~/Library/Application Support/Basil"
end
