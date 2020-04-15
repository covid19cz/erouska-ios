//
//  Markdown.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 15/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import SwiftyMarkdown

struct Markdown {
    
    static func attributedString(markdown: String) -> NSAttributedString {
        var editedMD = RemoteValues.helpMarkdown.replacingOccurrences(of: "\\n", with: "\u{0085}")
        editedMD = editedMD.replacingOccurrences(of: "(.pdf)", with: "")
        print(editedMD)

        let md = SwiftyMarkdown(string: editedMD)

        let body = UIFont.preferredFont(forTextStyle: .body)
        md.body.fontSize = body.pointSize

        let h1 = UIFont.preferredFont(forTextStyle: .headline)
        md.h1.fontSize = h1 .pointSize
        md.h1.fontStyle = .bold

        let h2 = UIFont.preferredFont(forTextStyle: .subheadline)
        md.h2.fontSize = h2.pointSize
        md.h2.fontStyle = .bold

        let attributedText = NSMutableAttributedString(attributedString: md.attributedString())
        var textColor: UIColor {
            if #available(iOS 13.0, *) {
                return .label
            } else {
                return .black
            }
        }
        attributedText.addAttribute(.foregroundColor, value: textColor, range: NSMakeRange(0, attributedText.length))
        return attributedText
    }

}
