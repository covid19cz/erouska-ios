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

class ScannerStore {

    let scans: Observable<[DeviceScan]>
    
    private let realm = try! Realm()
    private let scanObjects: Results<DeviceScanRealm>
    private let bag = DisposeBag()
    
    private let didFindSubject = PublishRelay<BTDevice>()
    private let didUpdateSubject = PublishRelay<BTDevice>()
    private let didReceive: Observable<BTDevice>
    private let timer: Observable<Int> = Observable.timer(.seconds(0), period: .seconds(20), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
    private var period: BehaviorSubject<Void> {
        return BehaviorSubject<Void>(value: ())
    }
    private var currentPeriod: BehaviorSubject<Void>?
    private var devices = [BTDevice]()
    
    init() {
        didReceive = Observable.merge(didFindSubject.asObservable(), didUpdateSubject.asObservable())
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
        NSLog("\(grouped)")
        let averaged = grouped.map { group -> BTDevice in
            let average = Int(group.value.map{ $0.rssi }.average.rounded())
            var device = group.value.first!
            device.rssi = average
            return device
        }
        NSLog("new record: \(averaged)")
    }
    
    private func scan(from device: BTDevice) -> DeviceScan {
        return DeviceScan(
            id: device.id,
            bluetoothIdentifier: device.bluetoothIdentifier.uuidString,
            buid: device.backendIdentifier ?? "Unknown",
            platform: device.platform,
            name: device.name ?? "Unknown",
            date: device.date,
            rssi: device.rssi
        )
    }
}

extension ScannerStore: BTScannerDelegate {

    func didFind(device: BTDevice) {
        didFindSubject.accept(device)
//        let updatedScans = scans.value + [scan(from: device)]
//        scans.accept(updatedScans)
    }

    func didUpdate(device: BTDevice) {
        didUpdateSubject.accept(device)
//        let scan = self.scan(from: device)
//        let updatedScans: [DeviceScan]
//        if let oldIndex = scans.value.firstIndex(where: { $0.id == device.id }) {
//            var updated = scans.value
//            updated[oldIndex] = scan
//            updatedScans = updated
//        } else {
//            updatedScans = scans.value + [scan]
//        }
//        scans.accept(updatedScans)
    }
}





//class ScannerStore: BTScannerStoreDelegate {
//
//    let scans: Observable<[DeviceScan]>
//    let storedScans = BehaviorRelay<[DeviceScan]>(value: [])
//
//    private let realm = try! Realm()
//    private var storedScansToken: NotificationToken!
//    private let scanObjects: Results<DeviceScanRealm>
//    private let bag = DisposeBag()
//
//    init() {
//        scanObjects = realm.objects(DeviceScanRealm.self)
//        scans = Observable.array(from: scanObjects)
//            .map { scanned in
//                return scanned.map { $0.toDeviceScan() }
//            }
//        bindRealm()
//        storedScansToken = realm.objects(DeviceScanRealm.self).observe { [weak self] _ in
//            guard let self = self else { return }
//            let scans: [DeviceScan] = self.realm.objects(DeviceScanRealm.self).map { $0.toDeviceScan() }
//            self.storedScans.accept(scans)
//       }
//    }
//
//    func didFind(device: CBPeripheral, rssi: Int) {
//        let scan = DeviceScan(
//            bluetoothIdentifier: device.identifier.uuidString,
//            buid: "",
//            platform: .iOS,
//            name: device.name ?? "Unknown",
//            date: Date(),
//            rssi: rssi
//        )
//        addDeviceToStorage(device: scan)
//    }
//
//    private func addDeviceToStorage(device: DeviceScan) {
//        let storageData = DeviceScanRealm(device: device)
//        try! realm.write {
//            realm.add(storageData, update: .all)
//        }
//        let updatedScans = scans.value + [device]
//        scans.accept(updatedScans)
//    }
    
//    private func bindRealm() {
//        Observable.array(from: scanObjects)
//            .map { scanned in
//                return scanned.map { $0.toDeviceScan() }
//        }
//        .subscribe(onNext: { scans in
//            print("Scans count: \(scans.count)")
//        })
//        .disposed(by: bag)
//    }
//}

extension Collection where Element: Numeric {
    /// Returns the total sum of all elements in the array
    var total: Element { reduce(0, +) }
}

extension Collection where Element: BinaryInteger {
    /// Returns the average of all elements in the array
    var average: Double { isEmpty ? 0 : Double(total) / Double(count) }
}
