# Lemondrop

# Podfile 
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Lemondrop' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Lemondrop


  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'Floaty', '~> 4.2.0'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'ProgressHUD'
  pod 'Alamofire'
  pod 'Cosmos', '~> 19.0'
  pod 'SideMenu'
  pod 'AWSSNS'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'HYParentalGate', '~> 1.0'
  pod 'SwipeCellKit'
  pod 'OneSignal', '>= 2.6.2', '< 3.0'
  pod 'MarqueeLabel'
end

target 'OneSignalNotificationServiceExtension' do
  use_frameworks!

  pod 'OneSignal', '>= 2.6.2', '< 3.0'
end

