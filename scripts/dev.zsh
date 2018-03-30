#!/usr/bin/env zsh
#
#
set -u -e -o pipefail


case "$1" in
  watch)
    exec sudo -u production_user --preserve-env da_dev watch
    ;;

  reset)
    bin/megauni reset
    exec sudo -u production_user --preserve-env bin/megauni migrate force
    ;;

  migrate)
    exec sudo -u production_user --preserve-env bin/megauni migrate force
    ;;

  *)
    echo "!!! Unknown args: $@" >&2
    exit 1
    ;;
esac
