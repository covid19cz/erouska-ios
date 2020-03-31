//
//  FirstActiovationController.swift
//  BT-Tracking
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import CoreBluetooth
import SafariServices

final class FirstActiovationController: UIViewController {

    @IBAction private func continueAction() {
        if bluetoothAuthorized  {
            performSegue(withIdentifier: "activation", sender: nil)
        } else {
            performSegue(withIdentifier: "bluetooth", sender: nil)
        }
    }

    @IBAction private func auditsURLAction(_ sender: Any) {
        let controller = SFSafariViewController(url: URL(string: "https://www.erouska.cz")!)
        present(controller, animated: true, completion: nil)
    }

    private var bluetoothAuthorized: Bool {
        if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .allowedAlways
        }
        return CBPeripheralManager.authorizationStatus() == .authorized
    }

}
