Pod::Spec.new do |s|
  s.name         = "TSAnimatedRootViewSwitcheroo"
  s.version      = "1.0.0"
  s.summary      = "A simple container controller for your that lets you animate transitions from one UIWindow.rootViewController to a new one."
  s.homepage     = "https://github.com/timshadel/TSAnimatedRootViewSwitcheroo"
  s.license      = "MIT"
  s.author       = { 'Tim Shadel' => 'github@timshadel.com' }
  s.ios.deployment_target = "7.0"
  s.source       = { :git => "https://github.com/timshadel/TSAnimatedRootViewSwitcheroo.git", :tag => s.version.to_s }
  s.source_files = 'TSAnimatedRootViewSwitcheroo.[mh]'
  s.public_header_files = 'TSAnimatedRootViewSwitcheroo.h'
  s.requires_arc = true
end
