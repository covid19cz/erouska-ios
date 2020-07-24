//
//  AboutTeam.swift
// eRouska
//
//  Created by Lukáš Foldýna on 21/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct AboutTeam: Codable {

    let id: Int
    let name: String
    let people: [AboutPerson]

}
