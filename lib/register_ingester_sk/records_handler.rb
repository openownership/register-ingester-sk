require 'register_ingester_sk/config/settings'
require 'register_sources_sk/config/elasticsearch'
require 'register_sources_sk/repositories/record_repository'
require 'register_ingester_sk/records_producer'

module RegisterIngesterSk
  class RecordsHandler
    def initialize(repository: nil, producer: nil)
      @repository = repository || RegisterSourcesSk::Repositories::RecordRepository.new(
        client: RegisterSourcesSk::Config::ELASTICSEARCH_CLIENT,
      )
      @producer = producer || RecordsProducer.new
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
