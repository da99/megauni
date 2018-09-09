
module MEGAUNI
  module Base

    extend self

    def migrate_head
      postgresql = MEGAUNI.postgresql
      template1 = postgresql.database("template1")

      if template1.schema?("public")
        template1.psql_file(self, "drop.public.schema")
      else
        DA.orange! "=== {{public}} schema already removed from BOLD{{#{template1.name}}}"
      end

      if !postgresql.database?
        template1.psql_command(%<CREATE DATABASE "#{postgresql.database_name}";>)
      end

      database = postgresql.database

      {"db_owner", "www_group", "www_app"}.each { |name|
        if postgresql.role?(name)
          DA.orange! "=== role already created: {{#{name}}}"
        else
          database.psql_file(self, "role.#{name}")
        end
      }

      database.psql_command(%<
        BEGIN;
          ALTER DATABASE megauni_db OWNER TO db_owner ;
          ALTER DATABASE megauni_db WITH CONNECTION LIMIT = 5;
        COMMIT;
                            >);

      database.psql_file(self, "alter.roles")

      database.psql_command(%<
        CREATE SCHEMA IF NOT EXISTS base AUTHORIZATION db_owner;
        COMMIT;
                            >);

      {"base.object_type", "base.privacy_level"}.each { |t|
        if !database.user_defined_type?(t)
          database.psql_file(self, "enum.#{t.split('.')[1..-1].join('.')}")
        end
      }

      schema = database.schema("base")
      database.psql_file(self, "function.squeeze_whitespace")
    end # === def

    def migrate_tail
      database = MEGAUNI.postgresql.database
      database.psql_file(self, "grant.sql")
    end

  end # === module Base
end # === module MEGAUNI
