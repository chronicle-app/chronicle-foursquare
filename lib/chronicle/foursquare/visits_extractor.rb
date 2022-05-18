module Chronicle
  module Foursquare
    class VisitsExtractor < Chronicle::ETL::Extractor
      register_connector do |r|
        r.provider = 'foursquare'
        r.description = 'visits'
      end

      setting :access_token, required: true

      def prepare
        raise(Chronicle::ETL::ExtractionError, "Access token is missing") if @config.access_token.empty?

        @proxy = Chronicle::Foursquare::Proxy.new(access_token: @config.access_token)
        @actor = load_actor
        @visits = load_visits
      end

      def results_count
        @visits.count
      end

      def extract
        @visits.each do |visit|
          yield Chronicle::ETL::Extraction.new(data: visit, meta: { actor: @actor})
        end
      end

      private

      def load_visits
        @proxy.load_visits(limit: @config.limit, since: @config.since)
      end

      def load_actor
        @proxy.load_self
      end
    end
  end
end
