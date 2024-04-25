module Chronicle
  module Foursquare
    class CheckinExtractor < Chronicle::ETL::Extractor
      register_connector do |r|
        r.source = :foursquare
        r.type = :checkin
        r.strategy = :api
        r.description = 'foursquare checkin'
      end

      setting :access_token, required: true

      def prepare
        raise(Chronicle::ETL::ExtractionError, 'Access token is missing') if @config.access_token.empty?

        @proxy = Chronicle::Foursquare::Proxy.new(access_token: @config.access_token)
        @actor = load_actor
        @checkins = load_checkins
      end

      def results_count
        @checkins.count
      end

      def extract
        @checkins.each do |checkin|
          yield build_extraction(data: checkin, meta: { actor: @actor })
        end
      end

      private

      def load_checkins
        @proxy.load_checkins(limit: @config.limit, since: @config.since)
      end

      def load_actor
        @proxy.load_self
      end
    end
  end
end
