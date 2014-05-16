module PostgreSQLCursor
  module ActiveRecord
    module ConnectionAdapters
      module PostgreSQL
        def get_type_map
          type_map
        end
      end
    end
  end
end
