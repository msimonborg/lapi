# frozen_string_literal: true

require 'httparty'

module LAPI
  # The object returned by a request call to the API.
  class Response
    attr_reader :body, :url, :code, :message, :headers, :objects, :controller

    def initialize(base_url: nil, resource: nil, response_object: nil)
      assign_url_and_controller(base_url, resource, response_object)
      fetch_and_parse_payload
      parse_objects if body.is_a? Hash
    end

    def assign_url_and_controller(base_url, resource, response_object)
      if base_url && resource
        @controller = resource.controller
        @url        = "#{base_url}#{resource}"
      elsif base_url
        @controller = base_url.sub(base_uri, '').split('/').first
        @url        = base_url
      elsif response_object
        @controller = response_object.controller
        @url        = response_object.self
      end
    end

    def base_uri
      self.class.const_get('BASE_URI')
    end

    def fetch_and_parse_payload
      payload  = HTTParty.get url
      @body    = payload.parsed_response
      @code    = payload.code
      @message = payload.message
      @headers = payload.headers
    end

    def parse_objects
      @objects = parser.parse(body, controller)
    end

    def parser
      self.class.send(:const_get, 'API_MODULE::Parser')
    end
  end
end
