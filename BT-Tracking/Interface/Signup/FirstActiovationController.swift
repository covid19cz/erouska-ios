//
//  FirstActiovationController.swift
//  BT-Tracking
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import CoreBluetooth

class FirstActiovationController: UIViewController {

    @IBAction func continueAction(_ sender: UIButton) {
        if isBluetoothAuthorized {
            performSegue(withIdentifier: "activation", sender: nil)
        } else {
            performSegue(withIdentifier: "bluetooth", sender: nil)
        }
    }
    
    private var isBluetoothAuthorized: Bool {
        if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .allowedAlways
        }
        return CBPeripheralManager.authorizationStatus() == .authorized
    }
}
