# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "gasagent"
  spec.version       = "1.0.0"
  spec.authors       = ["Jorja Hung"]
  spec.email         = ["jorjahung@gmail.com"]
  spec.summary       = %q{A gem for importing, exporting, and creating new Google Apps Scripts from/to your Google Drive}
  spec.description   = %q{A gem for importing, exporting, and creating new Google Apps Scripts from/to your Google Drive}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.executables = ["gasagent"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-mocks"
  spec.add_runtime_dependency  'google-api-client', '>= 0.6'
  spec.add_runtime_dependency  'json'
  spec.add_runtime_dependency  'httparty'
  spec.add_runtime_dependency  'command_line_reporter'
end