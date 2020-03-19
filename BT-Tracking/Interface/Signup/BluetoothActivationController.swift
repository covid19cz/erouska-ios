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
            let advertiser = AppDelegate.delegate.advertiser
            advertiser.start()
            
            DispatchQueue.main.async {
                switch advertiser.authorization {
                case .allowedAlways:
                    self.performSegue(withIdentifier: "activation", sender: nil)
                default:
                    self.showError(title: "Povolení bluetooth", message: "Musíte povolit bluetooth, aby aplikace mohla fungovat.")
                }

                advertiser.stop()
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
