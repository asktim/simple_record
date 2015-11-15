module Schema
  extend Forwardable

  def_delegator :"self.class", :columns

  def initialize(init_attrs = {})
    known_attributes = init_attrs.select{ |key, _| column_names.include?(key) }
    known_attributes.each do |key, value|
      self.public_send("#{ key }=", value)
    end
  end

  private

  def column_names
    columns.map { |c| c.name }
  end

  def attributes
    @attributes ||= {}
  end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    ID_ATTRIBUTE = 'id'

    @@columns = [Column.new(ID_ATTRIBUTE, :serial)]

    def table_name
      word = name
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.downcase!
      word
    end

    def connection
      SimpleRecord::connection
    end

    def columns
      @@columns
    end

    def attribute(name, typename, options = {})
      @@columns.push Column.new(name, typename)

      define_method("#{ name }=") do |value|
        attributes[name] = value
      end

      define_method("#{ name }") do
        attributes[name]
      end
    end

    def sql_create
      connection.exec <<-SQL
        CREATE TABLE #{ table_name } (
          #{ columns.map(&:sql_definition).join(', ') },
          CONSTRAINT #{ table_name }_pkey PRIMARY KEY (#{ ID_ATTRIBUTE })
        );
      SQL
    end

    def sql_drop
      connection.exec "DROP TABLE #{ table_name };"
    end
  end
end
