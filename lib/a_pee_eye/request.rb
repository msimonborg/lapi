# frozen_string_literal: true

module APeeEye
  # The Request module determines based on the :resource parameter which
  # Resource subclass to call for constructing the query to the API, and
  # returns an instance of that class.
  class Request
    def self.build(resource, id = nil)
      new_resource(resource, id) if resources.include?(resource.to_sym)
    end

    def self.new_resource(resource, id)
      const_get("API_MODULE::#{resource.to_s.camelize}").new(id)
    end

    def self.resources
      const_get('API_MODULE::RESOURCES')
    end
  end
end
