//
//  ActiveAppController.swift
//  BT-Tracking
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

final class ActiveAppController: UIViewController {

    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var activityView: UIView!

    private var writer: CSVMakering?

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        if AppDelegate.delegate.scanner.isRunning != true {
            AppDelegate.delegate.scanner.start()
        }

        if AppDelegate.delegate.advertiser.isRunning != true {
            AppDelegate.delegate.advertiser.start()
        }

        _ = AppDelegate.delegate.scannerStore
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        #if !targetEnvironment(simulator)
        checkForBluetooth()
        #endif
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

    @IBAction func sendReportAction() {
        let controller = UIAlertController(
            title: "Byli jste požádáni o odeslání seznamu telefonů, se kterými jste se setkali?",
            message: "Anonymní seznam obsahuje např.: UIDYXZ (19/3/2020/13:45/)",
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(title: "Ano, odeslat", style: .default, handler: { __SRD in
            self.sendReport()
        }))
        controller.addAction(UIAlertAction(title: "Ne", style: .cancel, handler: nil))
        controller.preferredAction = controller.actions.first
        present(controller, animated: true, completion: nil)
    }

    @IBAction func shareAppAction() {
        let url = URL(string: "https://covid19cz.page.link/share")!
        let shareContent = [url]
        let activityViewController = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = shareButton
        
        present(activityViewController, animated: true, completion: nil)
    }

    // MARK: -
    
    @objc private func applicationDidBecomeActive() {
        checkForBluetooth()
    }
    
    private func checkForBluetooth() {
        if !AppDelegate.delegate.advertiser.isRunning {
            performSegue(withIdentifier: "bluetoothDisabled", sender: nil)
        }
    }

    private func sendReport() {
        activityView.isHidden = false
        createCSVFile()
    }

    private func createCSVFile() {
        writer = CSVMaker()
        writer?.createFile(callback: { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                self.uploadCSVFile(fileURL: result.fileURL, metadata: result.metadata)
            } else if let error = error {
                self.show(error: error, title: "Nepodařilo se vytvořit soubor se setkánímy")
            }
        })
    }

    private func uploadCSVFile(fileURL: URL, metadata: [String: String]) {
        let path = "proximity/\(Auth.auth().currentUser?.uid ?? "")"
        let fileName = "\(Int(Date().timeIntervalSince1970 * 1000)).csv"

        let storage = Storage.storage()
        let storageReference = storage.reference()
        let fileReference = storageReference.child("\(path)/\(fileName)")
        let storageMetadata = StorageMetadata()
        storageMetadata.customMetadata = metadata

        fileReference.putFile(from: fileURL, metadata: storageMetadata) { (metadata, error) in
            if let error = error {
                self.show(error: error, title: "Nepodařilo se nahrát setkání")
                return
            }

            self.activityView.isHidden = true
            self.performSegue(withIdentifier: "sendReport", sender: nil)
        }
    }

}
