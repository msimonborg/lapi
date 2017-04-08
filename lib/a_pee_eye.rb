# frozen_string_literal: true

require 'lazy_record'

require 'a_pee_eye/response_object'
require 'a_pee_eye/version'

module APeeEye
  def self.configure(string)
    api_name = string.camelize
    api = if const_defined?(api_name)
            const_get(api_name)
          else
            const_set(api_name, Module.new)
          end
    api.extend(API)
    yield api if block_given?
    api.const_set('RESOURCES', api.resources)
    api.create_response_objects
    # api.create_resource_objects
    api
  end

  module API
    attr_reader :base_uri

    def base_uri=(value)
      raise ArgumentError.new('Base URI can\'t be assigned more than once') if base_uri
      @base_uri = value
    end

    def resources
      @resources.dup.freeze
    end

    def add_resource(plural, singular = nil)
      add_inflection(plural, singular) if singular
      @resources ||= []
      @resources << plural.to_sym
    end

    def add_inflection(plural, singular)
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.irregular singular, plural
      end
    end

    def create_response_objects
      resources.each do |resource|
        klass = const_set(resource.to_s.classify, Class.new(ResponseObject))
        klass.const_set('API_MODULE', self)
      end
    end

    def call(resource, id = nil)
      if resource.is_a?(APeeEye::ResponseObject)
        request_object = { response_object: resource }
      elsif resource.to_s.include? base_uri
        request_object = { base_url: resource }
      else
        resource = Request.build(resource, id)
        yield resource if block_given?
        request_object = { base_url: base_uri, resource: resource }
      end
      Response.new request_object
    end
  end
end

APeeEye.configure('Dog') do |dog|
  dog.base_uri = 'hello'
  dog.add_resource('cats')
  dog.add_resource('buffalo', 'cowboy')
end