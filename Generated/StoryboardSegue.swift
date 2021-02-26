// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Segues

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardSegue {
  internal enum Active: String, SegueType {
    case debugReports
    case howItWorks
    case sendReport
    case traveler
  }
  internal enum Error: String, SegueType {
    case help = "Help"
  }
  internal enum Help: String, SegueType {
    case about
    case howItWorks
    case question
    case section
  }
  internal enum Onboarding: String, SegueType {
    case efgsPermission
    case exposureNotification
    case privacy
    case unsupported
  }
  internal enum RiskyEncounters: String, SegueType {
    case help
    case mainSymptoms
    case preventTransmission
    case previousRiskyEncounters
    case showDetailV1
    case showDetailV2
  }
  internal enum SendReports: String, SegueType {
    case agreement
    case efgs
    case noCode
    case result
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol SegueType: RawRepresentable {}

internal extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

internal extension SegueType where RawValue == String {
  init?(_ segue: UIStoryboardSegue) {
    guard let identifier = segue.identifier else { return nil }
    self.init(rawValue: identifier)
  }
}
