//
//  Help2VC.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 10/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import MarkdownKit

class Help2VC: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let markdownParser = MarkdownParser()
        textView.attributedText = markdownParser.parse(RemoteValues.helpMarkdown)
    }
}
