# frozen_string_literal: true

module LAPI
  # Resource and its subclasses accept attribute params and,
  # in conjunction with the Param class,
  # convert them to a URI friendly string
  class Resource
    attr_reader :id

    def self.params
      @params ||= []
    end

    def initialize(id)
      self.id = id
    end

    def controller
      self.class.to_s.split('::').last.to_s.underscore
    end

    def id=(value)
      @id = Param.new(:id, value, id: true) if value
    end

    def to_s
      "#{controller}#{id}?#{self.class.send(:params).map(&:to_s).join('&')}"
    end
  end
end
