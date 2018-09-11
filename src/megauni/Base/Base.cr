
module MEGAUNI
  module Base

    extend self

    def migrate_head
      postgresql = MEGAUNI.postgresql
      template1 = postgresql.database("template1")

      template1.drop_schema?("public")

      database = postgresql.create_database?(postgresql.database_name)

      postgresql.create_role?("db_owner")
      postgresql.create_role?("www_group")
      postgresql.create_role?("definer_group")
      postgresql.create_role?("www_app")
      database.psql_file(self, "role.www_app")

      database.psql_command("
        BEGIN;
          ALTER DATABASE megauni_db OWNER TO db_owner ;
          ALTER DATABASE megauni_db WITH CONNECTION LIMIT = 5;
        COMMIT;
      ");

      database.create_schema?("base")

      {"base.object_type", "base.privacy_level"}.each { |t|
        if !database.user_defined_type?(t)
          database.psql_file(self, "enum.#{t.split('.')[1..-1].join('.')}")
        end
      }

      schema = database.schema("base")
      database.psql_file(self, "grant.sql")
      database.psql_file(self, "function.squeeze_whitespace")
    end # === def

    def migrate_tail
    end

  end # === module Base
end # === module MEGAUNI
