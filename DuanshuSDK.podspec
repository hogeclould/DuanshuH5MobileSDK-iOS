Pod::Spec.new do |s|

  s.name         = "DuanshuSDK"
  s.version      = "1.0.1"
  s.platform     = :ios, "9.0"
  s.authors      = 'dingdone'
  s.license      = 'dingdone'
  s.homepage     = 'http://www.duanshu.com'
  s.summary      = 'dingdone'

  s.source       = { :git => "https://github.com/hogeclould/DuanshuH5MobileSDK-iOS.git"}

  s.vendored_frameworks = 'Framework/DuanshuSDK.framework'

  s.requires_arc = true

end
