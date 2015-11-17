class Columns < Array
  def [](index)
    if index.is_a? Integer
      super(index)
    else
      find {|item| item.name == index.to_s }
    end
  end

  def serial_column
    find { |c| c.serial? }
  end

  def value_columns
    select { |c| !c.serial? }
  end

  def value_names
    value_columns.map &:name
  end
end
