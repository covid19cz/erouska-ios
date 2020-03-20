//
//  ActiveAppController.swift
//  BT-Tracking
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit


class ActiveAppController: UIViewController {
    
    @IBOutlet private weak var shareButton: UIButton!

    @IBAction func shareApp() {
        let url = URL(string: "https://www.google.com")
        let shareContent = [url]
        let activityViewController = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = shareButton
        
        present(activityViewController, animated: true, completion: nil)
    }
}
