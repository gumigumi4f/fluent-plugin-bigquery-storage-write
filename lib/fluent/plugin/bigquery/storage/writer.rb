module Fluent
  module BigQuery
    module Storage
      class Writer
        def initialize(log, auth_method, project, dataset, table, proto_descriptor, **options)
          @auth_method = auth_method
          @scope = "https://www.googleapis.com/auth/bigquery"
          @options = options
          @log = log

          @write_stream = "projects/#{project}/datasets/#{dataset}/tables/#{table}/streams/_default"
          @write_schema = Google::Cloud::Bigquery::Storage::V1::ProtoSchema.new(
            proto_descriptor: proto_descriptor
          )
        end

        def client
          @client ||= Google::Cloud::Bigquery::Storage::V1::BigQueryWrite::Client.new do |cf|
            cf.credentials = get_auth
          end
        end

        def insert(rows)
          data = [
            Google::Cloud::Bigquery::Storage::V1::AppendRowsRequest.new(
              write_stream: @write_stream,
              proto_rows: Google::Cloud::Bigquery::Storage::V1::AppendRowsRequest::ProtoData.new(
                rows: Google::Cloud::Bigquery::Storage::V1::ProtoRows.new(
                  serialized_rows: rows
                ),
                writer_schema: @write_schema
              )
            )
          ]
          client.append_rows(data).map do |e|
            @log.trace(e)
          end
        end

        private

        def get_auth
          case @auth_method
          when :private_key
            get_auth_from_private_key
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

        def get_auth_from_private_key
          require 'google/api_client/auth/key_utils'
          private_key_path = @options[:private_key_path]
          private_key_passphrase = @options[:private_key_passphrase]
          email = @options[:email]

          key = Google::APIClient::KeyUtils.load_from_pkcs12(private_key_path, private_key_passphrase)
          Signet::OAuth2::Client.new(
            token_credential_uri: "https://accounts.google.com/o/oauth2/token",
            audience: "https://accounts.google.com/o/oauth2/token",
            scope: @scope,
            issuer: email,
            signing_key: key
          )
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