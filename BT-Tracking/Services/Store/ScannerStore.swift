//
//  ScannerStore.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 18/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift

final class ScannerStore {

    /// default 60
    private let scanningPeriod: Int
    /// default 0
    private let scanningDelay: Int = 0

    private let lastPurgeDateKey = "lastDataPurgeDate"

    /// 1 day... for testing set to 60 seconds for example
    private let dataPurgeCheckInterval: TimeInterval = 1 * 86400

    /// 14 days... for testing se to 300 seconds for example and see data older then 5 minutes being deleted
    private let dataPurgeInterval: TimeInterval

    let currentScan = BehaviorRelay<[Scan]>(value: [])
    let scans: Observable<[Scan]>
    let appTermination = PublishSubject<Void>()

    private let scanObjects: Results<ScanRealm>
    private let bag = DisposeBag()
    
    private let didFindSubject = PublishRelay<BTDevice>()
    private let didUpdateSubject = PublishRelay<BTDevice>()
    private let didReceive: Observable<BTDevice>
    private let timer: Observable<Int>
    private var period: BehaviorSubject<Void> {
        return BehaviorSubject<Void>(value: ())
    }
    private var currentPeriod: BehaviorSubject<Void>?
    private var devices = [BTDevice]()
    
    init(scanningPeriod: Int = 60, dataPurgeInterval: TimeInterval = 14 * 86400) {
        self.scanningPeriod = scanningPeriod
        self.dataPurgeInterval = dataPurgeInterval
        self.timer = Observable.timer(.seconds(scanningDelay), period: .seconds(scanningPeriod), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))

        didReceive = Observable.merge(didFindSubject.asObservable(), didUpdateSubject.asObservable())
        let realm = try! Realm()
        scanObjects = realm.objects(ScanRealm.self)
        scans = Observable.array(from: scanObjects)
            .map { scanned in
                return scanned.map { $0.toScan() }
            }
        bindScanning()
        bindAppTerminate()
    }
    
    private func bindScanning() {
        // Periods
        currentPeriod = period
        bind(newPeriod: currentPeriod, endsAt: Date() + Double(scanningPeriod))
        timer
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                self?.currentPeriod?.onCompleted()
            })
            .disposed(by: bag)

        // Device scans
        didReceive
            .subscribe(onNext: { [weak self] device in
                self?.devices.append(device)
                self?.updateCurrent(at: Date())
            })
            .disposed(by: bag)
    }
    
    private func bind(newPeriod: BehaviorSubject<Void>?, endsAt endDate: Date) {
        newPeriod?
            .subscribe(onCompleted: { [weak self] in
                self?.processPeriod(with: endDate)
            })
            .disposed(by: bag)
    }
    
    private func bindAppTerminate() {
        appTermination
            .subscribe(onNext: { [weak self] in
                self?.processPeriod(with: Date())
            })
            .disposed(by: bag)
    }
    
    private func processPeriod(with endDate: Date) {
        self.currentPeriod = self.period
        self.bind(newPeriod: self.currentPeriod, endsAt: Date() + Double(scanningPeriod))
        self.process(self.devices, at: endDate)
        self.devices.removeAll()
        self.deleteOldRecordsIfNeeded()
    }
    
    private func process(_ devices: [BTDevice], at date: Date) {
        let grouped = Dictionary(grouping: devices, by: { $0.deviceIdentifier })
        let averaged = grouped.map { group -> ScanRealm? in
            guard var device = group.value.first,
                let backendIdentifier = group.value.first(where: { $0.backendIdentifier != nil })?.backendIdentifier,
                let startDate = group.value.first?.date,
                let endDate = group.value.last?.date else { return nil }
            device.backendIdentifier = backendIdentifier

            let RSIIs = group.value.map { $0.rssi }
            let averageRssi = Int(RSIIs.average.rounded())
            var medianRssi: Int = 0
            if let median = RSIIs.median() {
                medianRssi = Int(median.rounded())
            }

            return ScanRealm(device: device, avargeRssi: averageRssi, medianRssi: medianRssi, startDate: startDate, endDate: endDate)
        }
        averaged.compactMap { $0 }.forEach { addDeviceToStorage(data: $0) }
    }
    
    private func updateCurrent(at date: Date) {
        let grouped = Dictionary(grouping: devices, by: { $0.deviceIdentifier })
        let latestDevices = grouped
            .map { group -> BTDevice? in
                return group.value.sorted(by: { $0.date > $1.date }).first
            }
            .compactMap { $0 }
            .map { [unowned self] device -> Scan in
                let uuid = self.currentScan.value.first(where: { $0.deviceIdentifier == device.deviceIdentifier })?.id
                return device.toScan(with: uuid)
            }
        currentScan.accept(latestDevices)
    }
    
    private func addDeviceToStorage(data: ScanRealm) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(data, update: .all)
            }
        } catch {
            log("Realm: Failed to write! \(error)")
        }
    }

    func deleteOldRecordsIfNeeded() {
        guard let lastPurgeDate = UserDefaults.standard.object(forKey: lastPurgeDateKey) as? Date else {
            storeLastPurgeDate()
            return
        }
        if lastPurgeDate + dataPurgeCheckInterval > Date() {
            return
        }
        deleteOldRecords()
    }
    
    private func deleteOldRecords() {
        do {
            let realm = try Realm()
            try realm.write {
                let cutOffDate = NSDate().addingTimeInterval(-dataPurgeInterval)
                let predicate = NSPredicate(format: "startDate < %@", cutOffDate)
                let oldObjects = realm.objects(ScanRealm.self).filter(predicate)
                realm.delete(oldObjects)
                storeLastPurgeDate()
            }
        } catch {
            log("Realm: Failed to delete! \(error)")
        }
    }
    
    private func storeLastPurgeDate() {
        UserDefaults.standard.set(Date(), forKey: lastPurgeDateKey)
    }
}

extension ScannerStore: BTScannerDelegate {

    func didFind(device: BTDevice) {
        didFindSubject.accept(device)
    }

    func didUpdate(device: BTDevice) {
        didUpdateSubject.accept(device)
    }
}

extension ScannerStore {
    
    func deleteAllData() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            log("Realm: Failed to delete! \(error)")
        }
    }
}
