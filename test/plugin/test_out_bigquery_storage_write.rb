require "helper"
require "fluent/plugin/out_bigquery_insert_storage_write.rb"

class BigqueryStorageWriteOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::BigqueryStorageWriteOutput).configure(conf)
  end
end
