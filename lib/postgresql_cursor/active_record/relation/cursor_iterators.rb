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
        #
        # Returns the number of rows yielded to the block
        def each_row(options={}, &block)
          options = {:connection => self.connection}.merge(options)
          PostgreSQLCursor::Cursor.new(to_sql, options).each(&block)
        end
        alias :each_hash :each_row

        # Public: Like each_row, but returns an instantiated model object to the block
        #
        # Paramaters: same as each_row
        #
        # Example:
        #   Post.where(user_id:123).each_instance { |post| post.process }
        #
        # Returns the number of rows yielded to the block
        def each_instance(options={}, &block)
          options = {:connection => self.connection}.merge(options)
          options[:symbolize_keys] = false # Must be strings to initiate
          PostgreSQLCursor::Cursor.new(to_sql, options).each do |row, column_types|
            model = instantiate(row, column_types)
            yield model
          end
        end
      end
    end
  end
end
