module Schema
  extend Forwardable

  def_delegator :"self.class", :columns

  def initialize(init_attrs = {})
    known_attributes = init_attrs.select{ |key, _| column_names.include?(key) }
    known_attributes.each do |key, value|
      self.public_send("#{ key }=", value)
    end
  end

  private

  def column_names
    columns.map { |c| c.name }
  end

  def attributes
    @attributes ||= {}
  end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    @@columns = []

    def columns
      @@columns
    end

    def attribute(name, typename, options = {})
      @@columns.push Column.new(name, typename)

      define_method("#{ name }=") do |value|
        attributes[name] = value
      end

      define_method("#{ name }") do
        attributes[name]
      end
    end
  end
end
