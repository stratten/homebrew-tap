# Basil Homebrew tap

This tap installs [Basil](https://github.com/stratten/Basil_OS), a local-first AI assistant for Apple Silicon Macs on macOS 13 or later.

```sh
brew install --cask stratten/tap/basil
```

Basil updates itself, so `brew upgrade` leaves it alone by default. To update through Homebrew instead, run `brew upgrade --cask --greedy basil`. To remove Basil and its application support folder, run `brew uninstall --cask --zap basil`; your `~/.basil` data folder is never removed by Homebrew.

## How this tap stays current

The cask in `Casks/basil.rb` is updated by a workflow in this repository, not by hand. Every hour, [Bump Basil cask](.github/workflows/bump-basil.yml) looks at the latest stable release of [stratten/Basil_OS](https://github.com/stratten/Basil_OS/releases). If it is newer than the cask, [the script](scripts/bump-cask.sh) downloads `Basil.dmg`, checks it against the release's `SHA256SUMS.txt`, verifies the build-provenance attestation that ties the file to the `validate.yml` workflow in the Basil repository, and only then commits the new version and checksum. Pre-releases such as `main-latest` are ignored.

GitHub pauses scheduled workflows in a repository with no activity for 60 days. If the cask looks stale, open the Actions tab and run Bump Basil cask by hand.

## Trust

Whoever can push to this repository controls what `brew install` downloads, so keep its access small. The cask pins the SHA-256 of the exact DMG, and Homebrew refuses a download that does not match it.

## License

Apache-2.0, the same as Basil. See [LICENSE](LICENSE).
