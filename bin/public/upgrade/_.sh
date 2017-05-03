
# === {{CMD}}
upgrade () {
  echo "=== Pulling from $(git remote get-url origin)"
  git pull

  echo "=== Downloading: CSS Reset..."
  cd "$THIS_DIR"
  mkdir -p Public/megauni/basic_one
  cd Public/megauni/basic_one
  curl --silent -L "https://github.com/richclark/HTML5resetCSS/raw/master/reset.css" -o reset.css

  echo "=== Downloading: Crystal deps..."
  cd "$THIS_DIR"
  crystal deps

  sh_color GREEN "=== {{Done upgrading}}."
} # === end function
