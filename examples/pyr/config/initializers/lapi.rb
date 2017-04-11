# frozen_string_literal: true
require 'lapi'

LAPI.new :pyr do |api|
  api.base_uri = 'https://phone-your-rep.herokuapp.com/api/beta/'

  api.add_resource 'reps' do
    optional_params 'address', 'lat', 'long'

    add_attributes :self,
                   :state,
                   :district,
                   :active,
                   :bioguide_id,
                   :official_full,
                   :role,
                   :party,
                   :senate_class,
                   :last,
                   :first,
                   :middle,
                   :nickname,
                   :suffix,
                   :contact_form,
                   :url,
                   :photo,
                   :twitter,
                   :facebook,
                   :youtube,
                   :instagram,
                   :googleplus,
                   :twitter_id,
                   :facebook_id,
                   :youtube_id,
                   :instagram_id

    add_collections 'office_locations'

    add_scopes democratic: -> { where party: 'Democrat' },
               republican: -> { where party: 'Republican' },
               senators: -> { where role: 'United States Senator' },
               representatives: -> { where role: 'United States Representative' },
               state: ->(name) { where { |x| x.state.name == name } }
  end

  api.add_resource 'office_locations' do
    add_attributes :self,
                   :rep,
                   :active,
                   :office_id,
                   :bioguide_id,
                   :office_type,
                   :distance,
                   :building,
                   :address,
                   :suite,
                   :city,
                   :state,
                   :zip,
                   :phone,
                   :fax,
                   :hours,
                   :latitude,
                   :longitude,
                   :v_card_link,
                   :downloads,
                   :qr_code_link
  end

  api.add_resource 'v_cards'

  api.add_resource('zctas', 'zcta') do
    optional_params # some stuff
    add_attributes # some stuff
    add_scopes # some stuff
  end

  api.add_resource 'states' do
    add_attributes :self, :abbr, :state_code, :name
  end

  api.add_resource 'districts' do
    add_attributes :self, :code, :state_code, :full_code
  end
end

LAPI.new :airbnb do |api|
  api.base_uri = 'https://api.airbnb.com/v2/'
  api.key      = :client_id, '3092nxybyb0otqw18e8nh5nty'

  api.add_resource :reviews do
    required_params role: 'all'
    optional_params :listing_id, :locale, :currency

    add_attributes :author, :author_id, :recipient, :reviewer
  end

  api.add_resource :listings do
    required_params _format: 'v1_legacy_for_p3'

    add_attributes :city
  end

  api.add_resource :users do
    required_params _format: 'v1_legacy_show'
    optional_params :locale, :currency

    add_aliases :author, :recipient

    add_attributes :first_name, :has_profile_pic, :id, :picture_url, :smart_name, :thumbnail_url, :recent_review
  end

  api.add_resource :recent_reviews do
    add_attributes :review
  end

  api.add_resource :reviewers do
    add_attributes :user
  end
end
