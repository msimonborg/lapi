# frozen_string_literal: true

require 'httparty'

module LAPI
  # The object returned by a request call to the API.
  class Response
    attr_reader :body, :url, :code, :message, :headers, :objects, :path, :controller

    def initialize(base_url: nil, resource: nil, response_object: nil)
      assign_url_and_controller(base_url, resource, response_object)
    end

    def get
      fetch_and_parse_payload
      parse_objects
      self
    end

    def assign_url_and_controller(base_url, resource, response_object)
      if resource
        @controller = resource.controller
        @path       = "#{base_uri}#{resource}"
      elsif base_url
        @path       = base_url
        @controller = path.sub(base_uri, '').split('/').first
      elsif response_object
        @controller = response_object.controller
        @path       = response_object.self
      end
    end

    def base_uri
      self.class.const_get('BASE_URI')
    end

    def fetch_and_parse_payload
      payload  = HTTParty.get path
      @body    = payload.parsed_response
      @code    = payload.code
      @message = payload.message
      @headers = payload.headers
    end

    def parse_objects
      @objects = if body.is_a?(Hash)
                   parser.parse(body, controller)
                 elsif body.is_a?(Array)
                   LazyRecord::Relation.new(
                      model: resource_class, array: body.map { |h| resource_class.new(h) }
                   )
                 end
    end

    def parser
      self.class.const_get("#{api}::Parser")
    end

    def api
      @api ||= self.class.const_get('API_MODULE')
    end

    def resource_class
      "#{api}::#{controller.to_s.classify}".constantize
    end
  end
end
