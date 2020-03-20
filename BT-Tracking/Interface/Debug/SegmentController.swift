//
//  SegmentController.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 16/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

class SegmentController: UIViewController {

    @IBOutlet private weak var segmentControl: UISegmentedControl!

    @IBOutlet private weak var leftContainerView: UIView!
    @IBOutlet private weak var rightContainerView: UIView!

    private weak var leftController: ServiceController!
    private weak var rightController: FileController!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let controller = segue.destination as? ServiceController {
            leftController = controller
        } else if let controller = segue.destination as? FileController {
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
        present(shareController, animated: true, completion: nil)
    }

    @IBAction private func purgeLogsAction(_ sender: Any) {
        let controller = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.pergeLogs()
        }))
        controller.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }

    private func pergeLogs() {
        FileLogger.shared.purgeLogs()

        leftController.purgeLog()
        rightController.purgeLog()
    }

}
