//
//  HelpEntities.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 24.01.2021.
//  Copyright © 2021 Covid19CZ. All rights reserved.
//

import Foundation

struct HelpSection: Codable {
    let title: String
    let subtitle: String
    let icon: String
    let question: [HelpQuestion]
}

struct HelpQuestion: Codable {
    let quenstion: String
    let answer: String
}

typealias Help = [HelpSection]
