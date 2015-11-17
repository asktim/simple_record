class Query
  include Enumerable

  SQL = 'SELECT * FROM %{table} WHERE %{condition}'

  attr_reader :owner

  def initialize(owner, sql, *params)
    @owner = owner
    @sql = sql
    @params = params
  end

  def where(sql, *params)
    self.class.new(self, sql, *params)
  end

  def each(&block)
    condition, condition_params = clause.transpose
    condition = condition.join(' AND ')
    condition = condition.gsub(/\?/).with_index { |p, i| "$#{ i + 1 }" }
    sql = SQL % { table:  holder.table_name, condition: condition }
    result = SimpleRecord.connection.exec_params(
      sql, condition_params.flatten
    )
    result.each do |row|
      block.call holder.new(row)
    end
  end

  protected

  def holder
    @holer ||= owner.is_a?(self.class) ? owner.holder : owner
  end

  def clause
    if owner.is_a? self.class
      owner.clause << [@sql, @params]
    else
      []
    end
  end
end
