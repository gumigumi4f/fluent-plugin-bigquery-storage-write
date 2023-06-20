require "helper"
require "fluent/plugin/out_bigquery_storage_write_insert.rb"

class BigQueryStorageWriteInsertOutputTest < Test::Unit::TestCase
  CONFIG = %[
    @type bigquery_storage_write_insert

    auth_method application_default

    project sample-project
    dataset test
    table data

    proto_schema_rb_path /path/to/schema_rb
    proto_message_class_name Test
  ]

  setup do
    Fluent::Test.setup
  end

  sub_test_case 'configure' do
    test 'all params are configured' do
      d = create_driver(%[
        auth_method json_key
        json_key test

        project sample-project
        dataset test
        table data

        proto_schema_rb_path /path/to/schema_rb
        proto_message_class_name Test
      ])

      assert_equal(:json_key, d.instance.auth_method)
      assert_equal('test', d.instance.json_key)
      assert_equal('sample-project', d.instance.project)
      assert_equal('test', d.instance.dataset)
      assert_equal('data', d.instance.table)
      assert_equal('/path/to/schema_rb', d.instance.proto_schema_rb_path)
      assert_equal('Test', d.instance.proto_message_class_name)
    end

    test '"json_key" must be specified when auth_method set to "json_key"' do
      assert_raises Fluent::ConfigError do
        create_driver(%[
          auth_method json_key

          project sample-project
          dataset test
          table data

          proto_schema_rb_path /path/to/schema_rb
          proto_message_class_name Test
        ])
      end
    end
  end

  private

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::BigQueryStorageWriteInsertOutput).configure(conf)
  end
end
