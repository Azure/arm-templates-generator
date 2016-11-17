Gem::Specification.new do |spec|
  spec.name          = 'arm-templates-generator'
  spec.version       = '0.1.0'
  spec.authors       = 'Microsoft Corporation'
  spec.email         = 'azrubyteam@microsoft.com'
  spec.description   = 'Microsoft Azure Resource Management Template Generation Library for Ruby'
  spec.summary       = 'Official ruby client library to consume Microsoft Azure Resource Management services.'
  spec.homepage      = 'http://github.com/azure/azure-sdk-for-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'dotenv', '~> 2'
  spec.add_development_dependency 'json', '~> 1.7'

  spec.add_runtime_dependency 'azure_mgmt_resources', '~> 0.2.0'
end