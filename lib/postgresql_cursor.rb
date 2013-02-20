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
#
# Exmaples: 
#   PostgreSQLCursor.new("select ...").each { |hash| ... }
#   ActiveRecordModel.where(...).each_row { |hash| ... }
#   ActiveRecordModel.each_row_by_sql("select ...") { |hash| ... }
#   ActiveRecordModel.each_instance_by_sql("select ...") { |model| ... }
#
class PostgreSQLCursor
  include Enumerable
  attr_reader :sql, :options, :connection, :count, :result
  @@cursor_seq = 0

  # Public: Start a new PostgreSQL cursor query
  # sql     - The SQL statement with interpolated values
  # options - hash of processing controls
  #   while: value    - Exits loop when block does not return this value.
  #   until: value    - Exits loop when block returns this value.
  #   fraction: 0.1..1.0    - The cursor_tuple_fraction (default 1.0)
  #   block_size: 1..n      - The number of rows to fetch per db block fetch
  #                           Defaults to 1000
  #
  # Examples
  #
  #   PostgreSQLCursor.new("select ....")
  #
  # Returns the cursor object when called with new.
  def initialize(sql, options={})
    @sql        = sql
    @options    = options
    @connection = @options.fetch(:connection) { ActiveRecord::Base.connection }
    @count      = 0
  end

  # Public: Yields each row of the result set to the passed block
  #
  #
  # Yields the row to the block. The row is a hash with symbolized keys.
  #   {colname: value, ....}
  #
  # Returns the count of rows processed
  def each(&block)
    has_do_until = @options.has_key?(:until)
    has_do_while = @options.has_key?(:while)
    @count      = 0
    @connection.transaction do
      begin
        open
        while (row = fetch) do
          break if row.size==0
          @count += 1
          row = row.symbolize_keys
          rc = yield row
          # TODO: Handle exceptions raised within block
          break if has_do_until && rc == @options[:until]
          break if has_do_while && rc != @options[:while]
        end
      rescue Exception => e
        close
        raise e
      end
    end
    @count
  end

  # Public: Opens (actually, "declares") the cursor. Call this before fetching
  def open
    set_cursor_tuple_fraction
    @cursor = @@cursor_seq += 1
    @result = @connection.execute("declare cursor_#{@cursor} cursor for #{@sql}")
    @block = []
  end

  # Public: Returns the next row from the cursor, or empty hash if end of results
  #
  # Returns a row as a hash of {'colname'=>value,...} 
  def fetch
    fetch_block if @block.size==0
    @block.shift
  end

  # Private: Fetches the next block of rows into @block
  def fetch_block(block_size=nil)
    block_size ||= @block_size ||= @options.fetch(:block_size) { 1000 }
    @result = @connection.execute("fetch #{block_size} from cursor_#{@cursor}")
    @block = @result.collect {|row| row } # Make our own
  end

  # Public: Closes the cursor
  def close
    @connection.execute("close cursor_#{@cursor}")
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

# Defines extension to ActiveRecord to use this library
class ActiveRecord::Base
  
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
    PostgreSQLCursor.new(sql, options).each(&block)
  end

  # Public: Returns each row as a model instance to the given block
  # As this instantiates a model object, it is slower than each_row_by_sql 
  #
  # Paramaters: see each_row_by_sql
  #
  # Returns the number of rows yielded to the block
  def self.each_instance_by_sql(sql, options={}, &block)
    PostgreSQLCursor.new(sql, options).each do |row|
      model = instantiate(row)
      yield model
    end
  end
end

# Defines extension to ActiveRecord/AREL to use this library
class ActiveRecord::Relation
  
  # Public: Executes the query, returning each row as a hash
  # to the given block.
  #
  # options     - Hash to control 
  #   fraction: 0.1..1.0    - The cursor_tuple_fraction (default 1.0)
  #   block_size: 1..n      - The number of rows to fetch per db block fetch
  #   while: value          - Exits loop when block does not return this value.
  #   until: value          - Exits loop when block returns this value.
  #
  # Returns the number of rows yielded to the block
  def each_row(options={}, &block)
    PostgreSQLCursor.new(to_sql).each(&block)
  end

  # Public: Like each_row, but returns an instantiated model object to the block
  #
  # Paramaters: same as each_row 
  #
  # Returns the number of rows yielded to the block
  def each_instance(options={}, &block)
    PostgreSQLCursor.new(to_sql, options).each do |row|
      model = instantiate(row)
      yield model
    end
  end
end
