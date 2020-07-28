//
//  Auth.swift
// eRouska
//
//  Created by Lukáš Foldýna on 02/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

extension String {
    
    var phoneFormatted: String {
        let countryCode = self.dropLast(9)
        let phone = String(self.suffix(9))
        return countryCode + " " + phone.chunkFormatted(withChunkSize: 3)
    }
}
