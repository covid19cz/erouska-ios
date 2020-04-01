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

    typealias Result = (fileURL: URL, metadata: [String: String])
    typealias Callback = (_ result: Result?, _ error: Error?) -> Void

    var fromDate: Date? { get }

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
    private(set) var fromDate: Date?

    init?(fromDate: Date?) {
        guard let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return nil }
        self.fileURL = URL(fileURLWithPath: documents).appendingPathComponent("db.csv")
        self.fromDate = fromDate
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
            try csv.write(row: ["buid", "timestampStart", "timestampEnd", "avgRssi", "medRssi"])
            
            realm = try Realm()
        } catch {
            callback(nil, error)
            return
        }

        var data = realm.objects(ScanRealm.self)
        if let fromDate = fromDate {
            data = data.filter("startDate >= %@", fromDate)
        }

        data.forEach() { scan in
            try? csv.write(row: [
                scan.buid,
                String(scan.startDate.timeIntervalSince1970),
                String(scan.endDate.timeIntervalSince1970),
                String(scan.avargeRssi),
                String(scan.medianRssi)
            ])
        }
        csv.stream.close()

        let metadata = [
            "version": "3",
            "buid": AppSettings.BUID ?? ""
        ]

        callback(Result(fileURL, metadata), nil)
    }

}
