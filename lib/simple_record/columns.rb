class Columns < Array
  def serial_column
    select { |c| c.serial? }.first
  end

  def value_columns
    select { |c| !c.serial? }
  end

  def value_names
    value_columns.map &:name
  end
end
