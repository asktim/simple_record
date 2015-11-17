class Query
  include Enumerable

  SQL = 'SELECT * FROM %{table} WHERE %{condition}'

  def initialize(owner)
    @owner = owner
    @sequence = []
  end

  def where(sql, *params)
    @sequence << [sql, params]
    self
  end

  def each(&block)
    condition, condition_params = @sequence.transpose
    condition = condition.join(' AND ')
    condition = condition.gsub(/\?/).with_index { |p, i| "$#{ i + 1 }" }
    sql = SQL % { table:  @owner.table_name, condition: condition }
    result = SimpleRecord.connection.exec_params(
      sql, condition_params.flatten
    )
    result.each do |row|
      block.call @owner.new(row)
    end
  end
end
