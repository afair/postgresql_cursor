module PostgreSQLCursor
  module ActiveRecord
    module SqlCursor
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
      #   Post.each_row { |hash| Post.process(hash) }
      #
      # Returns the number of rows yielded to the block
      def each_row(options={}, &block)
        options = {:connection => self.connection}.merge(options)
        all.each_row(options, &block)
      end
      alias :each_hash :each_row

      # Public: Like each_row, but returns an instantiated model object to the block
      #
      # Paramaters: same as each_row
      #
      # Example:
      #   Post.each_instance { |post| post.process }
      #
      # Returns the number of rows yielded to the block
      def each_instance(options={}, &block)
        options = {:connection => self.connection}.merge(options)
        all.each_instance(options, &block)
      end

      # Public: Returns each row as a hash to the given block

      # sql         - Full SQL statement, variables interpolated
      # options     - Hash to control
      #   fraction: 0.1..1.0    - The cursor_tuple_fraction (default 1.0)
      #   block_size: 1..n      - The number of rows to fetch per db block fetch
      #   while: value          - Exits loop when block does not return this value.
      #   until: value          - Exits loop when block returns this value.
      #
      # Example:
      #   Post.each_row_by_sql("select * from posts") { |hash| Post.process(hash) }
      #   Post.each_row_by_sql("select * from posts").count
      #
      # Returns the number of rows yielded to the block
      def each_row_by_sql(sql, options={}, &block)
        options = {:connection => self.connection}.merge(options)
        cursor  = PostgreSQLCursor::Cursor.new(sql, options)
        return cursor.each_row(&block) if block_given?
        cursor
      end
      alias :each_hash_by_sql :each_row_by_sql

      # Public: Returns each row as a model instance to the given block
      # As this instantiates a model object, it is slower than each_row_by_sql
      #
      # Paramaters: see each_row_by_sql
      #
      # Example:
      #   Post.each_instance_by_sql("select * from posts") { |post| post.process }
      #   Post.each_instance_by_sql("select * from posts").count
      #
      # Returns the number of rows yielded to the block
      def each_instance_by_sql(sql, options={}, &block)
        options = {:connection => self.connection}.merge(options)
        cursor  = PostgreSQLCursor::Cursor.new(sql, options)
        return cursor.each_instance(self, &block) if block_given?
        cursor.iterate_type(self)
      end

      # Returns and array of the given column names. Use if you need cursors and don't expect
      # this to comsume too much memory. Values are strings. Like ActiveRecord's pluck.
      def pluck_rows(*cols)
        options = cols.last.is_a?(Hash) ? cols.pop : {}
        all.each_row(options).pluck(*cols)
      end
      alias :pluck_row :pluck_rows

      # Returns and array of the given column names. Use if you need cursors and don't expect
      # this to comsume too much memory. Values are instance types. Like ActiveRecord's pluck.
      def pluck_instances(*cols)
        options = cols.last.is_a?(Hash) ? cols.pop : {}
        all.each_instance(options).pluck(*cols)
      end
      alias :pluck_instance :pluck_instances
    end
  end
end
