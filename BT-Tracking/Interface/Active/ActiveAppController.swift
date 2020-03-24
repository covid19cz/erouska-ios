//
//  ActiveAppController.swift
//  BT-Tracking
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import FirebaseAuth

final class ActiveAppController: UIViewController {

    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var disableBluetoothView: UIView!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        if AppDelegate.delegate.scanner.isRunning != true {
            AppDelegate.delegate.scanner.start()
        }

        if AppDelegate.delegate.advertiser.isRunning != true {
            AppDelegate.delegate.advertiser.start()
        }

        _ = AppDelegate.delegate.scannerStore
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        #if !targetEnvironment(simulator)
        checkForBluetooth()
        #endif
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

    @IBAction func shareAppAction() {
        let url = URL(string: "https://covid19cz.page.link/share")!
        let shareContent = [url]
        let activityViewController = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = shareButton
        
        present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func changeScanningAction() {
        showError(title: "TODO", message: "")
    }

    // MARK: -
    
    @objc private func applicationDidBecomeActive() {
        checkForBluetooth()
    }
    
    private func checkForBluetooth() {
        disableBluetoothView.isHidden = AppDelegate.delegate.advertiser.isRunning
    }

}
