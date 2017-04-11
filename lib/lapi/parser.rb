
# frozen_string_literal: true

module LAPI
  # Parses the response body and returns an array of response_objects.
  class Parser
    def self.parse(body, controller)
      first_key = body.keys.first
      klass = "#{api}::#{controller.to_s.classify}".constantize
      case first_key
      when 'self'
        LazyRecord::Relation.new model: klass, array: [klass.new(body)]
      when controller.to_s.singularize
        LazyRecord::Relation.new model: klass, array: [klass.new(body.values.first)]
      else
        reduce_body(body)
      end
    end

    def self.reduce_body(body)
      body.reduce([]) do |memo, (key, value)|
        if resources.include?(key.to_sym)
          convert_to_relation(key, memo, value)
        else
          memo
        end
      end
    end

    def self.convert_to_relation(resource, memo, value)
      klass = "#{api}::#{resource.classify}".constantize
      LazyRecord::Relation.new model: klass,
                               array: memo + value.map { |val| klass.new(val) }
    end

    def self.api
      const_get('API_MODULE')
    end

    def self.resources
      const_get("#{api}::RESOURCES")
    end
  end
end
