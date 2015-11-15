class Query < Enumerator::Lazy
  def where(string, params = [])
    self << [string, params]
  end

  def to_a
    sql, sql_params = super.transpose
    sql = sql.join(' AND ')
    sql = sql.gsub(/\?/).with_index { |p, i| "$#{ i + 1 }" }
    SimpleRecord.connection.exec_param sql, sql_params.flatten
  end
end
