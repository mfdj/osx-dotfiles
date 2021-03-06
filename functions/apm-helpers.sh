# shellcheck disable=SC2148

apm_ensure() {
   for package in "$@"; do
      (cd ~/.atom/packages 2> /dev/null && find . -type d -maxdepth 1 | grep -q "$package") ||
         apm list | grep "$package" -q ||
         apm install "$package"
   done
}
