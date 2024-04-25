module Chronicle
  module Foursquare
    class CheckinTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.source = :foursquare
        r.type = :checkin
        r.strategy = :api
        r.description = 'a checkin'
        r.from_schema = :extraction
        r.to_schema = :chronicle
      end

      def transform(record)
        checkin = record.data
        actor = record.extraction.meta[:actor]
        build_checkin(checkin, actor)
      end

      private

      def build_checkin(checkin, actor)
        Chronicle::Models::CheckInAction.new do |r|
          r.source = 'foursquare'
          r.end_time = Time.at(checkin[:createdAt])
          r.agent = build_agent(actor)
          r.object = build_venue(checkin)
        end
      end

      def build_venue(checkin)
        venue = checkin[:venue]
        location = venue[:location]

        # TODO: represent categories (https://github.com/chronicle-app/chronicle-core/issues/10)

        Chronicle::Models::Place.new do |r|
          r.source = 'foursquare'
          r.name = venue[:name]
          r.latitude = location[:lat]
          r.longitude = location[:lng]
          r.source_id = venue[:id]

          r.address = Chronicle::Models::PostalAddress.new do |a|
            a.description = location&.dig(:formattedAddress)&.join(', ')
            a.address_country = location[:country]
            a.address_locality = location[:city]
            a.address_region = location[:state]
            a.postal_code = location[:postalCode]
            a.street_address = location[:address]
          end

          r.dedupe_on = [%i[source source_id type]]
        end
      end

      def build_agent(actor)
        image_url = "#{actor[:photo][:prefix]}260x260#{actor[:photo][:suffix]}"
        name = "#{actor[:firstName]} #{actor[:lastName]}"

        Chronicle::Models::Person.new do |r|
          r.source = 'foursquare'
          r.name = name
          r.image = image_url
          r.source_id = actor[:id]
          r.url = actor[:canonicalUrl]
        end
      end

      # def build_category(category)
      #   record = ::Chronicle::ETL::Models::Entity.new
      #   record.provider = 'foursquare'
      #   record.provider_id = category[:id]
      #   record.represents = 'topic'
      #   record.title = category[:name]
      #   record.dedupe_on << ['provider', 'provider_id', 'represents']
      #   record
      # end
    end
  end
end
