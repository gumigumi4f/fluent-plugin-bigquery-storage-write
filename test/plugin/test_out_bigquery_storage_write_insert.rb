require "helper"
require "fluent/plugin/out_bigquery_storage_write_insert.rb"

class BigQueryStorageWriteInsertOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::BigQueryStorageWriteInsertOutput).configure(conf)
  end
end
