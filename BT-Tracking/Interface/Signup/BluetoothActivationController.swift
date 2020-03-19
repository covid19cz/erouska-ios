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
    
    @IBAction func activateBluetoothAction(_ sender: Any) {
        if #available(iOS 13.0, *) {
            let peripheralManager = CBPeripheralManager(
                delegate: self,
                queue: nil,
                options: [:]
            )

            switch peripheralManager.authorization {
            case .allowedAlways:
                performSegue(withIdentifier: "activation", sender: nil)
            default:
                let alertController = UIAlertController(
                    title: "Povolení bluetooth",
                    message: "Musíte povolit bluetooth, aby aplikace mohla fungovat.",
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
            }
        } else {
            performSegue(withIdentifier: "activation", sender: nil)
        }
    }

}

extension BluetoothActivationController: CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {

    }

}
