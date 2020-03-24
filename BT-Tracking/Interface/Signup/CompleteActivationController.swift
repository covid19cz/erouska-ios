//
//  CompleteActivation.swift
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
import DeviceKit

class CompleteActivationController: UIViewController {

    private var smsCode = BehaviorRelay<String>(value: "")
    private var isValid: Observable<Bool> {
        smsCode.asObservable().map { phoneNumber -> Bool in
            phoneNumber.count == 6
        }
    }
    private var disposeBag = DisposeBag()

    private lazy var functions = Functions.functions(region:"europe-west2")

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var smsCodeTextField: UITextField!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var activityView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        smsCodeTextField.rx.text.orEmpty.bind(to: smsCode).disposed(by: disposeBag)

        isValid.bind(to: actionButton.rx.isEnabled).disposed(by: disposeBag)

        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyboardVisibleHeight in
            guard let self = self else { return }

            self.view.setNeedsLayout()
            UIView.animate(withDuration: 0.1) {
                let adjsutHomeIndicator = keyboardVisibleHeight - self.view.safeAreaInsets.bottom
                self.scrollView.contentInset.bottom = adjsutHomeIndicator
                self.scrollView.scrollIndicatorInsets.bottom = adjsutHomeIndicator
                self.view.layoutIfNeeded()
            }
        }).disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        smsCodeTextField.becomeFirstResponder()
    }

    // MARK: - Actions

    @IBAction func activateAcountAction(_ sender: Any) {
        activityView.isHidden = false
        view.endEditing(true)
        
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") ?? ""
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: smsCode.value)

        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                self.activityView.isHidden = true
                self.show(error: error, title: "Chyba při aktivaci")
                self.cleanup()
            } else {
                var data: [String: Any] = [
                    "platform": "iOS",
                    "platformVersion": UIDevice.current.systemVersion,
                    "manufacturer": "Apple",
                    "model": Device.current.description,
                    "locale": "\(Locale.current.languageCode ?? "cs")_\(Locale.current.regionCode ?? "CZ")",
                ]

                if let token = AppDelegate.delegate.deviceToken {
                    data["pushRegistrationToken"] = token.hexEncodedString()
                }

                self.functions.httpsCallable("registerBuid").call(data) { [weak self] result, error in
                    guard let self = self else { return }
                    self.activityView.isHidden = true

                    if let error = error as NSError? {
                        self.show(error: error, title: "Chyba při aktivaci")
                        self.cleanup()
                        self.navigationController?.popViewController(animated: true)
                    } else if let result = result {
                        if let BUID = (result.data as? [String: Any])?["buid"] as? String {
                            UserDefaults.standard.set(BUID, forKey: "BUID")
                            self.performSegue(withIdentifier: "done", sender: nil)
                        } else {
                            self.show(error: NSError(domain: FunctionsErrorDomain, code: 500, userInfo: nil), title: "Chyba při aktivaci")
                            self.cleanup()
                        }
                    }

                }
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
