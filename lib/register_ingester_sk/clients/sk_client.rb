require 'net/http/persistent'
require 'json'

module RegisterIngesterSk
  module Clients
    class SkClient
      API_URL = 'https://rpvs.gov.sk/OpenData/Partneri'

      # The api uses OData, which defines it's own system of url params that allow
      # you to (amongst other things) request that records are 'expanded', i.e.
      # eagerly fetched and nested in the results.
      # This parameter 'expands' Partneri and Konecni, the company and people
      # records for each result, expanding all their sub-properties in turn.  
      RECORD_EXPANSION_PARAM = '$expand=PartneriVerejnehoSektora($expand=*),KonecniUzivateliaVyhod($expand=*)'

      def initialize(api_url: nil, record_expansion_param: nil, error_adapter: nil)
        @api_url = api_url || API_URL
        @record_expansion_param = record_expansion_param || RECORD_EXPANSION_PARAM
        @error_adapter = error_adapter
        @http = Net::HTTP::Persistent.new(name: self.class.name)
      end

      def all_records
        uri = "#{api_url}?#{record_expansion_param}"

        Enumerator.new do |yielder|
          response = yield_response(fetch(uri), yielder)

          while response && response['@odata.nextLink']
            response = yield_response(fetch(response['@odata.nextLink']), yielder)
          end
        end
      end

      def company_record(company_id)
        uri = "#{api_url}(#{company_id})?#{record_expansion_param}"
        response = fetch(uri)
        return if response.nil?

        JSON.parse(response.body)
      end

      private

      attr_reader :error_adapter, :http, :api_url, :record_expansion_param

      def fetch(uri)
        response = http.request(URI(uri))

        unless response.is_a?(Net::HTTPSuccess)
          error_adapter && error_adapter.error("#{response.code} received when importing sk data")
          return nil
        end

        response
      end

      def yield_response(response, yielder)
        return if response.nil?

        JSON.parse(response.body).tap do |object|
          object['value'].each do |record|
            if record['KonecniUzivateliaVyhod@odata.nextLink']
              fetched_record = company_record(record['Id'])

              record['KonecniUzivateliaVyhod'] = fetched_record.nil? ? [] : fetched_record['KonecniUzivateliaVyhod']
            end

            yielder << record
          end
        end
      end
    end
  end
end
