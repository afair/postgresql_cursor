module PostgreSQLCursor
  module ActiveRecord
    module SqlCursor
      # Public: Returns each row as a hash to the given block
      #
      # sql         - Full SQL statement, variables interpolated
      # options     - Hash to control 
      #   fraction: 0.1..1.0    - The cursor_tuple_fraction (default 1.0)
      #   block_size: 1..n      - The number of rows to fetch per db block fetch
      #   while: value          - Exits loop when block does not return this value.
      #   until: value          - Exits loop when block returns this value.
      #
      # Returns the number of rows yielded to the block
      def self.each_row_by_sql(sql, options={}, &block)
        options = {:connection => self.connection}.merge(options)
        PostgreSQLCursor.new(sql, options).each(&block)
      end

      # Public: Returns each row as a model instance to the given block
      # As this instantiates a model object, it is slower than each_row_by_sql 
      #
      # Paramaters: see each_row_by_sql
      #
      # Returns the number of rows yielded to the block
      def self.each_instance_by_sql(sql, options={}, &block)
        options = {:connection => self.connection}.merge(options)
        PostgreSQLCursor.new(sql, options).each do |row|
          model = instantiate(row)
          yield model
        end
      end
    end
  end
end
