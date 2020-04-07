//
//  FirstActiovationController.swift
//  BT-Tracking
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import CoreBluetooth

final class FirstActiovationController: UIViewController {

    @IBAction private func continueAction() {
        if bluetoothAuthorized  {
            performSegue(withIdentifier: "notification", sender: nil)
        } else {
            performSegue(withIdentifier: "bluetooth", sender: nil)
        }
    }

    @IBAction private func auditsURLAction(_ sender: Any) {
        guard let url = URL(string: RemoteValues.proclamationLink) else { return }
        openURL(URL: url)
    }

    private var bluetoothAuthorized: Bool {
        if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .allowedAlways
        }
        return CBPeripheralManager.authorizationStatus() == .authorized
    }

}
