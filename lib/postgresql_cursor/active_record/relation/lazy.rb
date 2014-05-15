# Experiment: see if we can implement lazy enumerators with cursor!

module PostgreSQLCursor
  module ActiveRecord
    module Relation
      module Lazy

        def lazy(options={}, &block)
          options = {:connection => self.connection}.merge(options)
          PostgreSQLCursor.new(to_sql, options).each(&block)
        end

      end
    end
  end
end
