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
  s.summary          = 'A Swift implementation of Redux'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
An implementation of [Redux](https://github.com/reactjs/redux) (the Flux-like state container)
in Swift. Supports middleware, as well as combining reducers using `CombinedReducer(...).combine()`.
Any object can be used for your State and Action objects. However, it is recommended to use structs
and enums, respectively, for these objects. This allows you to not worry about accidentally mutating
state (Swift passes struct by value rather than reference) and makes passing action data easy (using
enum tuples).

By default, it ships with a `BaseStore` object which can't be subscribed to by views. There are a few
options included in this library:

- [Observable-Swift](https://github.com/slazyk/Observable-Swift) - Simple property-observing library
- [RxSwift](https://github.com/ReactiveX/RxSwift) - ReactiveX Observable Pattern implementation. Similar
to rx-redux, it allows stores to act as an observer for Actions and an Observable for State
                       DESC

  s.homepage         = 'https://github.com/rabidaudio/SwiftRedux'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Charles Julian Knight' => 'charles@rabidaudio.com' }
  s.source           = { :git => 'https://github.com/rabidaudio/SwiftRedux.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/charlesjuliank'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SwiftRedux/Classes/*'
  
  # s.resource_bundles = {
  #   'SwiftRedux' => ['SwiftRedux/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.subspec 'Observable-Swift' do |os|
    os.xcconfig = { 'OTHER_CFLAGS' => '$(inherited) -DREDUX_INCLUDE_OBSERVABLESWIFT' }
    os.source_files = 'SwiftRedux/Classes/ObservableSwift/**/*'
    os.dependency 'Observable-Swift', '~> 0.6.0'
  end

  s.subspec 'RxSwift' do |rx|
    rx.xcconfig = { 'OTHER_CFLAGS' => '$(inherited) -DREDUX_INCLUDE_RX' }
    rx.source_files = 'SwiftRedux/Classes/Rx/**/*'
    rx.dependency 'RxSwift', '~> 2.6'
  end

  s.subspec 'PromiseKit' do |promisekit|
    promisekit.xcconfig = { 'OTHER_CFLAGS' => '$(inherited) -DREDUX_INCLUDE_PROMISEKIT' }
    promisekit.source_files = 'SwiftRedux/Classes/PromiseKit/**/*'
    promisekit.dependency 'PromiseKit', '~> 3.3'
  end

end
