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

final class BluetoothActivationVC: UIViewController, CBPeripheralManagerDelegate {

    // MARK: -

    private let viewModel = BluetoothActivationVM()

    private var peripheralManager: CBPeripheralManager?

    private var checkAfterBecomeActive: Bool = false

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var enableButton: Button!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: scrollView)
        setupStrings()
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

private extension BluetoothActivationVC {

    func setupStrings() {
        navigationItem.localizedTitle(viewModel.title)
        navigationItem.backBarButtonItem?.localizedTitle(viewModel.back)
        navigationItem.rightBarButtonItem?.localizedTitle(viewModel.help)

        headlineLabel.localizedText(viewModel.headline)
        bodyLabel.localizedText(viewModel.body)
        enableButton.localizedTitle(viewModel.enableButton)
    }

    func continueOnboarding() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async { [weak self] in
                if settings.authorizationStatus == .notDetermined {
                    // Request authorization
                    self?.performSegue(withIdentifier: "notification", sender: nil)
                } else {
                    // Already authorized or denied
                    self?.performSegue(withIdentifier: "activation", sender: nil)
                }
                self?.peripheralManager = nil
            }
        }
    }
    
    func checkForBluetooth() {
        if viewModel.bluetoothNotDetermined {
            requestBluetoothPermission()
            return
        }

        if !viewModel.bluetoothAuthorized {
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
        showAlert(
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
