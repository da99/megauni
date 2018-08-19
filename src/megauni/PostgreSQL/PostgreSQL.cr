
require "da"
require "./Database_Cluster"
ENV["PATH"] = "#{ENV["PATH"]}:#{DA.app_dir}/postgresql-10.4/bin"

module MEGAUNI
  module PostgreSQL
    extend self

    SUPER_USER = "pg-megauni"

    def start
      app_dir = DA.app_dir
      Dir.cd app_dir
      prefix = File.expand_path "postgresql-10.4"
      ENV["PGROOT"] = prefix
      ENV["PGDATA"] = File.join(prefix, "data")
      ENV["PGLOG"]  = File.join( ENV["PGDATA"], "log.log" )
      ENV["PATH"]   = "#{prefix}/bin:#{ENV["PATH"]}"
      Dir.cd prefix
      # Extra options to run postmaster with, e.g.:
      # -N is the maximal number of client connections
      # -B is the number of shared buffers and has to be at least 2x the value for -N
      puts "=== in #{Dir.current}: #{Time.now}: #{`postgres --version`.strip}"

      user = `whoami`.strip
      if user != SUPER_USER
        STDERR.puts "!!! Not running as user: #{SUPER_USER}"
        Process.exit 1
      end

      cmd = "#{prefix}/bin/postgres"
      args = %<
        --config_file=#{app_dir}/config/postgresql/postgresql.conf
        --hba_file=#{app_dir}/config/postgresql/pg_hba.conf
        --data_directory=#{ENV["PGDATA"]} \
        -N 10 -B 20
      >.split
      DA.orange! "=== Running as #{user}: {{#{cmd}}} BOLD{{#{args.join ' '}}}"
      Process.exec(cmd, args)
    end # === def

    def compile
      # --with-python
      # --with-pam
      # --with-perl
      # --with-tcl
      # --without-bonjour
      # --with-libxml
      # --with-libxslt
      # --with-openssl
      configure_args = %w[
        --datadir=/usr/share/megauni_pg
        --enable-thread-safety
        --without-ldap
        --without-gssapi
        --without-krb5
        --disable-rpath
        --with-system-tzdata=/usr/share/zoneinfo
        --enable-nls
        --with-uuid=e2fs
        --without-perl
        --without-python
        --without-tcl
      ]
      pkgname="postgresql"
      version="10.4"
      distfiles="https://ftp.postgresql.org/pub/source/v#{version}/#{pkgname}-#{version}.tar.bz2"
      hostmakedepends=%w[flex docbook docbook2x openjade]

      # http://www.postgresql.org/docs/9.3/static/docguide-toolsets.html
      ENV["SGML_CATALOG_FILES"]="/usr/share/sgml/openjade/catalog:/usr/share/sgml/iso8879/catalog:/usr/share/sgml/docbook/dsssl/modular/catalog:/usr/share/sgml/docbook/4.2/catalog"

        # perl
        # tcl-devel
        # python-devel
        # libxml2-devel
        # libxslt-devel
        # pam-devel
      makedepends=%w[
        libfl-devel
        readline-devel
        libressl-devel
        libuuid-devel
      ]
    end # def

  end # === module Postgresql
end # === module Megauni

