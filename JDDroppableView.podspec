Pod::Spec.new do |s|

  s.name         = "JDDroppableView"
  s.version      = "1.1.4"
  s.summary      = "Easy Drag & Drop - even within scrollviews! A base class to make any view draggable. Automatic drag target recognition."

  s.description  = "A DroppableView represents a single draggable View. Use it as a base class for any view that should be draggable. You can even use it to drag something out of a scrollview, as you can see in the example project. You can define views as drop targets. You will then be informed, if a dragged view hits those targets, leaves them again or is released / dropped over a drop target."

  s.license      = "MIT"
  s.author       = { "Markus Emrich" => "markus.emrich@gmail.com" }
  s.homepage     = "https://github.com/calimarkus/JDDroppableView"
  s.screenshot   = "https://user-images.githubusercontent.com/807039/169490230-66ced2bc-bfc2-4270-bd6d-21a9823a9f8c.png"

  s.source       = { :git => "https://github.com/calimarkus/JDDroppableView.git", :tag => "pod-#{s.version}" }
  s.source_files = 'Library/DroppableView/**/*.{h,m}'

  s.platform     = :ios, '12.0'

end
