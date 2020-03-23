//
//  ActiveAppController.swift
//  BT-Tracking
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit


class ActiveAppController: UIViewController {

    @IBOutlet private weak var shareButton: UIButton!

    @IBOutlet private weak var activityView: UIView!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        if AppDelegate.delegate.scanner.isRunning != true {
            AppDelegate.delegate.scanner.start()
        }

        if AppDelegate.delegate.advertiser.isRunning != true {
            AppDelegate.delegate.advertiser.start()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        checkForBluetooth()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    // MARK: - Actions

    @IBAction func sendReportAction() {
        let controller = UIAlertController(
            title: "Byli jste požádáni o odeslání seznamu telefonů, se kterými jste se setkali?",
            message: "Anonymní seznam obsahuje např.: UIDYXZ (19/3/2020/13:45/)",
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(title: "Ano, odeslat", style: .default, handler: { __SRD in
            self.sendReport()
        }))
        controller.addAction(UIAlertAction(title: "Ne", style: .cancel, handler: nil))
        controller.preferredAction = controller.actions.first
        present(controller, animated: true, completion: nil)
    }

    @IBAction func shareAppAction() {
        let url = URL(string: "https://covid19cz.page.link/share")!
        let shareContent = [url]
        let activityViewController = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = shareButton
        
        present(activityViewController, animated: true, completion: nil)
    }

    // MARK: -
    
    @objc private func applicationDidBecomeActive() {
        checkForBluetooth()
    }
    
    private func checkForBluetooth() {
        if !AppDelegate.delegate.advertiser.isRunning {
            performSegue(withIdentifier: "bluetoothDisabled", sender: nil)
        }
    }

    private func sendReport() {
        activityView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.activityView.isHidden = true
            self.performSegue(withIdentifier: "sendReport", sender: nil)
        }
    }

}
