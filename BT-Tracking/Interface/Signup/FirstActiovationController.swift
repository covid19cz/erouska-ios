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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func continueAction(_ sender: UIButton) {
        if bluetoothAuthorized  {
            performSegue(withIdentifier: "activation", sender: nil)
        } else {
            performSegue(withIdentifier: "bluetooth", sender: nil)
        }
    }
    
    private var bluetoothAuthorized: Bool {
        if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .allowedAlways
        }
        return CBPeripheralManager.authorizationStatus() == .authorized
    }
}
