# fluent-plugin-bigquery-storage-write

![Test](https://github.com/gumigumi4f/fluent-plugin-bigquery-storage-write/workflows/Test/badge.svg)
[![Gem Version](https://badge.fury.io/rb/fluent-plugin-bigquery-storage-write.svg)](http://badge.fury.io/rb/fluent-plugin-bigquery-storage-write)

[Fluentd](https://fluentd.org/) output plugin to insert data into BigQuery through storage write api.

## Overview

Google Cloud Bigquery output plugin for [Fluentd](https://fluentd.org/).
The main difference from [fluent-plugin-bigquery](https://github.com/fluent-plugins-nursery/fluent-plugin-bigquery) is that it uses BigQuery new API called `Storage Write API`.

Advantages of using the Storage Write API are described [here](https://cloud.google.com/bigquery/docs/write-api#advantages).

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

### bigquery_storage_write_insert

| name                     | type   | required?         | default             | description                                                                                                  |
|:-------------------------|:-------|:------------------|:--------------------|:-------------------------------------------------------------------------------------------------------------|
| auth_method              | enum   | yes               | application_default | `private_key` or `json_key` or `compute_engine` or `application_default`                                     |
| email                    | string | yes (private_key) | nil                 | GCP Service Account Email                                                                                    |
| private_key_path         | string | yes (private_key) | nil                 | GCP Private Key file path                                                                                    |
| private_key_passphrase   | string | yes (private_key) | nil                 | GCP Private Key Passphrase                                                                                   |
| json_key                 | string | yes (json_key)    | nil                 | GCP JSON Key file path or JSON Key string                                                                    |
| project                  | string | yes               | nil                 |                                                                                                              |
| dataset                  | string | yes               | nil                 |                                                                                                              |
| table                    | string | yes               | nil                 |                                                                                                              |
| ignore_unknown_fields    | bool   | no                | true                | If False, raise errors for unknown fields.                                                                   |
| proto_schema_rb_path     | string | yes               | nil                 | Generated Protocol Buffers schema .rb file path.                                                             |
| proto_message_class_name | string | no                | nil                 | Class name of Protocol Buffers message. If not specified, table value that converted to pascal case is used. |

### buffer section

| name                        | type    | required? | default  | description                        |
|:----------------------------|:--------|:----------|:---------|:-----------------------------------|
| @type                       | string  | no        | memory   |                                    |
| chunk_limit_size            | integer | no        | 1MB      |                                    |
| total_limit_size            | integer | no        | 1GB      |                                    |
| chunk_records_limit         | integer | no        | 500      |                                    |
| flush_mode                  | enum    | no        | interval | default, lazy, interval, immediate |
| flush_interval              | float   | no        | 1.0      |                                    |
| flush_thread_interval       | float   | no        | 0.05     |                                    |
| flush_thread_burst_interval | float   | no        | 0.05     |                                    |

And, other params (defined by base class) are available

see. https://github.com/fluent/fluentd/blob/master/lib/fluent/plugin/output.rb

## Examples

First, you have to generate Protocol Buffers compiled code to serialize data.
Write code `.proto` and compile it using `protoc`.
The sample code with BigQuery schema is located in the path below `proto/test_data.proto`.

```sh
protoc -I proto --ruby_out=proto proto/test_data.proto
```

Next, specify generated ruby code path to fluentd configuration file.

```
<match test>
  @type bigquery_storage_write_insert

  auth_method application_default

  project sample-project
  dataset test
  table data

  proto_schema_rb_path /your/generated/code/path/here/test_data_pb.rb
  proto_message_class_name Data
</match>
```

## Tips

- Can I dynamically retrieve and use the BigQuery table schema?
  - No, you have to use predefined schema generated by `protoc`.
  - Also, you have to create BigQuery table before using this plugin.
- Where is the type conversions docs between Protocol Buffers and BigQuery?
  - See https://cloud.google.com/bigquery/docs/write-api#data_type_conversions
  - Note that some types, including `google.protobuf.Timestamp`, are not available due to [BigQuery limitation](https://github.com/googleapis/python-bigquery-storage/issues/257).
- Which protoc version do I need for compilation?
  - [Protocol Buffers v23.0](https://github.com/protocolbuffers/protobuf/releases/tag/v23.0) is minimum version because it generates a serialized proto instead of the DSL.
- Is there any limitation on the Storage Write API?
  - See https://cloud.google.com/bigquery/quotas?hl=ja#write-api-limits
  - Especially, note that the maximum value of chunk_limit_size is limited to 10 MB.

## Copyright

* Copyright(c) 2023 gumigumi4f
* License
  * Apache License, Version 2.0
* This plugin includes some code from [fluent-plugin-bigquery](https://github.com/fluent-plugins-nursery/fluent-plugin-bigquery) for compatibility.
