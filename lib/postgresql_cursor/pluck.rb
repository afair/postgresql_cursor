class PostgreSQLCursor
  class Pluck
    class << self
      def joins_hash_from_columns_hash(columns, hash = {})
        case columns
        when Symbol, String
          # Just ignore it
        when Array
          columns.each do |col|
            joins_hash_from_columns_hash col, hash
          end
        when Hash
          columns.each do |k,v|
            cache = hash[k] ||= {}
            joins_hash_from_columns_hash v, cache
          end
        else
          raise ::ActiveRecord::ConfigurationError, columns.inspect
        end
        hash
      end

      def columns_array_from_columns_hash(base, columns_hash, columns_array = [])
        case columns_hash
        when Symbol, String
          column_name = if base.respond_to?(:attribute_aliases)
            base.attribute_aliases[columns_hash] || columns_hash
          else
            columns_hash
          end

          columns_array << base.arel_table[column_name].as("#{base.table_name}__#{column_name}")
        when Array
          columns_hash.each do |col|
            columns_array_from_columns_hash base, col, columns_array
          end
        when Hash
          columns_hash.each do |k,v|
            if association = base.reflect_on_association(k)
              columns_array_from_columns_hash association.klass, v, columns_array
            else
              raise ::ActiveRecord::ConfigurationError, "Association named '#{ k }' was not found on #{ base.name }; perhaps you misspelled it?"
            end
          end
        else
          raise ::ActiveRecord::ConfigurationError, columns_hash.inspect
        end
        columns_array
      end
    end

    module ActiveRecord
      def pluck_each(*column_names, &block)
        if ::ActiveRecord::VERSION::MAJOR == 3
          self.scoped
        else
          self.all
        end.pluck_each(*column_names, &block)
      end
    end

    module ActiveRecordRelation
      def pluck_each(*column_names, &block)
        to_join = []

        column_names.map! do |column_name|
          if column_name.is_a?(Symbol) && self.respond_to?(:attribute_aliases) && attribute_aliases.has_key?(column_name.to_s)
            attribute_aliases[column_name.to_s]
          elsif column_name.is_a?(Hash)
            to_join << PostgreSQLCursor::Pluck.joins_hash_from_columns_hash(column_name)
            PostgreSQLCursor::Pluck.columns_array_from_columns_hash(@klass, column_name)
          elsif column_name.is_a?(Arel::Attributes::Attribute) || column_name.is_a?(Arel::Nodes::As)
            column_name
          else
            column_name.to_s
          end
        end.flatten!

        if self.respond_to?(:construct_relation_for_association_calculations) && has_include?(column_names.first)
          construct_relation_for_association_calculations.joins(to_join).pluck_each(*column_names, &block)
        else
          relation = clone.joins(to_join)
          relation.select_values = column_names.map { |cn|
            columns_hash.key?(cn) ? arel_table[cn] : cn
          }

          cursor = PostgreSQLCursor.new(relation.to_sql)

          if ::ActiveRecord::VERSION::MAJOR == 3
            cursor.each{ |row| block.call(row.values) }
          else
            columns = column_names.map do |key|
              klass.column_types.fetch(key) {
                case key
                when Arel::Attributes::Attribute
                  key.relation.engine.column_types.fetch(key.name.to_s)
                when Arel::Nodes::As
                  key.left.relation.engine.column_types.fetch(key.left.name.to_s)
                else
                  nil
                end
              }
            end

            cursor.each do |row|
              values = columns.zip(row.values).map do |column, value|
                column ? column.type_cast(value) : value
              end
              block.call(values)
            end
          end
        end
      end
    end
  end
end