//
//  Markdown.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 15/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import SwiftyMarkdown

struct Markdown {

    static func attributedString(markdown: String, lines: [SwiftyLine]) -> NSAttributedString {
        var editedMD = markdown.replacingOccurrences(of: "\\n", with: "\u{0085}")
        editedMD = editedMD.replacingOccurrences(of: "(.pdf)", with: "")

        let md = SwiftyMarkdown(string: editedMD)

        let body = UIFont.preferredFont(forTextStyle: .body)
        md.body.fontSize = body.pointSize

        let h1 = UIFont.preferredFont(forTextStyle: .headline)
        md.h1.fontSize = h1.pointSize
        md.h1.fontStyle = .bold

        let h2 = UIFont.preferredFont(forTextStyle: .subheadline)
        md.h2.fontSize = h2.pointSize
        md.h2.fontStyle = .bold

        let attributedText = NSMutableAttributedString(attributedString: md.attributedString(lines: lines))
        attributedText.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: attributedText.length))
        return attributedText
    }
}
