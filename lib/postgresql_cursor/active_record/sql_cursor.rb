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
      #
      # sql         - Full SQL statement, variables interpolated
      # options     - Hash to control
      #   fraction: 0.1..1.0    - The cursor_tuple_fraction (default 1.0)
      #   block_size: 1..n      - The number of rows to fetch per db block fetch
      #   while: value          - Exits loop when block does not return this value.
      #   until: value          - Exits loop when block returns this value.
      #
      # Example:
      #   Post.each_row_by_sql("select * from posts") { |hash| Post.process(hash) }
      #
      # Returns the number of rows yielded to the block
      def each_row_by_sql(sql, options={}, &block)
        options = {:connection => self.connection}.merge(options)
        PostgreSQLCursor::Cursor.new(sql, options).each(&block)
      end
      alias :each_hash_by_sql :each_row_by_sql

      # Public: Returns each row as a model instance to the given block
      # As this instantiates a model object, it is slower than each_row_by_sql
      #
      # Paramaters: see each_row_by_sql
      #
      # Example:
      #   Post.each_instance_by_sql("select * from posts") { |post| post.process }
      #
      # Returns the number of rows yielded to the block
      def each_instance_by_sql(sql, options={}, &block)
        options = {:connection => self.connection}.merge(options)
        PostgreSQLCursor::Cursor.new(sql, options).each do |row|
          model = instantiate(row)
          yield model
        end
      end
    end
  end
end
