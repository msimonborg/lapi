# frozen_string_literal: true

LAPI.configure('pyr') do |config|
  config.base_uri = 'https://phone-your-rep.herokuapp.com/api/beta/'

  config.add_resource('reps') do
    add_params 'address', 'lat', 'long'
    add_attributes :self,
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
               representatives: -> { where role: 'United States Representative' }
  end

  config.add_resource('office_locations') do
    add_attributes :self,
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

  config.add_resource('v_cards')

  config.add_resource('zctas', 'zcta') do
    add_params # some stuff
    add_attributes # some stuff
    add_scopes # some stuff
  end
end
