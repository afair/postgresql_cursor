require 'postgresql_cursor/version'
require 'postgresql_cursor/cursor'
require 'postgresql_cursor/active_record/relation/cursor_iterators'
require 'postgresql_cursor/active_record/sql_cursor'

# ActiveRecord 4.x
require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'
ActiveRecord::Base.include(PostgreSQLCursor::ActiveRecord::SqlCursor)
ActiveRecord::Relation.include(PostgreSQLCursor::ActiveRecord::Relation::CursorIterators)

ActiveRecord::Base.establish_connection(
  "postgres://#{ENV['USER']}:@localhost/#{ENV['USER']}"
)

class List < ActiveRecord::Base
  self.table_name = 'list'
end

List.order("list_id").each_row {|r| p r }
List.order("list_id").each_instance {|r| p r }
