//
//  ActiveAppController.swift
//  BT-Tracking
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit


class ActiveAppController: UIViewController {
    
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
    
    @IBOutlet private weak var shareButton: UIButton!

    @IBAction func shareApp() {
        let url = URL(string: "https://covid19cz.page.link/share")!
        let shareContent = [url]
        let activityViewController = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = shareButton
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc private func applicationDidBecomeActive() {
        checkForBluetooth()
    }
    
    private func checkForBluetooth() {
        if (UIApplication.shared.delegate as? AppDelegate)?.scanner.isRunning != true {
            performSegue(withIdentifier: "bluetoothDisabled", sender: nil)
        }
    }
}
