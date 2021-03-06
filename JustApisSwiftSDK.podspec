Pod::Spec.new do |s|
  s.name = 'JustApisSwiftSDK'
  s.module_name = 'JustApisSwiftSDK'
  s.version = '0.1.0'
  s.license = 'MIT'
  s.summary = 'Lightweight Swift SDK to connect to a JustAPIs gateway through an iOS client.'
  s.homepage = 'https://github.com/AnyPresence/justapis-swift-sdk'
  s.authors = { 'AnyPresence' => 'http://www.anypresence.com' }
  s.source = { :git => 'https://github.com/AnyPresence/justapis-swift-sdk.git', :tag => "v#{s.version}" }
  s.ios.deployment_target = '8.0'
  s.source_files = 'Source/**/*.swift'
end
