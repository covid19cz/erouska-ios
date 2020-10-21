// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let bluetoothOff = ImageAsset(name: "BluetoothOff")
  internal static let bluetoothPaused = ImageAsset(name: "BluetoothPaused")
  internal static let buttonBorder = ColorAsset(name: "ButtonBorder")
  internal static let chat = ImageAsset(name: "Chat")
  internal static let appDisabled = ColorAsset(name: "AppDisabled")
  internal static let appEnabled = ColorAsset(name: "AppEnabled")
  internal static let appPaused = ColorAsset(name: "AppPaused")
  internal static let conditionsOfUse = ImageAsset(name: "ConditionsOfUse")
  internal enum CurrentData {
    internal static let active = ImageAsset(name: "CurrentData/Active")
    internal static let covid = ImageAsset(name: "CurrentData/Covid")
    internal static let death = ImageAsset(name: "CurrentData/Death")
    internal static let healthy = ImageAsset(name: "CurrentData/Healthy")
    internal static let hospital = ImageAsset(name: "CurrentData/Hospital")
    internal static let measures = ImageAsset(name: "CurrentData/Measures")
    internal static let tests = ImageAsset(name: "CurrentData/Tests")
  }
  internal static let error = ImageAsset(name: "Error")
  internal static let exposureNotificationPermission = ImageAsset(name: "ExposureNotificationPermission")
  internal static let exposuresOff = ImageAsset(name: "ExposuresOff")
  internal static let forceOSUpdate = ImageAsset(name: "ForceOSUpdate")
  internal static let forceUpdate = ImageAsset(name: "ForceUpdate")
  internal static let helpBackground = ColorAsset(name: "HelpBackground")
  internal static let iconsColor = ColorAsset(name: "IconsColor")
  internal static let launchScreenBackground = ColorAsset(name: "LaunchScreenBackground")
  internal static let launchScreenHands = ImageAsset(name: "LaunchScreenHands")
  internal static let launchScreenLogo = ImageAsset(name: "LaunchScreenLogo")
  internal static let mainSymptoms = ImageAsset(name: "MainSymptoms")
  internal static let minLogo = ImageAsset(name: "MinLogo")
  internal static let newsAlwaysActive = ImageAsset(name: "News_AlwaysActive")
  internal static let newsExposureNotification = ImageAsset(name: "News_ExposureNotification")
  internal static let newsNoPhoneNumber = ImageAsset(name: "News_NoPhoneNumber")
  internal static let newsPrivacy = ImageAsset(name: "News_Privacy")
  internal static let newsToTheWorld = ImageAsset(name: "News_ToTheWorld")
  internal static let preventTransmission = ImageAsset(name: "PreventTransmission")
  internal static let previousRiskyEncounters = ImageAsset(name: "PreviousRiskyEncounters")
  internal static let scanActive = ImageAsset(name: "ScanActive")
  internal static let contacts = ImageAsset(name: "Contacts")
  internal static let help = ImageAsset(name: "Help")
  internal static let homeActive = ImageAsset(name: "HomeActive")
  internal static let homeActiveSelected = ImageAsset(name: "HomeActiveSelected")
  internal static let homeDisabled = ImageAsset(name: "HomeDisabled")
  internal static let homeDisabledSelected = ImageAsset(name: "HomeDisabledSelected")
  internal static let homePaused = ImageAsset(name: "HomePaused")
  internal static let homePausedSelected = ImageAsset(name: "HomePausedSelected")
  internal static let myData = ImageAsset(name: "MyData")
  internal static let gdpr = ImageAsset(name: "gdpr")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    Bundle(for: BundleToken.self)
  }()
}
// swiftlint:enable convenience_type
