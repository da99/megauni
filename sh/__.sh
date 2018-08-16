#!/usr/bin/env sh
#
#

set -u -e

THE_ARGS="$@"
THIS_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
THIS_NAME="$(basename "$THIS_DIR")"

PATH="$PATH:$THIS_DIR/bin"

pkgname="postgresql"
version="10.4"
archive_file="${pkgname}-${version}.tar.bz2"
folder="${pkgname}-${version}"
distfiles="https://ftp.postgresql.org/pub/source/v${version}/${archive_file}"

export PREFIX=/apps/megauni_pg/$folder
app_dir=/apps/megauni_pg
export config_dir=/apps/megauni_pg/config
export LD_RUN_PATH=$PREFIX/lib
export LD_LIBRARY_PATH=$PREFIX/lib
export PATH="$PREFIX/bin:$PATH"
full_args="$@"
db_user=pg-megauni

case "$@" in

  "psql "*)
    cd $THIS_DIR
    shift
    set -x
    user="$1"
    histfile="/tmp/${user}.histfile"
    shift
    exec sudo -u $user $PREFIX/bin/psql --set=HISTFILE="$histfile" --port=311 $@
    ;;

  compile)
    da void install libfl-devel readline-devel libressl-devel libuuid-devel
    main_dir="$PWD"
    mkdir -p tmp/
    cd tmp

    if ! test -f "$archive_file"; then
      wget "$distfiles"
    fi

    if ! test -d "$folder" ; then
      tar xvjf "$archive_file"
    fi

    cd "$folder"
    make distclean
    ./configure
      --prefix="$PREFIX"                       \
      --enable-thread-safety                   \
      --without-ldap                           \
      --without-gssapi                         \
      --without-krb5                           \
      --disable-rpath                          \
      --with-system-tzdata=/usr/share/zoneinfo \
      --enable-nls                             \
      --with-uuid=e2fs                         \
      --without-perl                           \
      --without-python                         \
      --without-tcl

    make --jobs=3
    make install
    ;; # compile

  "reset data")
    da is dev
    echo "=== Are you sure you want to delete /data? y/N "
    read -r ans
    case "$ans" in
      y|Y|YES|yes)
        set -x
        sudo pkill -f "postgres .+--data_directory.+megauni_pg.+"
        sudo rm -r "/apps/megauni_pg/postgresql-10.4"/data
        megauni_pg create data
        ;;
      *)
        echo "=== Skipping removing /data"
        ;;
    esac
    ;;

  "create data")
    set -x
    cd $PREFIX

    sudo da create system user pg-megauni
    sudo da create system user www_app

    mkdir -p data
    sudo chown $db_user:$db_user --recursive data
    sudo chmod go-rwX --recursive            data

    if ! sudo test -d data || test -z "$(sudo ls --almost-all data)" ; then
      sudo -u $db_user initdb  \
        --username=${db_user}  \
        --auth=peer            \
        --auth-host=reject     \
        --auth-local=peer      \
        --locale="en_US.UTF-8" \
        --pgdata $PWD/data     \
        --data-checksums
    else
      echo "=== Data dir already created."
    fi
    ;; # "create data"

  "migrate")
    sudo -u pg-megauni da pg migrate --port=311 --dbname=template1 \
      $app_dir/migrate/create_db

    sudo -u pg-megauni da pg migrate --port=311 --dbname=megauni_db \
      $app_dir/migrate/megauni_db/common      \
      $app_dir/migrate/megauni_db/screen_name \
      $app_dir/migrate/megauni_db/member      \
      $app_dir/migrate/megauni_db/block       \
      $app_dir/migrate/megauni_db/permission  \
      ;
    ;; # create data

  *)
    cd "tmp/$folder"
    exec $@
    ;;

esac
