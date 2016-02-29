Pod::Spec.new do |spec|

  spec.name = 'KSPNavigationController'

  spec.version = '0.0.0'

  spec.cocoapods_version = '>= 0.36'

  spec.authors = {'Konstantin Pavlikhin' => 'k.pavlikhin@gmail.com'}

  spec.social_media_url = 'https://twitter.com/kpavlikhin'

  spec.license = {:type => 'MIT', :file => 'LICENSE.md'}

  spec.homepage = 'https://github.com/konstantinpavlikhin/KSPNavigationController'

  spec.source = {:git => 'https://github.com/konstantinpavlikhin/KSPNavigationController.git', :tag => "v#{spec.version}"}

  spec.summary = 'The navigation controller for your desktop application development needs.'

  spec.platform = :osx, '10.11'

  spec.osx.deployment_target = '10.9'

  spec.requires_arc = true

  spec.frameworks = 'AppKit'

  spec.module_name = 'KSPNavigationController'

  spec.source_files = 'Sources/*.{h,m}'

  spec.public_header_files = 'Sources/*.h'

  spec.private_header_files = 'Sources/KSPNavigationController+Private.h'

  spec.resources = 'Resources/*'

  spec.exclude_files = 'Resources/KSPNavigationController.plist'

  spec.module_map = 'KSPNavigationController.modulemap'

end
