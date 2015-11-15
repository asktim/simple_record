require "pg"
require "simple_record/version"
require "simple_record/column"
require "simple_record/query"
require "simple_record/schema"

module SimpleRecord
  class << self
    attr_accessor :connection
  end
end
