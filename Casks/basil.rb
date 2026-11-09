cask "basil" do
  version "1.0.2"
  sha256 "624daf2874fc8cf319392ad22257f3c2cab57c82459cc06559edb6a960aa4920"

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
