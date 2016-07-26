#
# Be sure to run `pod lib lint SwiftRedux.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftRedux'
  s.version          = '0.1.0'
  s.summary          = 'A Swift implementation of Redux, with appropriate tweaks for the language'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/rabidaudio/SwiftRedux'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Charles Julian Knight' => 'charles@rabidaudio.com' }
  s.source           = { :git => 'https://github.com/rabidaudio/SwiftRedux.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/charlesjuliank'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SwiftRedux/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SwiftRedux' => ['SwiftRedux/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Observable-Swift', '~> 0.6.0'

#s.default_subspec = 'Basic'

#s.subspec 'Basic' do |basic|

#end

  s.subspec 'Rx' do |rx|
    rx.xcconfig = { 'OTHER_CFLAGS' => '$(inherited) -DREDUX_INCLUDE_RX' }
    rx.dependency 'RxSwift'
  end

  s.subspec 'PromiseKit' do |promisekit|
    promisekit.xcconfig = { 'OTHER_CFLAGS' => '$(inherited) -DREDUX_INCLUDE_PROMISEKIT' }
    promisekit.dependency 'PromiseKit'
  end

end
