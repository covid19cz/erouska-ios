//
//  CSVWriter.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 23/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import RealmSwift
import CSV

protocol CSVMakering {

    typealias Callback = (_ fileURL: URL?, _ error: Error?) -> Void

    func createFile(callback: @escaping Callback)

}

/*
buid,timestampStart,timestampEnd,minRssi,maxRssi,avgRssi,medRssi
b5e446a423330ca0e143,1584896543951,1584896587921,0,-38,0,-63
b5e446a423330ca0e143,1584896663553,1584896686886,0,-63,0,-68
b5e446a423330ca0e143,1584897450231,1584897452256,0,-74,0,-75
*/

final class CSVMaker: CSVMakering {

    private(set) var fileURL: URL

    init?() {
        guard let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return nil }
        self.fileURL = URL(fileURLWithPath: documents).appendingPathComponent("db.csv")
    }

    func createFile(callback: @escaping Callback) {
        guard let stream = OutputStream(toFileAtPath: fileURL.path, append: false) else {
            callback(nil, NSError(domain: "CSV", code: 500, userInfo: nil) as Error)
            return
        }

        let csv: CSVWriter
        let realm: Realm
        do {
            csv = try CSVWriter(stream: stream)
            try csv.write(row: ["buid", "timestampStart", "timestampEnd", "minRssi", "maxRssi", "avgRssi", "medRssi"])
            
            realm = try Realm()
        } catch {
            callback(nil, error)
            return
        }

        let scanObjects = realm.objects(ScanRealm.self)
        for scan in scanObjects {
            let signal = String(scan.rssi)

            try? csv.write(row: [
                scan.buid,
                String(scan.date.timeIntervalSince1970),
                String(scan.date.timeIntervalSince1970),
                String(0),
                signal,
                String(0),
                signal
            ])
        }

        csv.stream.close()
        callback(fileURL, nil)
    }

}
