// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum Active: StoryboardType {
    internal static let storyboardName = "Active"

    internal static let initialScene = InitialSceneType<TabBarController>(storyboard: Active.self)
  }
  internal enum CurrentData: StoryboardType {
    internal static let storyboardName = "CurrentData"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: CurrentData.self)
  }
  internal enum Debug: StoryboardType {
    internal static let storyboardName = "Debug"

    internal static let initialScene = InitialSceneType<TabBarController>(storyboard: Debug.self)

    internal static let tabBar = SceneType<TabBarController>(storyboard: Debug.self, identifier: "TabBar")
  }
  internal enum Error: StoryboardType {
    internal static let storyboardName = "Error"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Error.self)
  }
  internal enum ForceUpdate: StoryboardType {
    internal static let storyboardName = "ForceUpdate"

    internal static let forceOSUpdateVC = SceneType<ForceOSUpdateVC>(storyboard: ForceUpdate.self, identifier: "ForceOSUpdateVC")

    internal static let forceUpdateVC = SceneType<ForceUpdateVC>(storyboard: ForceUpdate.self, identifier: "ForceUpdateVC")

    internal static let unsupportedDeviceVC = SceneType<UnsupportedDeviceVC>(storyboard: ForceUpdate.self, identifier: "UnsupportedDeviceVC")
  }
  internal enum Help: StoryboardType {
    internal static let storyboardName = "Help"

    internal static let initialScene = InitialSceneType<HelpVC>(storyboard: Help.self)

    internal static let about = SceneType<AboutVC>(storyboard: Help.self, identifier: "About")

    internal static let help = SceneType<HelpVC>(storyboard: Help.self, identifier: "Help")

    internal static let helpArticle = SceneType<HelpArticleVC>(storyboard: Help.self, identifier: "HelpArticle")

    internal static let helpNavigation = SceneType<UIKit.UINavigationController>(storyboard: Help.self, identifier: "HelpNavigation")

    internal static let helpSearchVC = SceneType<HelpSearchVC>(storyboard: Help.self, identifier: "HelpSearchVC")
  }
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIKit.UIViewController>(storyboard: LaunchScreen.self)
  }
  internal enum News: StoryboardType {
    internal static let storyboardName = "News"

    internal static let initialScene = InitialSceneType<NavigationController>(storyboard: News.self)
  }
  internal enum Onboarding: StoryboardType {
    internal static let storyboardName = "Onboarding"

    internal static let initialScene = InitialSceneType<NavigationController>(storyboard: Onboarding.self)

    internal static let onboardingActivatedUser = SceneType<NavigationController>(storyboard: Onboarding.self, identifier: "OnboardingActivatedUser")
  }
  internal enum RiskyEncounters: StoryboardType {
    internal static let storyboardName = "RiskyEncounters"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: RiskyEncounters.self)
  }
  internal enum SendReports: StoryboardType {
    internal static let storyboardName = "SendReports"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: SendReports.self)

    internal static let sendReportNav = SceneType<UIKit.UINavigationController>(storyboard: SendReports.self, identifier: "SendReportNav")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: BundleToken.bundle)
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    Bundle(for: BundleToken.self)
  }()
}
// swiftlint:enable convenience_type
