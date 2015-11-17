module Schema
  extend Forwardable

  ID_ATTRIBUTE = 'id'
  SQL_INSERT = 'INSERT INTO %{table} (%{columns}) VALUES(%{values});'
  SQL_DT_CREATE = 'CREATE TABLE %{table} (%{columns}, CONSTRAINT %{table}_pkey PRIMARY KEY (%{pkey}));'
  SQL_DT_DROP = 'DROP TABLE %{table};'

  def_delegators :"self.class", :columns, :connection, :table_name

  attr_reader :primary_key

  def initialize(attrs = {})
    known_attrs(attrs).each do |key, value|
      public_send("#{ key }=", value)
    end

    init_primary_key(attrs[columns.serial_column.name])
  end

  def create
    params = to_sql_params
    params_sql = (1..params.size).map { |i| "$#{ i }" }.join(', ')
    connection.exec_params(
      SQL_INSERT % { table: table_name, columns: known_keys.join(', '), values: params_sql },
      params
    )
  end

  def persisted?
    !@primary_key.nil?
  end

  private

  def init_primary_key(key)
    @primary_key = nil
    @primary_key = columns[ID_ATTRIBUTE].cast(key) if key
  end

  def known_keys
    columns.value_names
  end

  def known_attrs(attrs)
    attrs.select { |key, _| known_keys.include?(key) }
  end

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
    # Define finding scopes
    # CODE: Article.where('name = ?', ['John Doe'])
    def where(query, *params)
      Query.new(self, query, *params)
    end

    def table_name
      word = name
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.downcase!
      word
    end

    def connection
      SimpleRecord.connection
    end

    def columns
      @columns ||= Columns.new [Column.new(ID_ATTRIBUTE, :serial)]
    end

    def attribute(name, typename, options = {})
      columns.push Column.new(name, typename)

      define_method("#{ name }=") do |value|
        attributes[name] = columns[name].cast(value)
      end

      define_method("#{ name }") do
        attributes[name]
      end
    end

    def dt_create
      connection.exec SQL_DT_CREATE % {
        table: table_name,
        columns: columns.map(&:sql_definition).join(', '),
        pkey: ID_ATTRIBUTE
      }
    end

    def dt_drop
      connection.exec SQL_DT_DROP % { table: table_name }
    end
  end
end
