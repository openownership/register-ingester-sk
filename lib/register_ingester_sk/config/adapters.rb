require 'register_common/adapters/http_adapter'
require 'register_common/adapters/kinesis_adapter'
require 'register_ingester_sk/config/settings'

module RegisterIngesterSk
  module Config
    module Adapters
      HTTP_ADAPTER = RegisterCommon::Adapters::HttpAdapter.new
      KINESIS_ADAPTER = RegisterCommon::Adapters::KinesisAdapter.new(credentials: AWS_CREDENTIALS)
    end
  end
end
