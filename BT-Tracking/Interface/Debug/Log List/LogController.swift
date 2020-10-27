//
//  LogController.swift
//  eRouska
//
//  Created by Tomas Svoboda on 16/03/2020.
//  Copyright © 2020 hatchery41. All rights reserved.
//

import UIKit

final class LogController: UIViewController {

    // MARK: - Outlets

    @IBOutlet private weak var textView: UITextView!

    // MARK: - Properties

    private var logText: String = "" {
        didSet {
            textView.text = logText
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Setup

    private func setup() {
        Log.delegate = self

        textView.text = ""
    }

    // MARK: -

    func purgeLog() {
        logText = ""
    }

}

extension LogController: LogDelegate {
    func didLog(_ text: String) {
        logToView(text)
    }
}

private extension LogController {
    private func logToView(_ text: String) {
        logText += "\n" + DateFormatter.baseDateFormatter.string(from: Date()) + " " + text
    }
}
