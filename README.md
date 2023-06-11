# fluent-plugin-bigquery-storage-write

[Fluentd](https://fluentd.org/) output plugin to insert data into BigQuery through storage write api.

TODO: write description for you plugin.

## Installation

### RubyGems

```
$ gem install fluent-plugin-bigquery-storage-write
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-bigquery-storage-write"
```

And then execute:

```
$ bundle
```

## Configuration

You have to generate proto code to serialize data.

```
$ bundle exec grpc_tools_ruby_protoc -I proto --ruby_out=proto --grpc_out=proto proto/test_data.proto
```

You can copy and paste generated documents here.

## Copyright

* Copyright(c) 2023- gumigumi4f
* License
  * Apache License, Version 2.0
