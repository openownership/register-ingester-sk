# frozen_string_literal: true

require 'register_sources_sk/config/elasticsearch'
require 'register_sources_sk/repository'

require_relative 'config/settings'
require_relative 'records_producer'

module RegisterIngesterSk
  class RecordsHandler
    def initialize(repository: nil, producer: nil)
      @repository = repository || RegisterSourcesSk::Repository.new(
        client: RegisterSourcesSk::Config::ELASTICSEARCH_CLIENT,
        index: RegisterSourcesSk::Config::ELASTICSEARCH_INDEX
      )
      @producer = producer || RecordsProducer.new(stream_name: ENV.fetch('SK_STREAM', nil))
    end

    def handle_records(records)
      new_records = records.reject { |record| repository.get(record.etag) }

      return if new_records.empty?

      producer.produce(new_records)
      producer.finalize

      repository.store(new_records)
    end

    private

    attr_reader :repository, :producer
  end
end
