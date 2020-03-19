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
    
    @IBAction func activateBluetoothAction(_ sender: Any) {
        if #available(iOS 13.0, *) {
            peripheralManager = CBPeripheralManager(
                delegate: self,
                queue: nil,
                options: [:]
            )
        } else {
            goToActivation()
        }
    }

    private func goToActivation() {
        performSegue(withIdentifier: "activation", sender: nil)
    }

}

extension BluetoothActivationController: CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if #available(iOS 13.0, *) {
            if peripheral.state == .poweredOn {
                goToActivation()
            } else {
                switch peripheral.authorization {
                case .allowedAlways:
                    self.goToActivation()
                default:
                    self.showError(title: "Povolení bluetooth", message: "Musíte povolit bluetooth, aby aplikace mohla fungovat.")
                }
            }
        } else {
            goToActivation()
        }
        peripheralManager = nil
    }

}
