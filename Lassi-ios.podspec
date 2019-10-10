Pod::Spec.new do |spec|

  spec.name         = "Lassi-ios"
  spec.version      = "0.0.2"
  spec.summary      = "A CocoaPods library written in Swift"
  spec.description  = <<-DESC
This CocoaPods library helps you perform calculation.
                   DESC
  spec.homepage     = "https://github.com/PiyushSelarka/Lassi-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "PiyushSelarka" => "piyushselarka.mi@gmail.com" }
  spec.ios.deployment_target = "12.1"
  spec.swift_version = "4.2"
  spec.source        = { :git => "https://github.com/PiyushSelarka/Lassi-ios.git", :tag => "#{spec.version}" }
  spec.source_files  = "Lassi-ios/**/*.{h,m,swift}"
  spec.dependency "CropViewController"

end