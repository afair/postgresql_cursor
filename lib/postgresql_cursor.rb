# frozen_string_literal: true

require 'postgresql_cursor/version'
require 'active_support'

ActiveSupport.on_load :active_record do
  require 'postgresql_cursor/cursor'
  require 'postgresql_cursor/active_record/relation/cursor_iterators'
  require 'postgresql_cursor/active_record/sql_cursor'
  require 'postgresql_cursor/active_record/connection_adapters/postgresql_type_map'

  # ActiveRecord 4.x
  require 'active_record/connection_adapters/postgresql_adapter'
  ActiveRecord::Base.extend(PostgreSQLCursor::ActiveRecord::SqlCursor)
  ActiveRecord::Relation.send(:include, PostgreSQLCursor::ActiveRecord::Relation::CursorIterators)
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send(:include, PostgreSQLCursor::ActiveRecord::ConnectionAdapters::PostgreSQLTypeMap)
end
