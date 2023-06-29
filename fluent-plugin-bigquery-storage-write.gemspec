lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-bigquery-storage-write"
  spec.version = "0.2.2"
  spec.authors = ["gumigumi4f"]
  spec.email   = ["gumigumi4f@gmail.com"]

  spec.summary       = %q{Fluentd output plugin to insert data into BigQuery through storage write api}
  spec.description   = %q{Fluentd plugin to insert data into BigQuery}
  spec.homepage      = "https://github.com/gumigumi4f/fluent-plugin-bigquery-storage-write"
  spec.license       = "Apache-2.0"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "grpc-tools", ">= 1.55"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
  spec.add_runtime_dependency "grpc", ">= 1.55"
  spec.add_runtime_dependency "googleauth", ">= 1.5.2"
  spec.add_runtime_dependency "google-cloud-bigquery-storage", ">= 1.3.0"
  spec.add_runtime_dependency "google-api-client", ">= 0.53.0"
end
