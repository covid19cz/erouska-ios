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
import CoreLocation

class AccountActivationControler: UIViewController {

    struct AuthData {
        let verificationID: String
        let phoneNumber: String
    }

    enum PhoneValidator {
        case prefix, number, smsCode

        var charcterSet: CharacterSet {
            switch self {
            case .prefix:
                return CharacterSet(charactersIn: "+0123456789")
            case .number, .smsCode:
                return CharacterSet(charactersIn: "0123456789")
            }
        }

        var rangeLimit: ClosedRange<Int> {
            switch self {
            case .prefix:
                return 2...5
            case .number:
                return 9...10
            case .smsCode:
                return 6...6
            }
        }

        func validate(_ text: String) -> Bool {
            guard rangeLimit.contains(text.count) else { return false }

            let set = charcterSet.inverted
            let filtered = text.components(separatedBy: set).joined()
            return filtered == text
        }
    }

    private var phonePrefix = BehaviorRelay<String>(value: "")
    private var phoneNumber = BehaviorRelay<String>(value: "")
    private var isValid: Observable<Bool> {
        Observable.combineLatest(phonePrefix.asObservable(), phoneNumber.asObservable()).map { (phonePrefix, phoneNumber) -> Bool in
            return PhoneValidator.prefix.validate(phonePrefix) && PhoneValidator.number.validate(phoneNumber)
        }
    }
    private var disposeBag = DisposeBag()
    private var confirmedPrivacy: Bool = false
    private let locationManager = CLLocationManager()

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var phonePrefixTextField: UITextField!
    @IBOutlet private weak var phoneNumberTextField: UITextField!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var activityView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: {_, _ in }
        )
        UIApplication.shared.registerForRemoteNotifications()

        locationManager.requestAlwaysAuthorization()

        phonePrefixTextField.rx.text.orEmpty.bind(to: phonePrefix).disposed(by: disposeBag)
        phoneNumberTextField.rx.text.orEmpty.bind(to: phoneNumber).disposed(by: disposeBag)

        isValid.bind(to: actionButton.rx.isEnabled).disposed(by: disposeBag)

        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyboardVisibleHeight in
            guard let self = self else { return }

            self.view.setNeedsLayout()
            UIView.animate(withDuration: 0.1) {
                let adjsutHomeIndicator = keyboardVisibleHeight - self.view.safeAreaInsets.bottom
                self.scrollView.contentInset.bottom = adjsutHomeIndicator
                self.scrollView.scrollIndicatorInsets.bottom = adjsutHomeIndicator
                self.view.layoutIfNeeded()

                DispatchQueue.main.async {
                    let height = (self.scrollView.frame.height - adjsutHomeIndicator)
                    let contentSize = self.scrollView.contentSize
                    self.scrollView.scrollRectToVisible(CGRect(x: 0, y: contentSize.height - height, width: contentSize.width, height: height), animated: true)
                }
            }
        }).disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        phoneNumberTextField.becomeFirstResponder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let destination = segue.destination as? CompleteActivationController,
            let authData = sender as? AuthData else { return }
        destination.authData = authData
    }

    // MARK: - Actions

    @IBAction func activateAcountAction(_ sender: Any) {
        guard !confirmedPrivacy else {
            activate()
            return
        }

        showError(
            title: "Pokračováním v aktivaci souhlasíte, aby Ministerstvo zdravotnictví pracovalo s telefonním číslem a údaji o setkání s jinými uživateli aplikace podle podmínek zpracování za účelem epidemiologického šetření.",
            message: "Souhlas můžete  odvolat a pokud nesouhlasíte, nepokračujte v aktivaci.",
            okTitle: "Ano, souhlasím",
            okHandler: { [weak self] in
                self?.confirmedPrivacy = true
                self?.activate()
            },
            action: (title: "Ne, nesouhlasím", handler: nil)
        )
    }

    private func activate() {
        activityView.isHidden = false
        view.endEditing(true)

        let phone = phonePrefix.value + phoneNumber.value
        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { [weak self] verificationID, error in
            guard let self = self else { return }
            self.activityView.isHidden = true

            if let error = error {
                self.show(error: error, title: "Chyba při aktivaci")
                self.cleanup()
            } else if let verificationID = verificationID  {
                self.performSegue(withIdentifier: "verification", sender: AuthData(verificationID: verificationID, phoneNumber: phone))
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
