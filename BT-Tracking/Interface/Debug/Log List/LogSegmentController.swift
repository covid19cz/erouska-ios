//
//  LogSegmentController.swift
// eRouska
//
//  Created by Lukáš Foldýna on 16/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class LogSegmentController: UIViewController {

    @IBOutlet private weak var segmentControl: UISegmentedControl!

    @IBOutlet private weak var leftContainerView: UIView!
    @IBOutlet private weak var rightContainerView: UIView!

    private weak var leftController: LogController!
    private weak var rightController: FileLogController!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.tabBarItem.image = UIImage(systemName: "doc.plaintext")

        navigationItem.largeTitleDisplayMode = .never
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let controller = segue.destination as? LogController {
            leftController = controller
        } else if let controller = segue.destination as? FileLogController {
            rightController = controller
        }
    }

    // MARK: - Actions

    @IBAction private func changeContainerAction(_ sender: Any) {
        if leftContainerView.isHidden {
            rightContainerView.isHidden = true
            leftContainerView.isHidden = false
        } else {
            rightContainerView.isHidden = false
            leftContainerView.isHidden = true
        }
    }

    @IBAction func shareLogsAction(_ sender: Any) {
        let shareController = UIActivityViewController(activityItems: [FileLogger.shared.fileURL], applicationActivities: nil)
        present(shareController, animated: true)
    }

    @IBAction private func purgeLogsAction(_ sender: Any) {
        let controller = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.purgeLogs()
        }))
        controller.addAction(UIAlertAction(title: "No", style: .cancel))
        present(controller, animated: true)
    }

    @IBAction private func closeAction(_ sender: Any) {
        dismiss(animated: true)
    }

    private func purgeLogs() {
        FileLogger.shared.purgeLogs()

        leftController.purgeLog()
        rightController.purgeLog()
    }

}
