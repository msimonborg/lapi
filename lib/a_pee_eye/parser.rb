
# frozen_string_literal: true

module APeeEye
  # Parses the response body and returns an array of response_objects.
  class Parser
    def self.parse(body, controller)
      if body.keys.first == 'self'
        klass = "#{api_module}::#{controller.to_s.classify}".constantize
        LazyRecord::Relation.new model: klass, array: [klass.new(body)]
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
      klass = "#{api_module}::#{resource.classify}".constantize
      LazyRecord::Relation.new model: klass,
                               array: memo + value.map { |val| klass.new(val) }
    end

    def self.api_module
      const_get('API_MODULE')
    end

    def self.resources
      const_get("#{api_module}::RESOURCES")
    end
  end
end
