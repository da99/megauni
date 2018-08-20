
module MEGAUNI
  module Base

    extend self

    def migrate_before_head
      db = PostgreSQL.database("template1")
      {"db_owner", "www_definer", "www_group", "www_app"}.each { |name|
        if PostgreSQL.role?(name)
          DA.orange! "=== role already created: {{#{name}}}"
        else
          db.psql_file("src/megauni/Base/sql.role.#{name}.sql")
        end
      }
    end # === def

    def migrate_head
      db = PostgreSQL.database
      if db.schema?("public")
        db.psql_file("src/megauni/Base/sql.drop.public.schema.sql")
      else
        DA.orange! "=== {{public}} schema already removed from BOLD{{#{db.name}}}"
      end
    end # === def

  end # === module Base
end # === module MEGAUNI
