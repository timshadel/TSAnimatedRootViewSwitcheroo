Pod::Spec.new do |s|
  s.name         = "LRNavStackContainer"
  s.version      = "1.0.0"
  s.summary      = "Use animated transitions (e.g. VCTransitionsLibrary) to switch between nav stacks (like login, upgrading db, and normal use)."
  s.homepage     = "https://github.com/timshadel/LRNavStackContainer"
  s.license      = "MIT"
  s.author       = { 'Tim Shadel' => 'github@timshadel.com' }
  s.source       = { :git => "https://github.com/timshadel/LRNavStackContainer.git", :tag => s.version.to_s }
  s.source_files = 'LRNavStackContainer.[mh]'
  s.public_header_files = 'LRNavStackContainer.h'
end
