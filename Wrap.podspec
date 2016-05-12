Pod::Spec.new do |s|
  s.name         = "Wrap"
  s.version      = "1.1"
  s.summary      = "The easy to use Swift JSON encoder"
  s.description  = <<-DESC
  Wrap is an easy to use Swift JSON encoder. Don't spend hours writing JSON encoding code - just wrap it instead!

  Using Wrap is as easy as calling Wrap() on any instance of a class or struct that you wish to encode. It automatically encodes all of your type’s properties, including nested objects, collections, enums and more!
  DESC
  s.homepage     = "https://github.com/JohnSundell/Wrap"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "John Sundell" => "john@sundell.co" }
  s.social_media_url   = "https://twitter.com/johnsundell"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/JohnSundell/Wrap.git", :tag => "1.1" }
  s.source_files  = "Wrap.swift"
  s.framework  = "Foundation"
end
