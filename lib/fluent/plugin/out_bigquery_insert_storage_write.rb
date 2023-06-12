require "fluent/plugin/output"

require "fluent/plugin/bigquery/storage/writer"
require "fluent/plugin/bigquery/storage/helper"

require 'google/protobuf'
require 'google/protobuf/descriptor_pb'
require "google/cloud/bigquery/storage/v1"
require 'googleauth'

module Fluent
  module Plugin
    class BigqueryInsertStorageWriteOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("bigquery_insert_storage_write", self)

      helpers :inject

      config_param :auth_method, :enum, list: [:private_key, :compute_engine, :json_key, :application_default], default: :private_key
      config_param :email, :string, default: nil
      config_param :private_key_path, :string, default: nil
      config_param :private_key_passphrase, :string, default: 'hoge', secret: true
      config_param :json_key, default: nil, secret: true

      config_param :project, :string
      config_param :dataset, :string
      config_param :table, :string

      config_param :generated_schema_rb_path, :string

      config_section :buffer do
        config_set_default :@type, "memory"
        config_set_default :flush_mode, :interval
        config_set_default :flush_interval, 1
        config_set_default :flush_thread_interval, 0.05
        config_set_default :flush_thread_burst_interval, 0.05
        config_set_default :chunk_limit_size, 1 * 1024 ** 2 # 1MB
        config_set_default :total_limit_size, 1 * 1024 ** 3 # 1GB
        config_set_default :chunk_limit_records, 500
      end

      def configure(conf)
        super

        case @auth_method
        when :private_key
          unless @email && @private_key_path
            raise Fluent::ConfigError, "'email' and 'private_key_path' must be specified if auth_method == 'private_key'"
          end
        when :compute_engine
          # Do nothing
        when :json_key
          unless @json_key
            raise Fluent::ConfigError, "'json_key' must be specified if auth_method == 'json_key'"
          end
        when :application_default
          # Do nothing
        else
          raise Fluent::ConfigError, "unrecognized 'auth_method': #{@auth_method}"
        end

        pool = Google::Protobuf::DescriptorPool.generated_pool

        descriptor_data = Fluent::BigQuery::Storage::Helper.get_descriptor_data(@generated_schema_rb_path)
        pool.add_serialized_file(descriptor_data)
        parsed = Google::Protobuf::FileDescriptorProto.decode(descriptor_data)
        @descriptor_proto = parsed.message_type[0]
        @klass = ::Google::Protobuf::DescriptorPool.generated_pool.lookup(Fluent::BigQuery::Storage::Helper.snake_to_pascal(@table)).msgclass
      end

      def start
        super

        @writer = Fluent::BigQuery::Storage::Writer.new(@log, @auth_method, @project, @dataset, @table, @descriptor_proto,
                                                        private_key_path: @private_key_path, private_key_passphrase: @private_key_passphrase,
                                                        email: @email,
                                                        json_key: @json_key,
        )
      end

      def format(tag, time, record)
        if record.nil?
          log.warn("nil record detected. corrupted chunks? tag=#{tag}, time=#{time}")
          return
        end

        record = inject_values_to_record(tag, time, record)
        record.to_json + "\n"
      end

      def multi_workers_ready?
        true
      end

      def write(chunk)
        rows = chunk.open do |io|
          io.map do |line|
            val = @klass.decode_json(line, ignore_unknown_fields: true)
            @klass.encode(val)
          end
        end

        @writer.insert(rows)
      end
    end
  end
end
