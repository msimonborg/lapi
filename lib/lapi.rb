# frozen_string_literal: true

require 'lapi/api'
require 'lapi/param'
require 'lapi/parser'
require 'lapi/request'
require 'lapi/resource'
require 'lapi/resource_builder'
require 'lapi/response'
require 'lapi/response_object'
require 'lapi/version'

# LAPI gives you a convenient interface for dealing with
# external APIs.
#
# See examples/ for more detailed code examples.
#
# Configure a new API by calling LAPI.new(api_name, &block)
#
# The api_name argument can be a string or symbol.
#
# LAPI.new('airbnb') will create a new Module called LAPI::Airbnb.
# API modules follow the rails/active_support naming conventions.
# The argument you pass to LAPI.new will receive #to_s and
# String#camelize before being set as a new constant in the LAPI scope.
#
# The new API module will yield to a block, allowing you to configure the
# base URI, access key, and the API resources and their properties.
#
# Basic usage:
#
# Lapi.new :airbnb do |api|
#   api.base_uri = 'https://api.airbnb.com/v2/'
#   api.key      = :client_id, 'secret_key'
#
#   api.add_resource :reviews do
#     required_params role: 'all'
#     optional_params :listing_id, :locale, :currency
#
#     add_attributes :author, :author_id, :recipient, :reviewer
#   end
#
#   api.add_resource :users do
#     required_params _format: 'v1_legacy_show'
#     optional_params :locale, :currency
#
#     add_aliases :author, :recipient
#
#     add_attributes :first_name, :has_profile_pic, :id, :recent_review
#
#   api.add_resource :recent_reviews do
#     add_attributes :review
#   end
# end
#
# API.base_uri= sets the base URI for all requests. It should end with '/'
#
# API.key= takes an array argument. The first element is the name of the
# key param, the second is the value. e.g. API.key = 'secret', 'key'
# would translate to "secret=key" in the URI, and will be used
# as a param into in every request.
#
# Any string or symbol passed to API.add_resource will result in two
# new classes, both namespaced within the new API module.
#
# For example, LAPI.new :airbnb { |api| api.add_resource 'listings' }
# will produce LAPI::Airbnb::Listings, which is the resource object
# that handles constructing the web request,
# and LAPI::Airbnb::Listing, which is the response object that handles
# the data response.
#
# If the names are irregular and need special rules for converting
# from plural to singular, or you need to specify different names
# for the resource and response objects, you can pass the singular,
# or response object, name as the second argument to API#add_resource.
#
# e.g. api.add_resource 'mice', 'mouse'
#
# You can configure both of these objects at once by passing a block
# to API.add_resource, which will open instance_eval on an instance of a
# ResourceBuilder. The ResourceBuilder is responsible for carrying
# your instructions to the newly created objects where they can
# be properly defined.
#
# ResourceBuilder#required_params takes a set of key value pairs that
# will be included with every request for that particular resource.
#
# ResourceBuilder#optional_params takes an array of param names that
# may or may not be used and whose values will be set at the time of
# the request. The params are attributes of the resource object.
#
# ResourceBuilder#add_attributes adds data attributes to the response
# object, creating getter and setter methods that allow you to retrieve
# and operate on the data. Attributes can be other response objects.
#
# e.g.
# api.add_resource :listings { add_attributes :user }
# api.add_resource :users
#
# By declaring :users as a resource LAPI will turn any data structure
# with a "user" key into a User response object, as long as it is
# declared as an attribute of that resource. Resources can be nested
# as deep as you need them to be.
#
# LAPI will also recognize an array of :users at any level of nesting,
# converting it into a collection of User response objects that will
# respond to declared scope methods, so long as the key of the key value
# pair is the expected plural form ("users"), and you add it as a collection.
#
# e.g.
# api.add_resource :listings { add_collections :users }
#
# You need to explicitly declare the attributes you'd like to access on
# each resource, otherwise they will be ignored.
module LAPI
  # LAPI.new 'name' do |api|
  #   api.base_uri = 'www.example.com/'
  #
  #   api.add_resource 'resources' do
  #     optional_params 'param'
  #     add_attributes 'attribute'
  #   end
  # end
  #
  # response = LAPI::Name.call('resources') { |r| r.param = 'optional' }
  #
  # response.uri
  # => "www.example.com/resources?param=optional"
  # response.objects
  # => #<LAPI::Name::ResourceRelation [#<LAPI::Name::Resource id: 1, attribute: "data">]> # rubocop:disable Style/LineLength
  # response.objects.first.attribute
  # => "data"
  #
  def self.new(name)
    api = set_or_get_constant(name.to_s.camelize, Module.new)
    api.extend(API)
    apis << api unless apis.include?(api)
    yield api if block_given?
    api.create_scoped_constants unless api.constants_created?
    api
  end

  def self.apis
    @apis ||= []
  end

  module_function

  def set_or_get_constant(const_name, object)
    if const_defined?(const_name)
      const_get(const_name)
    else
      const_set(const_name, object)
    end
  end
end
