class Column
  class UnknownTypeException < Exception
  end

  SQL_TYPE_MAP = {
    serial: 'serial NOT NULL',
    integer: 'integer',
    string: 'character varying(255)',
    text: 'text'
  }

  SQL_CAST_MAP = {
    serial: ->(val) { Integer(val) },
    integer: ->(val) { Integer(val) },
    string: ->(val) { val },
    text: ->(val) { val }
  }

  attr_reader :name

  def initialize(name, typename)
    unless SQL_TYPE_MAP.keys.include?(typename)
      raise UnknownTypeException.new('Unknown column type.')
    end

    @name = name
    @typename = typename
  end

  def cast(value)
    SQL_CAST_MAP[@typename].call(value)
  end

  def serial?
    @typename == :serial
  end

  def sql_definition
    "#{ name } #{ sql_typename }"
  end

  private

  def sql_typename
    SQL_TYPE_MAP[@typename]
  end
end
