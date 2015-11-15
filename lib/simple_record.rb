require "pg"
require "simple_record/version"
require "simple_record/column"
require "simple_record/schema"

module SimpleRecord
  def self.connection=(connection)
    @connection = connection
  end
end
