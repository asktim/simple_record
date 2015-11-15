class Column
  attr_reader :name

  def initialize(name, typename)
    @name = name
    @typename = typename
  end

  def sql_definition
    "#{ name } #{ sql_typename }"
  end

  private

  def sql_typename
    { serial: 'serial NOT NULL',
      integer: 'integer',
      string: 'character varying(255)',
      text: 'text'
    }[@typename]
  end
end
