module PostgreSQLCursor
  module ActiveRecord
    module ConnectionAdapters
      module PostgreSQL
        def get_type_map
          if Rails::VERSION::MAJOR == 4 && Rails::VERSION::MAJOR == 0
            ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::OID::TYPE_MAP
          else
            type_map
          end
        end
      end
    end
  end
end
