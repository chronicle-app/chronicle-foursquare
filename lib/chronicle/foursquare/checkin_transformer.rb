module Chronicle
  module Foursquare
    class CheckinTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.provider = 'foursquare'
        r.description = 'foursquare checkin'
        r.identifier = 'checkin'
      end

      def transform
        build_checkin
      end

      def timestamp
        Time.at(checkin[:createdAt])
      end

      def id
        checkin[:id]
      end

      private

      def build_checkin
        record = ::Chronicle::ETL::Models::Activity.new
        record.provider = 'foursquare'
        record.end_at = timestamp
        record.provider_id = id
        record.lat = checkin[:venue][:location][:lat]
        record.lng = checkin[:venue][:location][:lng]
        record.dedupe_on << ['provider', 'provider_id', 'verb']
        record.involved = build_venue
        record.actor = build_actor
        record
      end

      def build_venue
        record = ::Chronicle::ETL::Models::Entity.new
        record.provider = 'foursquare'
        record.provider = checkin[:venue][:id]
        record.represents = 'venue'
        record.title = checkin[:venue][:name]
        record.provider_id = checkin[:venue][:id]
        record.lat = checkin[:venue][:location][:lat]
        record.lng = checkin[:venue][:location][:lng]
        record.dedupe_on << ['provider', 'provider_id', 'represents']
        record.abouts = checkin[:venue][:categories].map{|category| build_category(category)}
        record
      end

      def build_actor
        record = ::Chronicle::ETL::Models::Entity.new
        record.provider = 'foursquare'
        record.represents = 'identity'
        record.title = "#{actor[:firstName]} #{actor[:lastName]}"
        record.provider_id = actor[:id]
        record.provider_url = actor[:canonicalUrl]
        record.dedupe_on << ['provider_url']
        record.dedupe_on << ['provider', 'provider_id', 'represents']
        record.attachments = [::Chronicle::ETL::Models::Attachment.new({
          url_original: actor[:photo][:prefix] + "260x260" + actor[:photo][:suffix]
        })]
        record
      end

      def build_category(category)
        record = ::Chronicle::ETL::Models::Entity.new
        record.provider = 'foursquare'
        record.provider_id = category[:id]
        record.represents = 'topic'
        record.title = category[:name]
        record.dedupe_on << ['provider', 'provider_id', 'represents']
        record
      end

      def checkin
        @checkin ||= @extraction.data
      end

      def actor
        @actor ||= @extraction.meta[:actor]
      end
    end
  end
end
