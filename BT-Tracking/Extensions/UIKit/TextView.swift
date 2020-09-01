//
//  TextView.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 27/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

extension UITextView {

    func hyperLink(originalText: String, hyperLink: String, urlString: String) {
        let attributedOriginalText = NSMutableAttributedString(string: originalText)

        attributedOriginalText.addAttribute(
            .font,
            value: UIFont.preferredFont(forTextStyle: .body),
            range: NSMakeRange(0, attributedOriginalText.length)
        )
        attributedOriginalText.addAttribute(
            .foregroundColor,
            value: textColor ?? .label,
            range: NSMakeRange(0, attributedOriginalText.length)
        )
        attributedOriginalText.addAttribute(
            .link,
            value: urlString,
            range: attributedOriginalText.mutableString.range(of: hyperLink)
        )

        linkTextAttributes = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ]
        attributedText = attributedOriginalText
    }
}
