################################################################################
# PostgreSQLCursor: library class provides postgresql cursor for large result
# set processing. Requires ActiveRecord, but can be adapted to other DBI/ORM libraries.
# If you don't use AR, this assumes #connection and #instantiate methods are available.
#
# options     - Hash to control operation and loop breaks
#   connection: instance  - ActiveRecord connection to use
#   fraction: 0.1..1.0    - The cursor_tuple_fraction (default 1.0)
#   block_size: 1..n      - The number of rows to fetch per db block fetch
#   while: value          - Exits loop when block does not return this value.
#   until: value          - Exits loop when block returns this value.
#   with_hold: boolean    - Allows the query to remain open across commit points.
#
# Exmaples:
#   PostgreSQLCursor::Cursor.new("select ...").each { |hash| ... }
#   ActiveRecordModel.where(...).each_row { |hash| ... }
#   ActiveRecordModel.each_row_by_sql("select ...") { |hash| ... }
#   ActiveRecordModel.each_instance_by_sql("select ...") { |model| ... }
#
module PostgreSQLCursor
  class Cursor
    include Enumerable
    attr_reader :sql, :options, :connection, :count, :result

    # Public: Start a new PostgreSQL cursor query
    # sql     - The SQL statement with interpolated values
    # options - hash of processing controls
    #   while: value    - Exits loop when block does not return this value.
    #   until: value    - Exits loop when block returns this value.
    #   fraction: 0.1..1.0    - The cursor_tuple_fraction (default 1.0)
    #   block_size: 1..n      - The number of rows to fetch per db block fetch
    #                           Defaults to 1000
    #   with_hold       - Allows the query to remain open across commit points.
    #
    # Examples
    #
    #   PostgreSQLCursor::Cursor.new("select ....")
    #
    # Returns the cursor object when called with new.
    def initialize(sql, options={})
      @sql        = sql
      @options    = options
      @connection = @options.fetch(:connection) { ::ActiveRecord::Base.connection }
      @count      = 0
      @iterate    = options[:instances] ? :each_instance : :each_row
    end

    # Specify the type to instantiate, or reset to return a Hash
    def iterate_type(type=nil)
      if type.nil? || type == Hash
        @iterate = :each_row
      elsif type == Array
        @iterate = :each_array
      else
        @iterate = :each_instance
        @type    = type
      end
      self
    end

    # Public: Yields each row of the result set to the passed block
    #
    # Yields the row to the block. The row is a hash with symbolized keys.
    #   {colname: value, ....}
    #
    # Returns the count of rows processed
    def each(&block)
      if @iterate == :each_row
        self.each_row(&block)
      elsif @iterate == :each_array
        self.each_array(&block)
      else
        self.each_instance(@type, &block)
      end
    end

    def each_row(&block)
      self.each_tuple do |row|
        row = row.symbolize_keys if @options[:symbolize_keys]
        block.call(row)
      end
    end

    def each_array(&block)
      old_iterate = @iterate
      @iterate = :each_array
      begin
        rv = self.each_tuple do |row|
          block.call(row)
        end
      ensure
        @iterate = old_iterate
      end
      rv
    end

    def each_instance(klass=nil, &block)
      klass ||= @type
      self.each_tuple do |row|
        model = klass.send(:instantiate,row)
        block.call(model)
      end
    end

    # Returns an array of columns plucked from the result rows.
    # Experimental function, as this could still use too much memory
    # and negate the purpose of this libarary.
    # Should this return a lazy enumerator instead?
    def pluck(*cols)
      options = cols.last.is_a?(Hash) ? cols.pop : {}
      @options.merge!(options)
      @options[:symbolize_keys] = true
      self.iterate_type(options[:class]) if options[:class]
      cols    = cols.map {|c| c.to_sym }
      result  = []

      self.each() do |row|
        row = row.symbolize_keys if row.is_a?(Hash)
        result << cols.map { |c| row[c] }
      end

      result.flatten! if cols.size == 1
      result
    end

    def each_tuple(&block) #:nodoc:
      has_do_until  = @options.has_key?(:until)
      has_do_while  = @options.has_key?(:while)
      @count        = 0
      @column_types = nil
      with_optional_transaction do
        begin
          open
          while (row = fetch) do
            break if row.size==0
            @count += 1
            rc = block.call(row)
            break if has_do_until && rc == @options[:until]
            break if has_do_while && rc != @options[:while]
          end
        rescue Exception => e
          raise e
        ensure
          close if @block
        end
      end
      @count
    end

    def cast_types(row)
      row
    end

    def column_types
      return nil if ::ActiveRecord::VERSION::MAJOR < 4
      return @column_types if @column_types

      types = {}
      fields = @result.fields
      fields.each_with_index do |fname, i|
        ftype = @result.ftype i
        fmod  = @result.fmod i
        types[fname] = @connection.get_type_map.fetch(ftype, fmod) { |oid, mod|
          warn "unknown OID: #{fname}(#{oid}) (#{sql})"
          OID::Identity.new
        }
      end

      @column_types = types
    end

    # Public: Opens (actually, "declares") the cursor. Call this before fetching
    def open
      set_cursor_tuple_fraction
      @cursor = SecureRandom.uuid.gsub("-","")
      hold = @options[:with_hold] ? 'with hold ' : ''
      @result = @connection.execute("declare cursor_#{@cursor} no scroll cursor #{hold}for #{@sql}")
      @block = []
    end

    # Public: Returns the next row from the cursor, or empty hash if end of results
    #
    # Returns a row as a hash of {'colname'=>value,...}
    def fetch(options={})
      open unless @block
      fetch_block if @block.size==0
      row = @block.shift
      row = row.symbolize_keys if row && options[:symbolize_keys]
      row
    end

    # Private: Fetches the next block of rows into @block
    def fetch_block(block_size=nil)
      block_size ||= @block_size ||= @options.fetch(:block_size) { 1000 }
      @result = @connection.execute("fetch #{block_size} from cursor_#{@cursor}")

      if @iterate == :each_array
        @block = @result.each_row.collect {|row| row }
      else
        @block = @result.collect {|row| row }
      end
    end

    # Public: Closes the cursor
    def close
      @connection.execute("close cursor_#{@cursor}")
    end

    # Private: Open transaction unless with_hold option, specified
    def with_optional_transaction
      if @options[:with_hold]
        yield
      else
        @connection.transaction { yield }
      end
    end

    # Private: Sets the PostgreSQL cursor_tuple_fraction value = 1.0 to assume all rows will be fetched
    # This is a value between 0.1 and 1.0 (PostgreSQL defaults to 0.1, this library defaults to 1.0)
    # used to determine the expected fraction (percent) of result rows returned the the caller.
    # This value determines the access path by the query planner.
    def set_cursor_tuple_fraction(frac=1.0)
      @cursor_tuple_fraction ||= @options.fetch(:fraction) { 1.0 }
      return @cursor_tuple_fraction if frac == @cursor_tuple_fraction
      @cursor_tuple_fraction = frac
      @result = @connection.execute("set cursor_tuple_fraction to  #{frac}")
      frac
    end
  end
end
