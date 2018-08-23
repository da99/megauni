
module MEGAUNI
  module PostgreSQL
    struct User_Defined_Type

      getter schema            : String
      getter name              : String
      getter internal_name     : String
      getter size              : Int64
      getter elements          : Array(String)
      getter owner             : String
      getter access_privileges : String
      getter description       : String

      def initialize(raw : String)
        @schema, @name, @internal_name, raw_size, raw_elements, @owner, @access_privileges, @description = raw.split('|')
        @elements = raw_elements.split('\n')
        @size = raw_size.to_i64
      end # def

    end # === struct User_Defined_Type
  end # === module PostgreSQL
end # === module MEGAUNI
