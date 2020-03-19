//
//  AccountActivationController.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 19/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import FirebaseAuth

class AccountActivationControler: UIViewController {

    private var phoneNumber = BehaviorRelay<String>(value: "")
    private var isValid: Observable<Bool> {
        phoneNumber.asObservable().map { phoneNumber -> Bool in
            phoneNumber.count > 8
        }
    }
    private var disposeBag = DisposeBag()

    @IBOutlet private var phoneNumberTextField: UITextField!
    @IBOutlet private var actionButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in

        }

        let generalCategory = UNNotificationCategory(
            identifier: "Scanning",
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([generalCategory])

        phoneNumberTextField.rx.text.orEmpty.bind(to: phoneNumber).disposed(by: disposeBag)

        isValid.bind(to: actionButton.rx.isEnabled).disposed(by: disposeBag)
    }

    @IBAction func activateAcountAction(_ sender: Any) {
        #if DEBUG
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        #endif

        PhoneAuthProvider.provider().verifyPhoneNumber("+420" + phoneNumber.value, uiDelegate: nil) { [weak self] verificationID, error in
            if let error = error {
                self?.show(error: error, title: "Chyba při aktivaci")
            } else if let verificationID = verificationID  {
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: "123456")
                self?.signIn(with: credential)
            }
        }
    }

    private func signIn(with credential: PhoneAuthCredential) {
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            if let error = error {
                self?.show(error: error, title: "Chyba při aktivaci")
            } else {
                self?.performSegue(withIdentifier: "done", sender: nil)
            }
        }
    }

}
