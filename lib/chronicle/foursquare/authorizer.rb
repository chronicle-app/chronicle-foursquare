require 'chronicle/etl/oauth_authorizer'

module Chronicle
  module Foursquare
    class Authorizer < Chronicle::ETL::OauthAuthorizer
      provider :foursquare
      omniauth_strategy :foursquare
      pluck_secrets({
        access_token: %i[credentials token],
        uid: [:uid],
        first_name: %i[info first_name],
        last_name: %i[info last_name],
        email: %i[info email]
      })
    end
  end
end
