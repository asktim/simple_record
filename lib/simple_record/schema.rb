module Schema
  extend Forwardable

  def_delegators :"self.class", :columns, :connection, :table_name

  def initialize(init_attrs = {})
    known_attributes = init_attrs.select { |key, _| columns.value_names.include?(key) }
    known_attributes.each do |key, value|
      self.public_send("#{ key }=", value)
    end
  end

  def create
    params = to_sql_params
    params_sql = (1..params.size).map { |i| "$#{ i }" }.join(', ')
    connection.exec_params(<<-SQL, params)
      INSERT INTO #{ table_name }
      (#{ columns.value_names.join(', ') })
      VALUES(#{ params_sql })
    SQL
  end

  private

  def to_sql_params
    columns.value_names.map { |name| attributes[name] }
  end

  def attributes
    @attributes ||= {}
  end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    ID_ATTRIBUTE = 'id'

    def where(query, params = [])
      Query.new do |fetcher|
        fetcher << [query, params]
      end
    end

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
      @columns ||= Columns.new [Column.new(ID_ATTRIBUTE, :serial)]
    end

    def attribute(name, typename, options = {})
      columns.push Column.new(name, typename)

      define_method("#{ name }=") do |value|
        attributes[name] = value
      end

      define_method("#{ name }") do
        attributes[name]
      end
    end

    def dt_create
      connection.exec <<-SQL
        CREATE TABLE #{ table_name } (
          #{ columns.map(&:sql_definition).join(', ') },
          CONSTRAINT #{ table_name }_pkey PRIMARY KEY (#{ ID_ATTRIBUTE })
        );
      SQL
    end

    def dt_drop
      connection.exec "DROP TABLE #{ table_name };"
    end
  end
end
