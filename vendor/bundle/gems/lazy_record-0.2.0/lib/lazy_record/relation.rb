# frozen_string_literal: true

module LazyRecord
  class Relation
    include Enumerable

    attr_reader :model, :all

    def initialize(model:, array: nil)
      raise ArgumentError, 'model must be a class' unless model.is_a?(Class)
      @model = model
      @all   = []
      self_extend_scopes_module
      array&.each do |object|
        @all << object && next if object.is_a?(model)
        message = "Argument must be a collection of #{model.to_s.tableize}"
        raise ArgumentError, message
      end
    end

    def <<(other)
      message = "object must be of type #{model}"
      raise ArgumentError, message unless other.is_a?(model)
      all << other
    end

    def inspect
      "\#<#{model}Relation [#{all.map(&:inspect).join(', ')}]>"
    end

    def where(condition = nil)
      result = all.select do |x|
        if condition.is_a? Hash
          condition.all? do |key, val|
            val = val.call if val.is_a? Proc
            x.send(key) == val
          end
        elsif block_given?
          yield x
        elsif condition
          eval "x.#{condition}"
        end
      end
      self.class.new(model: model, array: result)
    end

    def each(&block)
      all.each(&block)
    end

    def [](index)
      all[index]
    end

    def last
      self[-1]
    end

    def clear
      all.clear
    end

    private :clear, :all

    def self_extend_scopes_module
      return unless model.const_defined?(:ScopeMethods, _search_ancestors = false)
      extend(model::ScopeMethods)
    end
  end
end
