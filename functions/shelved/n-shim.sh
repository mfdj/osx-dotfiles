# shellcheck disable=SC2148

<< 'MARKDOWN'
n is a function that extends [n](https://github.com/tj/n)

*Usage*

```
n
```

Does one thing resolves a version from .node-version or package.json and passes it to n.

Passing any arguments to n will transparently skip this version resolution.

Paths without .node-version or package.json will go directly to the n interactive picker.
MARKDOWN

n() {
   # forward straght to n
   [[ $# -gt 0 ]] && {
      command n "$@"
      return
   }

   # look for a local-version

   [[ -f .node-version ]] && {
      echo using .node-version
      command n "$(cat .node-version)" && node --version
      return
   }

   [[ -f .nvmrc ]] && {
      echo using .nvmrc
      command n "$(cat .nvmrc)" && node --version
      return
   }

   [[ -f package.json ]] && {
      echo checking package.json
      if command -v jq > /dev/null; then
         local version="$(jq -r '.engines.node | match("[>= ]*(.+)") | .captures[0].string' package.json 2> /dev/null)"
         if [[ $version ]]; then
            command n "$(echo $version)" && node --version
            return
         else
            echo "package.json missing 'engines' key"
            sleep 1.5
         fi
      else
         echo "could not parse package.json, missing jq — please 'brew install jq'"
         sleep 1.5
      fi
   }

   # use n's interactive picker
   command n
}
