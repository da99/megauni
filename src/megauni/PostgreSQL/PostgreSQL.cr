
require "da"
# require "./Database_Cluster"
require "./Role"
require "./Table"
require "./Database"
require "./User_Defined_Type"
require "./Schema"

module MEGAUNI
  module PostgreSQL
    extend self

    def database_name
      "megauni_db"
    end

    def super_user
      "pg-megauni"
    end # === def

    def prefix : String
      File.join(DA.app_dir, "postgresql-10.4")
    end

    def prefix(*args : String) : String
      File.join(prefix, *args)
    end

    def port
      3111
    end

    def start
      app_dir = DA.app_dir
      Dir.cd app_dir
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
      if user != super_user
        STDERR.puts "!!! Not running as user: #{super_user}"
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

    def histfile(user)
      "/tmp/#{user}.histfile"
    end

    def psql_output(cmd  : String)
      DA.capture_output(
        "sudo",
        %<
          -u #{PostgreSQL.super_user}
          #{PostgreSQL.prefix("/bin/psql")}
          --set=HISTFILE=/dev/null
          --port=#{PostgreSQL.port}
          --dbname=template1
          --no-align
          --set ON_ERROR_STOP=on
          --set AUTOCOMMIT=off
          #{cmd}
        >.split
      )
    end

    def psql_tuples(cmd  : String)
      DA.capture_output(
        "sudo",
        %<
          -u #{PostgreSQL.super_user}
          #{PostgreSQL.prefix("/bin/psql")}
          --set=HISTFILE=/dev/null
          --port=#{PostgreSQL.port}
          --dbname=template1
          --tuples-only
          --no-align
          --set ON_ERROR_STOP=on
          --set AUTOCOMMIT=off
          #{cmd}
        >.split
      )
    end


    def psql(*cmd_and_args : String)
      DA.capture_output(
        "sudo",
        %<
          -u #{PostgreSQL.super_user}
          #{PostgreSQL.prefix("/bin/psql")}
          --set=HISTFILE=/dev/null
          --port=#{PostgreSQL.port}
          --dbname=template1
          --no-align
          --set ON_ERROR_STOP=on
          --set AUTOCOMMIT=off
        >.split.concat(cmd_and_args)
      )
    end

    # Roles are common across an entire Database cluster,
    # so they are defined on PostgreSQL, and not on the Database struct.
    def roles
      roles = Deque(PostgreSQL::Role).new
      output = psql_tuples("-c \\du")
      output.each_line.each { |raw_line|
        line = raw_line.chomp
        next if line.empty?
        roles.push Role.new(line)
      }
      roles
    end

    def role?(name : String)
      roles.find { |x| x.name == name }
    end # def

    def databases
      sep = "~!~"
      databases = Deque(PostgreSQL::Database).new
      DA.each_non_empty_string( psql_tuples("--record-separator=#{sep} -c \\list").to_s.split(sep) ) { |line|
        databases.push Database.new(line)
      }
      databases
    end # === def

    def database : PostgreSQL::Database
      database(database_name)
    end # === def

    def database(name : String)
      db = database?(name)
      if db
        return db
      else
        raise Exception.new("Database not found: #{name.inspect}")
      end
    end # === def

    def database?
      database?(PostgreSQL.database_name)
    end # === def

    def database?(name : String)
      databases.find { |db| db.name == PostgreSQL.database_name }
    end # === def

    def migrate_up
      # === HEAD: ========================================
      MEGAUNI::Base.migrate_before_head
      MEGAUNI::Base.migrate_head

      # === BODY: ========================================

      # === TAIL: ========================================
      MEGAUNI::Base.migrate_after_tail

      DA.green! "=== {{Done}}: BOLD{{migrating up}}"
    end # === def

  end # === module Postgresql
end # === module Megauni

