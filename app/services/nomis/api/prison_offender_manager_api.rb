module Nomis
  module Api
    class PrisonOffenderManagerApi
      extend Elite2Api

      def self.list(prison)
        route = "/elite2api/api/staff/roles/#{prison}/role/POM"

        response = e2_client.get(route) { |data|
          raise Nomis::Client::APIError, 'No data was returned' if data.empty?
        }

        response.map { |pom|
          api_deserialiser.deserialise(Nomis::Models::PrisonOffenderManager, pom)
        }
      end
    end
  end
end
