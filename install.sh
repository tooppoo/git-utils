#!/usr/bin/env sh
set -eu

REPO_OWNER="${REPO_OWNER:-tooppoo}"
REPO_NAME="${REPO_NAME:-git-helpers}"
REF="${REF:-main}"
INSTALL_DIR="${INSTALL_DIR:-"$HOME/.local/bin"}"
FORCE=0

main() {
  if [ "$#" -eq 0 ]; then
    echo "error: at least one helper name is required" >&2
    usage >&2
    exit 2
  fi
  
  need_cmd chmod
  need_cmd cmp
  need_cmd mkdir
  need_cmd mv
  need_cmd rm
  
  mkdir -p "$INSTALL_DIR"
  
  for helper in "$@"; do
    install_one "$helper"
  done
  
  if ! contains_path "$INSTALL_DIR"; then
    cat >&2 <<EOF
  
  warning: $INSTALL_DIR is not in PATH.
  
  Add this to your shell profile:
  
    export PATH="$INSTALL_DIR:\$PATH"
  
  EOF
  fi
  
  echo "installed git helper commands to $INSTALL_DIR"
}

usage() {
  cat <<'EOF'
usage: install.sh [--force] <git-helper>...

Examples:
  install.sh git-commits-since-tag
  install.sh git-commits-since-tag git-merges-since-tag

Environment variables:
  INSTALL_DIR   Install directory. Default: $HOME/.local/bin
  REF           Git ref to install from. Default: main
  REPO_OWNER    GitHub owner. Default: tooppoo
  REPO_NAME     GitHub repository. Default: git-helpers
EOF
}

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    exit 127
  fi
}

fetch() {
  url="$1"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$url"
  else
    echo "error: curl or wget is required" >&2
    exit 127
  fi
}

contains_path() {
  dir="$1"
  old_ifs=$IFS
  IFS=:
  for p in $PATH; do
    if [ "$p" = "$dir" ]; then
      IFS=$old_ifs
      return 0
    fi
  done
  IFS=$old_ifs
  return 1
}

validate_helper_name() {
  name="$1"

  case "$name" in
    git-*)
      ;;
    *)
      echo "error: helper name must start with git-: $name" >&2
      exit 2
      ;;
  esac

  case "$name" in
    */*|*..*|"")
      echo "error: invalid helper name: $name" >&2
      exit 2
      ;;
  esac

  case "$name" in
    *[!A-Za-z0-9._-]*)
      echo "error: invalid characters in helper name: $name" >&2
      exit 2
      ;;
  esac
}

install_one() {
  name="$1"
  validate_helper_name "$name"

  url="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$REF/bin/$name"
  target="$INSTALL_DIR/$name"
  tmp="$target.tmp.$$"

  trap 'rm -f "$tmp"' EXIT HUP INT TERM

  echo "installing $name"

  if ! fetch "$url" > "$tmp"; then
    rm -f "$tmp"
    echo "error: failed to download: $url" >&2
    exit 1
  fi

  chmod 0755 "$tmp"

  if [ -e "$target" ] && ! cmp -s "$tmp" "$target"; then
    if [ "$FORCE" -ne 1 ]; then
      rm -f "$tmp"
      echo "error: $target already exists and differs" >&2
      echo "hint: rerun with --force to overwrite" >&2
      exit 1
    fi
  fi

  mv "$tmp" "$target"
  trap - EXIT HUP INT TERM
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      break
      ;;
  esac
done

main "$@"

