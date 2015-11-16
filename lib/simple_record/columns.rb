class Columns < Array
  def value_columns
    select { |c| !c.serial? }
  end

  def value_names
    value_columns.map &:name
  end
end
