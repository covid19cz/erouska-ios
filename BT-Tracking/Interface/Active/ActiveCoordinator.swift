//
//  ActiveCoordinator.swift
//  BT-Tracking
//
//  Created by Michal Šrůtek on 17/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let didUnregisterUser = Notification.Name("BT-Tracking-didUnregisterUser")
}

final class ActiveCoordinator: Coordinator {

    let navigationController: UINavigationController
    private let notificationCenter: NotificationCenter

    private let storyboard = UIStoryboard(name: "Active", bundle: nil)
    private let unregisterStoryboard = UIStoryboard(name: "UnregisterUser", bundle: nil)

    init(
        navigationController: UINavigationController = UINavigationController(),
        notificationCenter: NotificationCenter = .default
    ) {
        self.navigationController = navigationController
        self.notificationCenter = notificationCenter

        navigationController.navigationBar.prefersLargeTitles = true

        let viewController = storyboard.instantiateViewController(withIdentifier: "ActiveAppController") as! ActiveAppController
        viewController.delegate = self
        navigationController.viewControllers = [viewController]

        if #available(iOS 13, *) {
            viewController.tabBarItem = UITabBarItem(title: "eRouška", image: UIImage(systemName: "phone"), tag: 0)
        } else {
            viewController.tabBarItem = UITabBarItem(title: "eRouška", image: UIImage(named: "phone")?.resize(toWidth: 26), tag: 0)
        }
    }

    func start() {}
}

// MARK: - Show Screens

private extension ActiveCoordinator {
    func showUnregisterScreen() {
        let viewController = unregisterStoryboard.instantiateViewController(withIdentifier: "UnregisterUserVC") as! UnregisterUserVC
        viewController.delegate = self

        navigationController.pushViewController(viewController, animated: true)
    }

    func showUnregisterFinishScreen() {
        let viewController = unregisterStoryboard.instantiateViewController(withIdentifier: "UnregisterFinishVC") as! UnregisterFinishVC
        viewController.delegate = self

        navigationController.setViewControllers([viewController], animated: true)
    }

    func showHelpScreen() {
        navigationController.pushViewController(HelpVC(), animated: true)
    }
}

// MARK: - ActiveAppControllerDelegate

extension ActiveCoordinator: ActiveAppControllerDelegate {
    func controllerDidTapUnregister(_ controller: ActiveAppController) {
        showUnregisterScreen()
    }
}

// MARK: - UnregisterUserVCDelegate

extension ActiveCoordinator: UnregisterUserVCDelegate {
    func controllerDidTapHelp(_ controller: UnregisterUserVC) {
        showHelpScreen()
    }

    func controllerDidTapConfirm(_ controller: UnregisterUserVC) {
        controller.showProgress()

        AppDelegate.shared.functions.httpsCallable("deleteUser").call() { [weak self, weak controller] result, error in
            guard let self = self, let controller = controller else { return }
            controller.hideProgress()

            if let error = error as NSError? {
                Log.log("deleteUser request failed with error: \(error.localizedDescription), code: \(error.code)")
            }

            #if !PROD
            FileLogger.shared.purgeLogs()
            #endif
            Log.log("deleteUser deleting data")

            AppDelegate.shared.advertiser.stop()
            AppDelegate.shared.scanner.stop()
            AppDelegate.shared.scannerStore.deleteAllData()

            AppSettings.deleteAllData()

            self.showUnregisterFinishScreen()
        }
    }
}

// MARK: - UnregisterFinishVCDelegate

extension ActiveCoordinator: UnregisterFinishVCDelegate {
    func controllerDidTapClose(_ controller: UnregisterFinishVC) {
        notificationCenter.post(name: .didUnregisterUser, object: nil)
    }
}
