# frozen_string_literal: true

require 'lazy_record'

require 'a_pee_eye/param'
require 'a_pee_eye/parser'
require 'a_pee_eye/request'
require 'a_pee_eye/resource'
require 'a_pee_eye/response'
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
    api.create_response_class
    api.create_parser_class
    api.create_request_class
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
      @resources ||= []
      @resources << plural.to_sym
      add_inflection(plural, singular) if singular
      resource_builder = ResourceBuilder.new
      yield resource_builder if block_given?
      response_object = const_set(plural.to_s.classify, Class.new(ResponseObject))
      response_object.const_set('API_MODULE', self)
      response_object.class_eval do
        lr_attr_accessor *resource_builder.attributes
        lr_has_many *resource_builder.children
        resource_builder.scopes.each do |k, v|
          lr_scope k, v
        end
      end
      resource_object = const_set(plural.to_s.camelize, Class.new(Resource))
      resource_object.class_eval do
        resource_builder.params.each do |param|
          define_method "#{param}=" do |value|
            instance_variable_set("@#{param}", Param.new(param.to_sym, value))
            self.class.send(:params) << instance_variable_get("@#{param}")
          end
        end
        self.class.send(:attr_reader, *resource_builder.params)
      end
    end

    def add_inflection(plural, singular)
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.irregular singular, plural
      end
    end

    def create_response_class
      klass = const_set('Response', Class.new(Response))
      klass.const_set('BASE_URI', base_uri)
      klass.const_set('API_MODULE', self)
    end

    def create_parser_class
      klass = const_set('Parser', Class.new(Parser))
      klass.const_set('API_MODULE', self)
    end

    def create_request_class
      klass = const_set('Request', Class.new(Request))
      klass.const_set('API_MODULE', self)
    end

    def call(resource, id = nil)
      if resource.is_a?(APeeEye::ResponseObject)
        request_object = { response_object: resource }
      elsif resource.to_s.include? base_uri
        request_object = { base_url: resource }
      else
        resource = self::Request.build(resource, id)
        yield resource if block_given?
        request_object = { base_url: base_uri, resource: resource }
      end
      self::Response.new request_object
    end

    class ResourceBuilder
      def params
        @params ||= []
      end

      def attributes
        @attributes ||= []
      end

      def children
        @has_many ||= []
      end

      def scopes
        @scopes ||= {}
      end

      def add_params(*args)
        @params = args
      end

      def add_attributes(*args)
        @attributes = args
      end

      def has_many(*args)
        @has_many = args
      end

      def add_scopes(**args)
        @scopes = args
      end
    end
  end
end

APeeEye.configure('PYR') do |pyr|
  pyr.base_uri = 'https://phone-your-rep.herokuapp.com/api/beta/'

  pyr.add_resource('reps') do |reps|
    reps.add_params 'address', 'lat', 'long'
    reps.add_attributes 'self', 'official_full', 'party'
    reps.has_many 'office_locations'
    reps.add_scopes democratic: -> { where party: 'Democrat' },
                    republican: -> { where party: 'Republican' }
  end

  pyr.add_resource('office_locations') do |off|
    off.add_attributes 'self', 'city'
  end
end