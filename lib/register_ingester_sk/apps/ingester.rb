# frozen_string_literal: true

require 'register_sources_sk/structs/record'

require_relative '../clients/sk_client'
require_relative '../config/adapters'
require_relative '../config/settings'
require_relative '../records_handler'

module RegisterIngesterSk
  module Apps
    class Ingester
      CHUNK_SIZE = 50

      def self.bash_call(_args)
        Ingester.new.call
      end

      def initialize(records_handler: nil, sk_client: nil)
        @records_handler = records_handler || RecordsHandler.new
        @sk_client = sk_client || Clients::SkClient.new
      end

      def call
        sk_client.all_records.lazy.each_slice(CHUNK_SIZE) do |records|
          records = records.map { |record| RegisterSourcesSk::Record[record] }.compact

          next if records.empty?

          records_handler.handle_records records
        end
      end

      private

      attr_reader :records_handler, :sk_client
    end
  end
end
