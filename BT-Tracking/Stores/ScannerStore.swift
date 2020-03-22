//
//  ScannerStore.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 18/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

private let scanningPeriod = 120
private let scanningDelay = 0

class ScannerStore {
    
    let currentScan = PublishRelay<[DeviceScan]>()
    let scans: Observable<[DeviceScan]>
    
    private let scanObjects: Results<DeviceScanRealm>
    private let bag = DisposeBag()
    
    private let didFindSubject = PublishRelay<BTDevice>()
    private let didUpdateSubject = PublishRelay<BTDevice>()
    private let didReceive: Observable<BTDevice>
    private let timer: Observable<Int> = Observable.timer(.seconds(scanningDelay), period: .seconds(scanningPeriod), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
    private var period: BehaviorSubject<Void> {
        return BehaviorSubject<Void>(value: ())
    }
    private var currentPeriod: BehaviorSubject<Void>?
    private var devices = [BTDevice]()
    private var currentDevices = [BTDevice]()
    
    init() {
        didReceive = Observable.merge(didFindSubject.asObservable(), didUpdateSubject.asObservable())
        let realm = try! Realm()
        scanObjects = realm.objects(DeviceScanRealm.self)
        scans = Observable.array(from: scanObjects)
            .map { scanned in
                return scanned.map { $0.toDeviceScan() }
            }
        bindScanning()
    }
    
    private func bindScanning() {
        // Periods
        currentPeriod = period
        bind(newPeriod: currentPeriod)
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
                self?.updateCurrent()
            })
            .disposed(by: bag)
    }
    
    private func bind(newPeriod: BehaviorSubject<Void>?) {
        newPeriod?
            .subscribe(onCompleted: { [unowned self] in
                self.currentPeriod = self.period
                self.bind(newPeriod: self.currentPeriod)
                self.process(self.devices, at: Date())
                self.devices.removeAll()
            })
            .disposed(by: bag)
    }
    
    private func process(_ devices: [BTDevice], at date: Date) {
        let grouped = Dictionary(grouping: devices, by: { $0.bluetoothIdentifier })
        let averaged = grouped.map { group -> BTDevice in
            let average = Int(group.value.map{ $0.rssi }.average.rounded())
            var device = group.value.first!
            device.rssi = average
            device.date = date
            return device
        }
        let deviceScans = averaged.map { $0.toDeviceScan() }
        deviceScans.forEach { addDeviceToStorage(device: $0) }
    }
    
    private func updateCurrent() {
        let grouped = Dictionary(grouping: devices, by: { $0.bluetoothIdentifier })
        let latestDevices = grouped
            .map { group -> BTDevice? in
                let sorted = group.value.sorted(by: { $0.date < $1.date })
                return sorted.last
            }
            .compactMap{ $0 }
            .map { $0.toDeviceScan()}
        currentScan.accept(latestDevices)
    }
    
    private func addDeviceToStorage(device: DeviceScan) {
        let storageData = DeviceScanRealm(device: device)
        let realm = try! Realm()
        try! realm.write {
            realm.add(storageData, update: .all)
        }
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
    
    func clear() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
}

extension Collection where Element: Numeric {
    /// Returns the total sum of all elements in the array
    var total: Element { reduce(0, +) }
}

extension Collection where Element: BinaryInteger {
    /// Returns the average of all elements in the array
    var average: Double { isEmpty ? 0 : Double(total) / Double(count) }
}
