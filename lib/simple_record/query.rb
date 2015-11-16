class Query
  include Enumerable

  def initialize(owner)
    @owner = owner
    @sequence = []
  end

  def where(sql, params = [])
    @sequence << [sql, params]
    self
  end

  def each(&block)
    condition, condition_params = @sequence.transpose
    condition = condition.join(' AND ')
    condition = condition.gsub(/\?/).with_index { |p, i| "$#{ i + 1 }" }
    sql = "SELECT * FROM #{ @owner.table_name } WHERE #{ condition }"
    result = SimpleRecord.connection.exec_params(
      sql, condition_params.flatten
    )
    result.each do |row|
      block.call @owner.new(row)
    end
  end
end
