//
//  ActiveAppViewModel.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 25/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift

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
                return L10n.activeHeadEnabled
            case .paused:
                return L10n.activeHeadPaused
            case .disabledBluetooth:
                return L10n.activeHeadDisabledBluetooth
            case .disabledExposures:
                return L10n.activeHeadDisabledExposures
            }
        }

        var title: String? {
            switch self {
            case .enabled:
                return L10n.activeTitleHighlightedEnabled
            default:
                return nil
            }
        }

        var text: String {
            switch self {
            case .enabled:
                return L10n.activeFooter
            case .paused:
                return L10n.activeTitlePaused
            case .disabledBluetooth:
                return L10n.activeTitleDisabledBluetooth
            case .disabledExposures:
                return L10n.activeTitleDisabledExposures
            }
        }

        var actionTitle: String {
            switch self {
            case .enabled:
                return L10n.activeButtonEnabled
            case .paused:
                return L10n.activeButtonPaused
            case .disabledBluetooth:
                return L10n.activeButtonDisabledBluetooth
            case .disabledExposures:
                return L10n.activeButtonDisabledExposures
            }
        }
    }

    var menuRiskyEncounters: String {
        RemoteValues.exposureUITitle
    }

    var exposureTitle: String {
        RemoteValues.exposureBannerTitle
    }

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

        if let observable = try? ExposureList.lastObservable() {
            exposureToShow = observable
        } else {
            exposureToShow = .empty()
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
