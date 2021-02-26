//
//  Other.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 18.02.2021.
//

import Foundation
import FirebaseFunctions
import RealmSwift

protocol HasOther {

    var deviceToken: Data? { get }

}

protocol HasFunctions {
    var functions: Functions { get }
}

protocol HasRealm {
    var realm: Realm { get }
}
