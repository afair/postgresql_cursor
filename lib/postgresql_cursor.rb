require 'active_record'
#require 'postgresql_adapter'

class PostgreSQLCursor
  attr_accessor :count
  @@counter=0
  
  def initialize(instantiator, sql,*args)
    @options = args.last.is_a?(Hash) ? args.pop : {}
    @@counter += 1
    @instantiator = instantiator
    @sql = sql
    @name = "pgcursor_#{@@counter}"
    @connection = ActiveRecord::Base.connection
    @buffer_size = @options[:buffer_size] || 10_000 
    @count = 0
  end
  
  # Iterates through the rows, yields them to the block
  def each
    @connection.transaction do
      @result = open_cursor
      while (row = fetch_cursor) do
        yield row
      end
      close_cursor
      @count
    end
  end
  
  def size
    @sql = replace_params(*(@sql.flatten)) if @sql.is_a?(Array)
    sql = @sql.sub(/^(select) (.+) (from .+)/i, '\1 count(*) \3')
    @result = @connection.execute("declare #{@name} cursor for #{@sql}")
  end
  
  # Starts buffered result set processing for a given SQL statement. The DB
  def open_cursor
    @sql = replace_params(*(@sql.flatten)) if @sql.is_a?(Array)
    #@connection.start_transaction if @connection.outside_transaction?
    @result = @connection.execute("declare #{@name} cursor for #{@sql}")
    @state = :empty
    @buffer = nil
  end
  
  # Fetches the next block of rows into memory
  def fetch_buffer #:nodoc:
    return unless @state == :empty
    @result = @connection.execute("fetch #{@buffer_size} from #{@name}")
    @buffer = @result.collect {|row| row }
    @state  = @buffer.size > 0 ? :buffered : :eof
    @buffer
  end

  # Returns the next row from the cursor, or nil when end of data.
  # The row returned is a hash[:colname]
  def fetch_cursor
    fetch_buffer if @state == :empty
    return nil   if @state == :eof
    @state = :empty if @buffer.size <= 1
    @count+= 1
    row = @buffer.shift
    #row.is_a?(Hash) ? row.symbolize_keys : row
    @instantiator.call(row)
  end
  
  alias_method :next, :fetch_cursor
  
  # Closes the cursor to clean up resources
  def close_cursor
    pg_result = @connection.execute("close #{@name}")
  end
  
end

class ActiveRecord::Base
  class <<self
  
    # Returns a PostgreSQLCursor instance to access the results
    def find_with_cursor(*args)
      find_options = args.last.is_a?(Hash) ? args.pop : {}
      options = find_options.delete(:cursor) || {}
      validate_find_options(find_options)
      set_readonly_option!(find_options)
      sql = construct_finder_sql(find_options)
      PostgreSQLCursor.new(lambda {|r| instantiate(r)}, sql, options)
      #PostgreSQLCursor.new(sql, options)
    end
  
    # Returns a PostgreSQLCursor instance to access the results of the sql
    def find_by_sql_with_cursor(sql, options={})
      PostgreSQLCursor.new(lambda {|r| instantiate(r)}, sql, options)
    end

    def fetch_cursor(record)
      instantiate(record)
    end
  
  end
end
