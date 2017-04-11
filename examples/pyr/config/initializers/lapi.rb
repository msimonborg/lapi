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

  api.add_resource('zctas', 'zcta') { optional_params :reps }

  api.add_resource 'states' do
    add_attributes :self, :abbr, :state_code, :name
  end

  api.add_resource 'districts' do
    add_attributes :self, :code, :state_code, :full_code
  end
end
