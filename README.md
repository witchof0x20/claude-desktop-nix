```bash
nix run github:witchof0x20/claude-desktop-nix#claude-desktop
nix run github:witchof0x20/claude-desktop-nix#claude-code
```


I don't use Claude code so I don't really maintain it. the way to update it if you want to PR is
```bash
cd claude-code
npm install --package-lock-only @anthropic-ai/claude-code
rm package.json
cd ..
```
then `nix build.#claude-code` and edit the hashes in `claude-code/default.nix` until things work.
