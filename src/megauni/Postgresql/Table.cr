
module MEGAUNI
  struct Postgresql
    struct Table

      struct Name

        def self.valid!(x : String)
          x[/^[a-z0-9\_]{1,25}$/]?.not_nil!
        end # === def

        getter name : String
        getter schema : String

        def initialize(raw_schema : String, raw : String)
          @schema = Schema_Name.new(raw_schema).name
          @name   = Table_Name.valid!(pieces.last)
        end # === def

        def initialize(raw : String)
          pieces = raw.split('.')
          case pieces.size
          when 2
            @schema = Schema::Name.valid!(pieces.first)
            @name   = Table::Name.valid!(pieces.last)
          else
            raise Exception.new("Invalid table name: #{raw.inspect}")
          end
        end # === def

      end # === struct Name

      getter database : Database
      getter schema   : String
      getter name     : String
      getter type     : String
      getter owner    : String

      def initialize(@database, raw_line : String)
        @schema, @name, @type, @owner = raw_line.split('|')
      end # def

    end # === struct Table
  end # === struct Postgresql
end # === module MEGAUNI
