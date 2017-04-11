# frozen_string_literal: true

require 'lazy_record'

module LAPI
  # The ResponseObject is the parent class of all objects instantiated
  # from the response body.
  class ResponseObject < LazyRecord::Base
    def initialize(opts = {})
      new_opts = opts.each_with_object({}) do |(key, val), memo|
        memo[key] = map_key_to_a_resource(key, val) || val
      end
      super(new_opts)
    end

    def map_key_to_a_resource(key, val)
      key_to_sym, singular_key_to_sym = plural_and_singular_key_to_sym(key)
      if resources_include_key?(key)
        objectify(key, val)
      elsif aliases_include?(key_to_sym)
        new_response_object(aliases[key_to_sym], val)
      elsif aliases_include?(singular_key_to_sym)
        objectify(aliases[singular_key_to_sym], val)
      elsif resources_include_singular_object?(key, val)
        new_response_object(key, val)
      end
    end

    def plural_and_singular_key_to_sym(key)
      [key.to_sym, key.to_s.singularize.to_sym]
    end

    def aliases_include?(key)
      aliases.include?(key)
    end

    def new_response_object(name, opts)
      "#{api}::#{name.to_s.classify}".constantize.new(opts)
    end

    def resources_include_singular_object?(key, val)
      resources_include_key?(key.to_s.pluralize) && val.is_a?(Hash)
    end

    def resources_include_key?(key)
      resources.include?(key.to_sym)
    end

    def objectify(name, array)
      array.map { |obj| "#{api}::#{name.to_s.classify}".constantize.new(obj) }
    end

    def api
      self.class.const_get('API_MODULE')
    end

    def resources
      self.class.const_get("#{api}::RESOURCES")
    end

    def aliases
      self.class.const_get("#{api}::ALIASES")
    end

    def controller
      @controller ||= self.class.to_s.split('::').last.tableize
    end
  end
end
