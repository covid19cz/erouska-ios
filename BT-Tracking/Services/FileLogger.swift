//
//  FileLogger.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 16/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

class FileLogger {
    
    static let shared = FileLogger()
    private var fileURL: URL!
    
    init() {
        guard let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
        let documentsURL = URL(fileURLWithPath: documents)
        fileURL = documentsURL.appendingPathComponent("application.log")
    }
    
    func writeLog(_ text: String) {
        do {
            let newText = getLog() + "\n" + formatter.string(from: Date()) + " " + text
            try newText.write(to: fileURL, atomically: false, encoding: .utf8)
        } catch {
            print("Unexpected error writing to log: \(error)")
        }
    }
    
    func getLog() -> String {
        do {
            let text = try String(contentsOf: fileURL, encoding: .utf8)
            return text
        } catch {
            print("Unexpected error reading from log: \(error)")
            return ""
        }
    }
    
    func purgeLogs() {
        do {
            try "".write(to: fileURL, atomically: false, encoding: .utf8)
        } catch {
            print("Unexpected error writing to log: \(error)")
        }
    }
}

private var formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .medium
    return formatter
}()
