Pod::Spec.new do |spec|
  spec.name         = 'JoGallery'
  spec.summary      = 'A iOS Photos UI components.'
  spec.version      = '0.0.4'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.authors      = { 'django' => 'djangolei@gmail.com' }
  spec.homepage     = 'https://github.com/djangolee/JoGallery'
  spec.source       = { :git => 'https://github.com/djangolee/JoGallery.git', :tag => spec.version.to_s }
  spec.requires_arc = true
  spec.ios.deployment_target = '8.0'
  spec.source_files = 'Source/**/*.{swift}'

end
