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
import RxKeyboard
import FirebaseAuth
import FirebaseFunctions

class AccountActivationControler: UIViewController {

    private var phoneNumber = BehaviorRelay<String>(value: "")
    private var isValid: Observable<Bool> {
        phoneNumber.asObservable().map { phoneNumber -> Bool in
            phoneNumber.count > 8
        }
    }
    private var disposeBag = DisposeBag()

    private lazy var functions = Functions.functions(region:"europe-west2")

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var phoneNumberTextField: UITextField!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var activityView: UIView!

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

        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyboardVisibleHeight in
            guard let self = self else { return }

            self.view.setNeedsLayout()
            UIView.animate(withDuration: 0.1) {
                self.scrollView.contentInset.bottom = keyboardVisibleHeight
                self.scrollView.scrollIndicatorInsets.bottom = keyboardVisibleHeight
                self.view.layoutIfNeeded()
            }
        }).disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        phoneNumberTextField.becomeFirstResponder()
    }

    // MARK: - Actions

    @IBAction func activateAcountAction(_ sender: Any) {
        activityView.isHidden = false

        PhoneAuthProvider.provider().verifyPhoneNumber("+420" + phoneNumber.value, uiDelegate: nil) { [weak self] verificationID, error in
            guard let self = self else { return }
            self.activityView.isHidden = true

            if let error = error {
                self.show(error: error, title: "Chyba při aktivaci")
                self.cleanup()
            } else if let verificationID = verificationID  {
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                self.performSegue(withIdentifier: "verification", sender: nil)
            }
        }
    }
    private func cleanup() {
        do {
            try Auth.auth().signOut()
        } catch {

        }

        UserDefaults.resetStandardUserDefaults()
    }

}
