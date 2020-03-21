//
//  BluetoothActivationController.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 19/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothActivationController: UIViewController {

    private var peripheralManager: CBPeripheralManager?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @IBAction func activateBluetoothAction() {
        checkForBluetooth()
    }

    private func goToActivation() {
        performSegue(withIdentifier: "activation", sender: nil)
    }
    
    @objc private func applicationDidBecomeActive() {
        checkForBluetooth()
    }
    
    private func checkForBluetooth() {
        if bluetoothNotDetermined {
            requestBluetoothPermission()
            return
        }
        
        if !bluetoothAuthorized {
            showBluetoothPermissionError()
            return
        }
        
        goToActivation()
    }
    
    private var bluetoothNotDetermined: Bool {
        if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .notDetermined
        }
        return false
    }
    
    private var bluetoothAuthorized: Bool {
        if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .allowedAlways
        }
        return CBPeripheralManager.authorizationStatus() == .authorized
    }
    
    private func requestBluetoothPermission() {
        peripheralManager = CBPeripheralManager(
            delegate: self,
            queue: nil
        )
    }
    
    private func showBluetoothPermissionError() {
        showError(
            title: "Povolení bluetooth",
            message: "Musíte povolit bluetooth, aby aplikace mohla fungovat.",
            okHandler: { [weak self] in self?.showAppSettings() }
        )
    }
    
    private func showAppSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
}

extension BluetoothActivationController: CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if #available(iOS 13.0, *) {
            if peripheral.state == .poweredOn {
                goToActivation()
            } else {
                showBluetoothPermissionError()
            }
        } else {
            goToActivation()
        }
        peripheralManager = nil
    }

}
