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
