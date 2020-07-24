//
//  AboutPerson.swift
// eRouska
//
//  Created by Lukáš Foldýna on 21/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct AboutPerson: Codable {

    let id = UUID()
    let name: String
    let surname: String
    var fullname: String {
        var parts: [String] = []
        if !name.isEmpty {
            parts.append(name)
        }
        if !surname.isEmpty {
            parts.append(surname)
        }
        return parts.joined(separator: " ")
    }
    let linkedin: String?
    let photoUrl: String?

}
