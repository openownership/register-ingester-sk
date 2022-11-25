require 'json'
require 'register_ingester_sk/records_producer'

RSpec.describe RegisterIngesterSk::RecordsProducer do
  subject do
    described_class.new(
      stream_name: stream_name,
      kinesis_adapter: kinesis_adapter,
      s3_adapter: s3_adapter,
      buffer_size: buffer_size,
      serializer: serializer
    )
  end

  let(:stream_name) { double 'stream_name' }
  let(:kinesis_adapter) { double 'kinesis_adapter' }
  let(:s3_adapter) { double 's3_adapter' }
  let(:buffer_size) { double 'buffer_size' }
  let(:serializer) { double 'serializer' }
  let(:fake_publisher) { double 'fake_publisher' }

  before do
    allow(RegisterCommon::Services::Publisher).to receive(:new).with(
      stream_name: stream_name,
      kinesis_adapter: kinesis_adapter,
      buffer_size: buffer_size,
      serializer: serializer,
      s3_adapter: s3_adapter,
      s3_prefix: 'large-sk',
      s3_bucket: ENV['BODS_S3_BUCKET_NAME'],
    ).and_return fake_publisher
  end

  let(:records) { [double('record1'), double('record2')] }

  describe '#produce' do
    context 'when stream_name not provided' do
      let(:stream_name) { nil }

      it 'does not call finalize' do
        expect(fake_publisher).not_to receive(:publish)

        subject.produce records

        expect(RegisterCommon::Services::Publisher).not_to have_received(:new)
      end
    end

    context 'when stream_name provided' do
      it 'calls publish' do
        allow(fake_publisher).to receive(:publish)

        subject.produce records

        expect(fake_publisher).to have_received(:publish).with(records[0])
        expect(fake_publisher).to have_received(:publish).with(records[1])
      end
    end
  end

  describe '#finalize' do
    context 'when stream_name not provided' do
      let(:stream_name) { nil }

      it 'does not call finalize' do
        expect(fake_publisher).not_to receive(:finalize)

        subject.finalize

        expect(RegisterCommon::Services::Publisher).not_to have_received(:new)
      end
    end

    context 'when stream_name provided' do
      it 'calls finalize' do
        expect(fake_publisher).to receive(:finalize)

        subject.finalize
      end
    end
  end
end
