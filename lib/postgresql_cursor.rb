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
    @connection = ActiveRecord.connection
    @buffer_size = @options[:buffer_size] || 10_000 
    @count = 0
  end
  
  # Takes arguments like ActiveRecord#find and returns a cursor object ready to consume
  def self.find(instantiator, *findargs)
    options = findargs.last.is_a?(Hash) && findargs.last.delete(:cursor) || {}
    validate_find_options(:all, *findargs)
    set_readonly_option!(findargs)
    sql = construct_finder_sql(:all, *findargs)
    PostgreSQLAdapter.new(sql, options)
  end
  
  # Iterates through the rows, yields them to the block
  def each
    @result = ActiveRecord.connection.open_cursor(@sql, @options)
    while (row = fetch_cursor) do
      yield row
    end
    close_cursor(@name)
    @count
  end
  
  def size
    @sql = replace_params(*(@sql.flatten)) if @sql.is_a?(Array)
    sql = @sql.sub(/^(select) (.+) (from .+)/i, '\1 count(*) \3')
    @result = @connection.execute("declare #{@name} cursor for #{@sql}")
  end
  
  # Starts buffered result set processing for a given SQL statement. The DB
  def open_cursor
    @sql = replace_params(*(@sql.flatten)) if @sql.is_a?(Array)
    @result = @connection.execute("declare #{@name} cursor for #{@sql}")
    @state = :empty
    @buffer_size = buffer_size
    @buffer = nil
  end
  
  # Fetches the next block of rows into memory
  def fetch_buffer() #:nodoc:
    return unless @state == :empty
    @result = @connection.execute("fetch #{@buffer_size} from #{@name}")
    @buffer = @result.collect {|row| row }
    @state  = @buffer.size > 0 ? :buffered : :eof
    @buffer
  end

  # Returns the next row from the cursor, or nil when end of data.
  # The row returned is a hash[:colname]
  def fetch_cursor()
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
  def close_cursor(name='csr')
    pg_result = @connection.execute("close #{@name}")
  end
  
end

class ActiveRecord::Base
  class <<self
  
    # Returns a PostgreSQLCursor instance to access the results
    def find_with_cursor(*findopts)
      puts findopts.inspect
      options = findopts.last.is_a?(Hash) && findopts.last.delete(:cursor) || {}
      validate_find_options(findopts)
      #set_readonly_option!(findopts)
      sql = construct_finder_sql(findopts)
      PostgreSQLAdapter.new(lambda {|r| instantiate(r)}, sql, options)
    end
  
    # Returns a PostgreSQLCursor instance to access the results of the sql
    def find_by_sql_with_cursor(sql, options={})
      PostgreSQLCursor.new(lambda {|r| instantiate(r)}, sql, options)
    end
  
  end
end