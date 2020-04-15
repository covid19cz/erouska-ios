//
//  BluetoothActivationController.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 19/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import CoreBluetooth
import UserNotifications

final class BluetoothActivationController: UIViewController, CBPeripheralManagerDelegate {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    
    private var peripheralManager: CBPeripheralManager?

    private var bluetoothNotDetermined: Bool {
        if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .notDetermined
        }
        return CBPeripheralManager.authorizationStatus() == .notDetermined
    }

    private var bluetoothAuthorized: Bool {
        if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .allowedAlways
        }
        return CBPeripheralManager.authorizationStatus() == .authorized
    }

    private var checkAfterBecomeActive: Bool = false

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: scrollView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard checkAfterBecomeActive else { return }
        activateBluetoothAction()
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
    
    @IBAction private func activateBluetoothAction() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        checkForBluetooth()
    }

    @objc private func applicationDidBecomeActive() {
        checkForBluetooth()
    }

    // MARK: - CBPeripheralManagerDelegate

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {

    }

}

private extension BluetoothActivationController {

    func continueOnboarding() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async { [weak self] in
                if settings.authorizationStatus == .authorized {
                    // Already authorized
                    self?.performSegue(withIdentifier: "activation", sender: nil)
                } else {
                    // Request authorization
                    self?.performSegue(withIdentifier: "notification", sender: nil)
                }
                self?.peripheralManager = nil
            }
        }
    }
    
    func checkForBluetooth() {
        if bluetoothNotDetermined {
            requestBluetoothPermission()
            return
        }

        if !bluetoothAuthorized {
            showBluetoothPermissionError()
            return
        }

        continueOnboarding()
    }

    func requestBluetoothPermission() {
        peripheralManager = CBPeripheralManager(
            delegate: self,
            queue: nil,
            options: [
                CBPeripheralManagerOptionShowPowerAlertKey: false,
            ]
        )
    }

    func showBluetoothPermissionError() {
        showError(
            title: "Zapněte Bluetooth",
            message: "Bez zapnutého Bluetooth nemůžeme vytvářet seznam telefonů ve vašem okolí.",
            okHandler: { [weak self] in self?.showAppSettings() }
        )
    }

    func showAppSettings() {
        checkAfterBecomeActive = true
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }

}
