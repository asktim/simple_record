class Column
  attr_reader :name

  def initialize(name, typename)
    @name = name
    @typename = typename
  end
end
