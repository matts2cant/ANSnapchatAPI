Pod::Spec.new do |s|

  s.name         = "ANSnapchatAPI"
  s.version      = "0.1"
  s.summary      = "Cocoa Snapchat API"

  s.description  = <<-DESC
                   Unofficial library to communicate with the Snapchat private API.
                   DESC

  s.homepage     = "https://github.com/matts2cant/ANSnapchatAPI"
  s.license      = 'Apache License, Version 2.0'
  s.author       = { "Alex NICHOL" => "unixpickle@gmail.com", "Matthieu DE CANTELOUBE" => "matts2cant@gmail.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/matts2cant/ANSnapchatAPI.git", :tag => "v0.1" }
  s.source_files  = 'Sources/**/*.{h,m}'
  s.public_header_files = 'Sources/**/*.h'
  s.requires_arc = true

end
