
module MEGAUNI
  struct News

    # =============================================================================
    # Class:
    # =============================================================================

    def self.migrate
      database = Postgresql.database
      schema = database.create_schema?("news")
      database.create_or_update_definer_for(schema)
      database.create_table?("news.tbl", self, "tbl")
      database.psql_file(self, "function.insert")
    end # def

  end # === struct News
end # === module MEGAUNI
