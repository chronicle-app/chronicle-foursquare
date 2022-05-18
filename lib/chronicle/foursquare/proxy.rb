require 'faraday'

module Chronicle
  module Foursquare
    class Proxy
      API_VERSION = 20170310

      def initialize(access_token: )
        @access_token = access_token
      end

      def load_visits(since: nil, limit: nil)
        has_more = true
        visits = []
        count = 0

        while has_more
          results = load_checkins(limit: 50, offset: count, since: since)
          results = results.first(limit - count) if limit
          visits += results

          count += results.length
          has_more = results.any?
        end
        visits
      end

      def load_self
        load_endpoint('users/self')[:response][:user]
      end

      def load_checkins(limit: 50, offset: 0, since: nil)
        params = {
          limit: limit,
          offset: offset,
          afterTimestamp: since.to_i
        }

        load_endpoint('users/self/checkins', params)[:response][:checkins][:items]
      end

      def load_endpoint(endpoint, params={})
        params = params.merge({
          oauth_token: @access_token,
          v: API_VERSION
        })

        conn = Faraday.new(
          url: 'https://api.foursquare.com/v2/',
          params: params
        )

        response = conn.get(endpoint)
        JSON.parse(response.body, { symbolize_names: true })
      end
    end
  end
end
