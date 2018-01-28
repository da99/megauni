#!/usr/bin/env zsh
#
#
set -u -e -o pipefail

local +x THE_ARGS="$@"
local +x THIS_DIR="$(dirname "$(dirname "$(realpath "$0")")")"

PATH="$PATH:$THIS_DIR/../sh_color/bin"
PATH="$PATH:$THIS_DIR/../process/bin"
PATH="$PATH:$THIS_DIR/../my_crystal/bin"
PATH="$PATH:$THIS_DIR/../my_zsh/bin"
PATH="$PATH:$THIS_DIR/../my_network/bin"
PATH="$PATH:$THIS_DIR/../my_jspp/bin"
PATH="$PATH:$THIS_DIR/bin"

local +x APP_NAME="$(basename "$THIS_DIR")"

local +x ACTION="[none]"
if [[ ! -z "$@" ]]; then
  ACTION="$1"; shift
fi


case $ACTION in

  help|--help|-h)
    my_zsh print-help $0 "$@"
    ;;

  *)
    local +x SH_FILE="$THIS_DIR/sh/${ACTION}/_"
    if [[ -s "$SH_FILE" ]]; then
      source "$SH_FILE"
      return 0
    fi

    # === Check progs/bin:
    if [[ -f "$THIS_DIR/tmp/bin/$ACTION" ]]; then
      export PATH="$THIS_DIR/tmp/bin:$PATH"
      "$THIS_DIR"/tmp/bin/$ACTION "$@"
      exit 0
    fi

    # === It's an error:
    echo "!!! Unknown action: $ACTION" >&2
    exit 1
    ;;

esac

