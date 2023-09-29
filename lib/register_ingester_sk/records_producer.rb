# frozen_string_literal: true

require 'register_ingester_sk/config/settings'
require 'register_ingester_sk/config/adapters'
require 'register_ingester_sk/record_serializer'
require 'register_common/services/publisher'

require 'active_support/core_ext/string'

module RegisterIngesterSk
  class RecordsProducer
    def initialize(stream_name: nil, kinesis_adapter: nil, s3_adapter: nil, buffer_size: nil, serializer: nil)
      stream_name ||= ENV.fetch('SK_STREAM', nil)
      kinesis_adapter ||= RegisterIngesterSk::Config::Adapters::KINESIS_ADAPTER
      s3_adapter ||= RegisterIngesterSk::Config::Adapters::S3_ADAPTER
      buffer_size ||= 50
      serializer ||= RecordSerializer.new

      @publisher = if stream_name.present?
                     RegisterCommon::Services::Publisher.new(
                       stream_name:,
                       kinesis_adapter:,
                       buffer_size:,
                       serializer:,
                       s3_adapter:,
                       s3_prefix: 'large-sk',
                       s3_bucket: ENV.fetch('BODS_S3_BUCKET_NAME', nil)
                     )
                   end
    end

    def produce(records)
      return unless publisher

      records.each do |record|
        publisher.publish(record)
      end
    end

    def finalize
      return unless publisher

      publisher.finalize
    end

    private

    attr_reader :publisher
  end
end
