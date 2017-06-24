# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

module LAPI
  # The object returned by a request call to the API.
  class Response
    attr_reader :body, :url, :code, :message, :headers, :objects, :path, :controller

    def initialize(base_url: nil, resource: nil, response_object: nil)
      assign_url_and_controller(base_url, resource, response_object)
    end

    def get
      fetch_and_parse_payload
      parse_objects if body.is_a? Hash
      self
    end

    def assign_url_and_controller(base_url, resource, response_object)
      if resource
        binding.pry
        @controller = resource.controller
        @path       = resource.to_s
      elsif base_url
        @path       = base_url.sub(base_uri, '')
        @controller = path.split('/').first
      elsif response_object
        @controller = response_object.controller
        @path       = response_object.self.sub(base_uri, '')
      end
    end

    def base_uri
      self.class.const_get('BASE_URI')
    end

    def api_conn
      self.class.const_get('API_CONN')
    end

    def fetch_and_parse_payload
      binding.pry
      payload  = api_conn.get path
      @body    = payload.body
      @code    = payload.status
      @message = payload.reason_phrase
      @headers = payload.headers
    end

    def parse_objects
      @objects = parser.parse(body, controller)
    end

    def parser
      self.class.const_get('API_MODULE::Parser')
    end
  end
end
