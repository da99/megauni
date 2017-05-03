
# === {{CMD}}  dev
# === {{CMD}}  prod
compile () {
  local +x TARGET="$1"; shift
  cd "$THIS_DIR"
  mkdir -p tmp
  mkdir -p prod

  echo "=== Compiling for ${TARGET}..."

  case "$TARGET" in
    dev)
      crystal build src/${APP_NAME}.cr
      ;;

    prod)
      crystal build --release src/${APP_NAME}.cr
      ;;

    *)
      echo "!!! Invalid option: $TARGET" >&2
      exit 2
      ;;
  esac

  if [[ -f "$APP_NAME" ]]; then
    mv ${APP_NAME} tmp/${APP_NAME}
    echo "=== Created: tmp/${APP_NAME}" >&2
  fi

  sh_color GREEN "=== Done: {{compile $TARGET}}"
} # === end function

