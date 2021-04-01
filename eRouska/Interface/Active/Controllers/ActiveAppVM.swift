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
            case .enabled, .paused:
                return .textLabel
            case .disabledBluetooth, .disabledExposures:
                return Asset.alertRed.color
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

        var text: String {
            switch self {
            case .enabled:
                return L10n.activeTitleEnabled
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

    // MARK: - Dependencies

    typealias Dependencies = HasRealm & HasExposureService & HasExposureList

    private let dependencies: Dependencies

    // MARK: -

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

    let riskyEncounterDateToShow: Observable<Date?>
    let riskyEncountersInTimeInterval: Observable<Int>

    var efgsEnabled: Bool {
        AppSettings.efgsEnabled
    }
    var efgsTitle: String {
        L10n.efgsSettingsTitle
    }
    var efgsBody: String {
        efgsEnabled ? L10n.activeEfgsEnabled : L10n.activeEfgsDisabled
    }

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        let showForDays = RemoteValues.serverConfiguration.showExposureForDays
        let exposures = dependencies.realm.objects(ExposureRealm.self).sorted(byKeyPath: "date")
        let showForDate = Calendar.current.date(byAdding: .day, value: -showForDays, to: Date()) ?? Date()
        let riskyEncounters = Observable.collection(from: exposures)
        let filteredRiskyEncounters = riskyEncounters.map { $0.filter { $0.date > showForDate } }
        riskyEncounterDateToShow = filteredRiskyEncounters.map { $0.last?.date }
        riskyEncountersInTimeInterval = filteredRiskyEncounters.map { $0.count }

        observableState = BehaviorSubject<State>(value: .paused)

        if let observable = try? dependencies.exposureList.lastObservable() {
            exposureToShow = observable
        } else {
            exposureToShow = .empty()
        }
        dependencies.exposure.readyToUse
            .subscribe { [weak self] _ in
                self?.updateStateIfNeeded()
            }.disposed(by: disposeBag)
    }

    func updateStateIfNeeded() {
        switch dependencies.exposure.status {
        case .active:
            observableState.onNext(.enabled)
        case .paused, .disabled:
            observableState.onNext(.paused)
        case .bluetoothOff:
            observableState.onNext(.disabledBluetooth)
        case .restricted, .unauthorized, .unknown:
            observableState.onNext(.disabledExposures)
        @unknown default:
            return
        }
    }
}
