
# === {{CMD}}
# === {{CMD}}  "my cmd --with --args"
watch () {
  case "$@" in
    "")
      $APP_NAME watch dev
      mksh_setup watch "-r src -r bin -r spec" "$APP_NAME watch dev"
      ;;

    "dev")
      $APP_NAME server grace
      $APP_NAME compile dev
      $APP_NAME server dev &
      ;;

    *)
      sh_color RED "!!! {{Invalid option}}: BOLD{{$@}}"
      ;;
  esac

} # === end function

