Pod::Spec.new do |s|
  s.name         = "TBL"
  s.version      = "0.0.1"
  s.license      = "MIT"
  s.summary      = "Create UITableViews the easy way."
  s.homepage     = "https://github.com/marcbaldwin/Zest"
  s.author       = { "Marc Baldwin" => "marc.baldwin88@gmail.com" }
  s.source       = { :git => "https://github.com/marcbaldwin/TBL.git", :tag => s.version }
  s.source_files = "TBL/*.swift"
  s.platform     = :ios, '8.0'
  s.frameworks   = "Foundation", "UIKit"
  s.requires_arc = true
end
