//
//  ActiveAppViewModel.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 25/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import RxRealm

final class ActiveAppVM {

    enum State: String {
        case enabled
        case paused
        case disabledBluetooth = "disabled"
        case disabledExposures

        var tabBarIcon: (UIImage?, UIImage?) {
            let name: String
            switch self {
            case .enabled:
                name = "HomeActive"
            case .paused:
                name = "HomePaused"
            case .disabledBluetooth, .disabledExposures:
                name = "HomeDisabled"
            }
            return (UIImage(named: name), UIImage(named: "\(name)Selected"))
        }

        var color: UIColor {
            switch self {
            case .enabled:
                return #colorLiteral(red: 0.6116178036, green: 0.7910612226, blue: 0.3123690188, alpha: 1)
            case .paused:
                return #colorLiteral(red: 0.8926691413, green: 0.5397555232, blue: 0.1979260743, alpha: 1)
            case .disabledBluetooth, .disabledExposures:
                return #colorLiteral(red: 0.8860370517, green: 0.2113904059, blue: 0.3562591076, alpha: 1)
            }
        }

        var image: UIImage? {
            switch self {
            case .enabled:
                return UIImage(named: "ScanActive")
            case .paused:
                return UIImage(named: "BluetoothPaused")
            case .disabledBluetooth:
                return UIImage(named: "BluetoothOff")
            case .disabledExposures:
                return UIImage(named: "ExposuresOff")
            }
        }

        var headline: String {
            switch self {
            case .enabled:
                return "active_head_enabled"
            case .paused:
                return "active_head_paused"
            case .disabledBluetooth:
                return "active_head_disabled_bluetooth"
            case .disabledExposures:
                return "active_head_disabled_exposures"
            }
        }

        var title: String? {
            switch self {
            case .enabled:
                return "active_title_highlighted_enabled"
            default:
                return nil
            }
        }

        var text: String {
            switch self {
            case .enabled:
                return "active_footer"
            case .paused:
                return "active_title_paused"
            case .disabledBluetooth:
                return "active_title_disabled_bluetooth"
            case .disabledExposures:
                return "active_title_disabled_exposures"
            }
        }

        var actionTitle: String {
            switch self {
            case .enabled:
                return "active_button_enabled"
            case .paused:
                return "active_button_paused"
            case .disabledBluetooth:
                return "active_button_disabled_bluetooth"
            case .disabledExposures:
                return "active_button_disabled_exposures"
            }
        }
    }

    let title = "app_name"
    let back = "back"
    let tabTitle = "app_name"

    let shareApp = "share_app"
    let shareAppMessage = "share_app_message"

    let lastUpdateText = "active_data_update"

    let menuRiskyEncounters = "risky_encounters_button"
    let menuSendReports = "data_list_send_button"
    let menuDebug = "debug"
    let menuCancelRegistration = "cancel_registration_button"
    let menuAbout = "about"
    let menuCancel = "close"

    let backgroundModeTitle = "active_background_mode_title"
    let backgroundModeMessage = "active_background_mode_title"
    let backgroundModeAction = "active_background_mode_settings"
    let backgroundModeCancel = "active_background_mode_cancel"

    let exposureTitle = RemoteValues.exposureBannerTitle
    let exposureBannerClose = "close"
    let exposureMoreInfo = "active_exposure_more_info"

    let errorActivationRestiredTitle = "exposure_activation_restricted_title"
    let errorActivationRestiredBody = "exposure_activation_restricted_body"
    let errorActivationSettingsTitle = "exposure_activation_restricted_settings_action"
    let errorActivationCancelTitle = "exposure_activation_restricted_cancel_action"

    let errorActivationUnknownTitle = "exposure_activation_unknown_title"
    let errorActivationUnknownBody = "exposure_activation_unknown_body"

    let errorDeactivationUnknownTitle = "exposure_deactivation_unknown_title"
    let errorDeactivationUnknownBody = "exposure_deactivation_unknown_body"

    var dateFormatter: DateFormatter {
        let formatrer = DateFormatter()
        formatrer.timeStyle = .short
        formatrer.dateStyle = .short
        return formatrer
    }

    var state: State {
        return try! observableState.value()
    }
    private(set) var observableState: BehaviorSubject<State>
    private(set) var exposureToShow: Observable<Exposure?>
    private let disposeBag = DisposeBag()

    let exposureService: ExposureServicing = AppDelegate.dependency.exposureService
    let reporter: ReportServicing = AppDelegate.dependency.reporter
    let backgroundService = AppDelegate.dependency.background

    init() {
        observableState = BehaviorSubject<State>(value: .paused)

        let lastPossibleDate = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
        let realm = try! Realm()
        let exposures = realm
            .objects(ExposureRealm.self)
            .sorted(byKeyPath: "date")

        exposureToShow = Observable.collection(from: exposures)
            .map {
                $0.filter { $0.date > lastPossibleDate }.last?.toExposure()
            }

        exposureService.readyToUse
            .subscribe { [weak self] _ in
                self?.updateStateIfNeeded()
            }.disposed(by: disposeBag)
    }

    func cardShadowColor(traitCollection: UITraitCollection) -> CGColor {
        return UIColor.label.resolvedColor(with: traitCollection).withAlphaComponent(0.2).cgColor
    }

    func updateStateIfNeeded() {
        switch exposureService.status {
        case .active:
            observableState.onNext(.enabled)
        case .paused, .disabled:
            observableState.onNext(.paused)
        case .bluetoothOff:
            observableState.onNext(.disabledBluetooth)
        case .restricted:
            observableState.onNext(.disabledExposures)
        case .unknown:
            observableState.onNext(.paused)
        @unknown default:
            return
        }
    }
}
