require 'chronicle/etl/oauth_authorizer'

module Chronicle
  module Foursquare
    class Authorizer < Chronicle::ETL::OauthAuthorizer
      provider :foursquare
      omniauth_strategy :foursquare
      pluck_secrets({ 
        access_token: [:credentials, :token],
        uid: [:uid],
        first_name: [:info, :first_name],
        last_name: [:info, :last_name],
        email: [:info, :email],
      })
    end
  end
end
