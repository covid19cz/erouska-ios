//
//  ActiveAppController.swift
//  BT-Tracking
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreBluetooth

final class ActiveAppController: UIViewController {

    private var viewModel = ActiveAppViewModel(bluetoothActive: true)
    private var lastBluetoothState: Bool = true // true enabled

    private let advertiser: BTAdvertising = AppDelegate.delegate.advertiser
    private let scanner: BTScannering = AppDelegate.delegate.scanner

    // MARK: - Outlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var actionButton: Button!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = AppDelegate.delegate.scannerStore // start scanner store

        checkForBluetooth()

        updateScanner()
        updateInterface()
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

    @IBAction private func shareAppAction() {
        let url = URL(string: "https://covid19cz.page.link/share")!
        let shareContent = [url]
        let activityViewController = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(activityViewController, animated: true, completion: nil)
    }

    @IBAction private func changeScanningAction() {
        switch viewModel.state {
        case .enabled:
            AppSettings.state = .paused
        case .paused:
            AppSettings.state = .enabled
        case .disabled:
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            return
        }
        updateViewModel()
    }

    // MARK: -
    
    @objc private func applicationDidBecomeActive() {
        checkForBluetooth()
    }

}

private extension ActiveAppController {

    func updateViewModel() {
        viewModel = ActiveAppViewModel(bluetoothActive: lastBluetoothState)

        updateScanner()
        updateInterface()
    }

    func updateScanner() {
        switch viewModel.state {
        case .enabled:
            if advertiser.isRunning != true {
                advertiser.start()
            }

            if scanner.isRunning != true {
                scanner.start()
            }
        case .disabled, .paused:
            if advertiser.isRunning == true {
                advertiser.stop()
            }

            if scanner.isRunning == true {
                scanner.stop()
            }
        }
    }

    func updateInterface() {
        imageView.image = viewModel.state.image
        headLabel.text = viewModel.state.head
        headLabel.textColor = viewModel.state.color
        titleLabel.text = viewModel.state.title
        textLabel.text = viewModel.state.text.replacingOccurrences(of: "%@", with: Auth.auth().currentUser?.phoneNumber ?? "")
        actionButton.style = viewModel.state.actionStyle
        actionButton.setTitle(viewModel.state.actionTitle, for: .normal)
    }

    func checkForBluetooth() {
        let state: Bool
        if #available(iOS 13.0, *) {
            state = AppDelegate.delegate.advertiser.authorization == .allowedAlways
        } else {
            state = CBPeripheralManager.authorizationStatus() == .authorized
        }
        guard lastBluetoothState != state else { return }
        lastBluetoothState = state
        updateViewModel()
    }

}
