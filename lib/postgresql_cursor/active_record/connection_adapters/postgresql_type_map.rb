# lib/postgresql_cursor/active_record/connection_adapters/postgresql_type_map
module PostgreSQLCursor
  module ActiveRecord
    module ConnectionAdapters
      module PostgreSQLTypeMap
        # Returns the private "type_map" needed for the cursor operation
        def get_type_map # :nodoc:
          if ::ActiveRecord::VERSION::MAJOR == 4 && ::ActiveRecord::VERSION::MINOR == 0
            ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::OID::TYPE_MAP
          else
            type_map
          end
        end
      end
    end
  end
end
