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

        var tabBarIcon: (UIImage, UIImage) {
            switch self {
            case .enabled:
                return (Asset.homeActive.image, Asset.homeActiveSelected.image)
            case .paused:
                return (Asset.homePaused.image, Asset.homePausedSelected.image)
            case .disabledBluetooth, .disabledExposures:
                return (Asset.homeDisabled.image, Asset.homePausedSelected.image)
            }
        }

        var color: UIColor {
            switch self {
            case .enabled:
                return Asset.appEnabled.color
            case .paused:
                return Asset.appPaused.color
            case .disabledBluetooth, .disabledExposures:
                return Asset.appDisabled.color
            }
        }

        var image: UIImage {
            switch self {
            case .enabled:
                return Asset.scanActive.image
            case .paused:
                return Asset.bluetoothPaused.image
            case .disabledBluetooth:
                return Asset.bluetoothOff.image
            case .disabledExposures:
                return Asset.exposuresOff.image
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

    var menuRiskyEncounters: String {
        RemoteValues.exposureUITitle
    }
    let menuSendReports = "data_list_send_title"
    let menuDebug = "debug"
    let menuCancel = "close"

    let backgroundModeTitle = "active_background_mode_title"
    let backgroundModeMessage = "active_background_mode_message"
    let backgroundModeAction = "active_background_mode_settings"
    let backgroundModeCancel = "active_background_mode_cancel"

    var exposureTitle: String {
        RemoteValues.exposureBannerTitle
    }
    let exposureBannerClose = "close"
    let exposureMoreInfo = "active_exposure_more_info"

    let errorActivationRestrictedTitle = "exposure_activation_restricted_title"
    let errorActivationRestrictedBody = "exposure_activation_restricted_body"
    let errorActivationSettingsTitle = "exposure_activation_restricted_settings_action"
    let errorActivationCancelTitle = "exposure_activation_restricted_cancel_action"

    let errorActivationUnknownTitle = "exposure_activation_unknown_title"
    let errorActivationUnknownBody = "exposure_activation_unknown_body"

    let errorActivationStorageTitle = "exposure_activation_storage_title"
    let errorActivationStorageBody = "exposure_activation_storage_body"

    let errorDeactivationUnknownTitle = "exposure_deactivation_unknown_title"
    let errorDeactivationUnknownBody = "exposure_deactivation_unknown_body"

    let errorSendDataTitle = "data_list_send_error_disabled_title"
    let errorSendDataMessage = "data_list_send_error_disabled_message"
    let errorSendDataActionClose = "close"
    let errorSendDataActionTurnOn = "turn_on"

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        return formatter
    }()

    var state: State {
        let state = try? observableState.value()
        return state ?? .disabledExposures
    }
    private(set) var observableState: BehaviorSubject<State>
    private(set) var exposureToShow: Observable<Exposure?>
    private let disposeBag = DisposeBag()

    let exposureService: ExposureServicing = AppDelegate.dependency.exposureService
    let reporter: ReportServicing = AppDelegate.dependency.reporter
    let backgroundService = AppDelegate.dependency.background

    init() {
        observableState = BehaviorSubject<State>(value: .paused)

        let showForDays = RemoteValues.serverConfiguration.showExposureForDays
        let realm = try? Realm()
        guard let exposures = realm?.objects(ExposureRealm.self).sorted(byKeyPath: "date") else {
            exposureToShow = .empty()
            return
        }

        let showForDate = Calendar.current.date(byAdding: .day, value: -showForDays, to: Date()) ?? Date()
        exposureToShow = Observable.collection(from: exposures).map {
            $0.last(where: { $0.date > showForDate })?.toExposure()
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
        case .paused, .disabled, .unauthorized:
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
