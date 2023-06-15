module Fluent
  module BigQuery
    module Storage
      class Writer
        def initialize(log, auth_method, project, dataset, table, proto_descriptor, **options)
          @auth_method = auth_method
          @project = project
          @dataset = dataset
          @table = table
          @proto_descriptor = proto_descriptor
          @scope = "https://www.googleapis.com/auth/bigquery"
          @options = options
          @log = log
        end

        def client
          @client ||= Google::Cloud::Bigquery::Storage::V1::BigQueryWrite::Client.new.tap do |cl|
            cl.configure.credentials = get_auth
          end
        end

        def insert(rows)
          data = [
            Google::Cloud::Bigquery::Storage::V1::AppendRowsRequest.new(
              write_stream: "projects/#{@project}/datasets/#{@dataset}/tables/#{@table}/streams/_default",
              proto_rows: Google::Cloud::Bigquery::Storage::V1::AppendRowsRequest::ProtoData.new(
                rows: Google::Cloud::Bigquery::Storage::V1::ProtoRows.new(
                  serialized_rows: rows
                ),
                writer_schema: Google::Cloud::Bigquery::Storage::V1::ProtoSchema.new(
                  proto_descriptor: @proto_descriptor
                )
              )
            )
          ]
          client.append_rows(data).map do |e|
            @log.debug(e)
          end
        end

        private

        def get_auth
          case @auth_method
          when :compute_engine
            get_auth_from_compute_engine
          when :json_key
            get_auth_from_json_key
          when :application_default
            get_auth_from_application_default
          else
            raise ConfigError, "Unknown auth method: #{@auth_method}"
          end
        end

        def get_auth_from_compute_engine
          Google::Auth::GCECredentials.new
        end

        def get_auth_from_json_key
          json_key = @options[:json_key]

          begin
            JSON.parse(json_key)
            key = StringIO.new(json_key)
            Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: key, scope: @scope)
          rescue JSON::ParserError
            File.open(json_key) do |f|
              Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: f, scope: @scope)
            end
          end
        end

        def get_auth_from_application_default
          Google::Auth.get_application_default([@scope])
        end
      end
    end
  end
end