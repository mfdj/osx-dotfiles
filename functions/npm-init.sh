# shellcheck disable=SC2148

npm_init() {
   [[ -f package.json  ]] || echo "{\"name\": \"${PWD##*/}\", \"private\": true}" > package.json
   [[ -f .editorconfig ]] || cp "$DOTFILES_DIR/configs/my-prefs.editorconfig" .editorconfig
}

npminit() {
   npm_init
}
