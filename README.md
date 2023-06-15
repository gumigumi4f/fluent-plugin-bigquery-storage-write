# fluent-plugin-bigquery-storage-write

[Fluentd](https://fluentd.org/) output plugin to insert data into BigQuery through storage write api.

TODO: write description for you plugin.

## Installation

### RubyGems

```sh
gem install fluent-plugin-bigquery-storage-write
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-bigquery-storage-write"
```

And then execute:

```sh
bundle
```

## Configuration

You have to generate proto code to serialize data.

```sh
bundle exec grpc_tools_ruby_protoc -I proto --ruby_out=proto proto/test_data.proto
```

You can copy and paste generated documents here.

## Copyright

* Copyright(c) 2023 gumigumi4f
* License
  * Apache License, Version 2.0
* This plugin includes some code from [fluent-plugin-bigquery](https://github.com/fluent-plugins-nursery/fluent-plugin-bigquery) for compatibility.
