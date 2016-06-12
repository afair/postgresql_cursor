# Defines extension to ActiveRecord/AREL to use this library
module PostgreSQLCursor
  module ActiveRecord
    module Relation
      module CursorIterators

        # Public: Executes the query, returning each row as a hash
        # to the given block.
        #
        # options     - Hash to control
        #   fraction: 0.1..1.0    - The cursor_tuple_fraction (default 1.0)
        #   block_size: 1..n      - The number of rows to fetch per db block fetch
        #   while: value          - Exits loop when block does not return this value.
        #   until: value          - Exits loop when block returns this value.
        #
        # Example:
        #   Post.where(user_id:123).each_row { |hash| Post.process(hash) }
        #   Post.each_row.map {|r| r["id"].to_i }
        #
        # Returns the number of rows yielded to the block
        def each_row(options={}, &block)
          options = {:connection => self.connection}.merge(options)
          cursor  = PostgreSQLCursor::Cursor.new(to_unprepared_sql, options)
          return cursor.each_row(&block) if block_given?
          cursor
        end
        alias :each_hash :each_row

        # Public: Like each_row, but returns an instantiated model object to the block
        #
        # Paramaters: same as each_row
        #
        # Example:
        #   Post.where(user_id:123).each_instance { |post| post.process }
        #   Post.where(user_id:123).each_instance.map { |post| post.process }
        #
        # Returns the number of rows yielded to the block
        def each_instance(options={}, &block)
          options = {:connection => self.connection}.merge(options)
          cursor = PostgreSQLCursor::Cursor.new(to_unprepared_sql, options)
          return cursor.each_instance(self, &block) if block_given?
          cursor.iterate_type(self)
        end

        # Plucks the column names from the rows, and return them in an array
        def pluck_rows(*cols)
          options = cols.last.is_a?(Hash) ? cols.pop : {}
          options[:connection] = self.connection
          PostgreSQLCursor::Cursor.new(to_pluck_sql(cols), options).pluck(*cols)
        end
        alias :pluck_row :pluck_rows

        # Plucks the column names from the instances, and return them in an array
        def pluck_instances(*cols)
          options = cols.last.is_a?(Hash) ? cols.pop : {}
          options[:connection] = self.connection
          PostgreSQLCursor::Cursor.new(to_pluck_sql(cols), options).iterate_type(self).pluck(*cols)
        end
        alias :pluck_instance :pluck_instances

        private

        def to_pluck_sql(cols)
          self.arel.projections = cols.map {|col|
            Arel::Nodes::SqlLiteral.new(col.to_s)
          }
          to_unprepared_sql
        end

        # Returns sql string like #to_sql, but with bind parameters interpolated.
        # ActiveRecord sets up query as prepared statements with bind variables.
        # Cursors will prepare statements regardless.
        def to_unprepared_sql
          if self.connection.respond_to?(:unprepared_statement)
            self.connection.unprepared_statement do
              to_sql
            end
          else
            to_sql
          end
        end

      end
    end
  end
end
