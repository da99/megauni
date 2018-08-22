
module MEGAUNI
  module Base

    extend self

    def migrate_before_head
      template1 = PostgreSQL.database("template1")

      if template1.schema?("public")
        template1.psql_file("src/megauni/Base/sql.drop.public.schema.sql")
      else
        DA.orange! "=== {{public}} schema already removed from BOLD{{#{template1.name}}}"
      end

      if !PostgreSQL.database?
        template1.psql_command(%<CREATE DATABASE "#{PostgreSQL.database_name}";>)
      end

      database = PostgreSQL.database
      database.psql_command(
        %<
          BEGIN;
            ALTER DATABASE megauni_db OWNER TO db_owner ;
            ALTER DATABASE megauni_db WITH CONNECTION LIMIT = 5;
          COMMIT;
        >
      );

      {"db_owner", "www_definer", "www_group", "www_app"}.each { |name|
        if PostgreSQL.role?(name)
          DA.orange! "=== role already created: {{#{name}}}"
        else
          database.psql_file("src/megauni/Base/sql.role.#{name}.sql")
        end
      }

      database.psql_file("src/megauni/Base/sql.alter.roles.sql")
    end # === def

    def migrate_head
      database = PostgreSQL.database
      if !database.schema?("base")
        database.psql_command(
          %<
            SET ROLE db_owner;
            CREATE SCHEMA base;
            COMMIT;
          >
        );
      end

      if database.schema?("megauni_schema")
        database.psql_command(%< DROP SCHEMA megauni_schema; COMMIT; >);
      end
    end # === def

  end # === module Base
end # === module MEGAUNI
