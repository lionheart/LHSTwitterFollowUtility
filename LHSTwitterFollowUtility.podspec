Pod::Spec.new do |s|
  s.name         = "LHSTwitterFollowUtility"
  s.version      =  "0.1.0"
  s.summary      = "A collection of helpful categories for use in iOS projects."
  s.homepage     = "http://lionheartsw.com"
  s.license      = 'Apache 2.0'
  s.author       = { "Dan Loewenherz" => "dan@lionheartsw.com" }
  s.social_media_url = "http://twitter.com/dwlz"
  s.source       = { :git => "https://github.com/lionheart/LHSTwitterFollowUtility.git", :tag => "#{s.version}" }
  s.source_files = 'LHSTwitterFollowUtility/*.{h,m}'
  s.public_header_files = 'LHSTwitterFollowUtility/*.h'
  s.requires_arc = true
  s.dependency 'LHSCategoryCollection'

  s.platform     = :ios, '7.0'
  s.framework  = 'UIKit'
  s.requires_arc = true
end

