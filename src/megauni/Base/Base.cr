
module MEGAUNI
  module Base

    extend self

    def pgsql(file : String)
      File.join "src/megauni/Base/postgresql/", file
    end

    def migrate_head
      template1 = PostgreSQL.database("template1")

      if template1.schema?("public")
        template1.psql_file(pgsql "drop.public.schema.sql")
      else
        DA.orange! "=== {{public}} schema already removed from BOLD{{#{template1.name}}}"
      end

      if !PostgreSQL.database?
        template1.psql_command(%<CREATE DATABASE "#{PostgreSQL.database_name}";>)
      end

      database = PostgreSQL.database

      {"db_owner", "www_group", "www_app"}.each { |name|
        if PostgreSQL.role?(name)
          DA.orange! "=== role already created: {{#{name}}}"
        else
          database.psql_file(pgsql "role.#{name}.sql")
        end
      }

      database.psql_command(%<
        BEGIN;
          ALTER DATABASE megauni_db OWNER TO db_owner ;
          ALTER DATABASE megauni_db WITH CONNECTION LIMIT = 5;
        COMMIT;
                            >);

      database.psql_file(pgsql "alter.roles.sql")

      database.psql_command(%<
        CREATE SCHEMA IF NOT EXISTS base AUTHORIZATION db_owner;
        COMMIT;
                            >);

      {"base.object_type", "base.privacy_level"}.each { |t|
        if !database.user_defined_type?(t)
          database.psql_file(pgsql "enum.#{t.split('.')[1..-1].join('.')}.sql")
        end
      }

      schema = database.schema("base")
      database.create_or_update_definer_for(schema);
      database.psql_file(pgsql "function.squeeze_whitespace.sql")
    end # === def

    def migrate_tail
      database = PostgreSQL.database
      database.psql_file(pgsql "grant.sql")
    end

  end # === module Base
end # === module MEGAUNI
