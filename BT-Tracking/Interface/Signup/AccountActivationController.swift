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

          phoneNumberTextField.rx.text.orEmpty.bind(to: phoneNumber).disposed(by: disposeBag)

          isValid.bind(to: actionButton.rx.isEnabled).disposed(by: disposeBag)
    }

    @IBAction func activateAcountAction(_ sender: Any) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber.value, uiDelegate: nil) { [weak self] verificationID, error in
            if let error = error {
                let alertController = UIAlertController(
                    title: "Chyba při aktivaci",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(alertController, animated: true, completion: nil)
            } else {
                // done
            }
        }
    }

}
