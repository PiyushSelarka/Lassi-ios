Pod::Spec.new do |s|
  s.name             = 'Lassi-ios'
  s.version          = '1.0.2'
  s.summary          = 'A CocoaPods library written in Swift'
  s.description      = <<-DESC
This CocoaPods library helps you perform calculation.
                       DESC

  s.homepage         = 'https://github.com/PiyushSelarka/Lassi-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'PiyushSelarka' => 'piyushselarka.mi@gmail.com' }
  s.source           = { :git => 'https://github.com/PiyushSelarka/Lassi-ios.git', :tag => s.version.to_s }


  s.ios.deployment_target = '12.1'
  s.swift_version = '4.2'

  s.source_files = 'Lassi-ios/**/*.{swift}'
  
  s.resource_bundles = {
     'Lassi-ios' => ['Lassi-ios/**/*.{storyboard,xib,xcdatamodeld}']
  }

  s.dependency "CropViewController"
end