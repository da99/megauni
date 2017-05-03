
# === {{CMD}}
# === {{CMD}}  "my cmd --with --args"
watch () {
  case "$@" in
    "run "*)
      shift
      case "$@" in
        "www")
          $APP_NAME compile www
          sh_color YELLOW "=== Running: {{tmp/www}} ..."
          tmp/www
          ;;

        "dev")
          $APP_NAME server grace
          $APP_NAME compile dev
          $APP_NAME server dev &
          ;; 

        *)
          sh_color RED "!!! {{Invalid option given}} for run: $@"
          exit 2
          ;;
      esac
      ;;

    *)
      if [[ -z "$@" ]]; then
        sh_color RED "!!! {{No option given}}."
        exit 2
      fi

      $APP_NAME watch run $@
      mksh_setup watch "-r src -r bin -r spec -r compile" "$APP_NAME watch run $@"
      ;;
  esac

} # === end function

