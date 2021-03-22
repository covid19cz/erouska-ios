//
//  BaseController.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 18.02.2021.
//

import UIKit

class BaseController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        if let dependentController = self as? CanInjectDependencies {
            dependentController.injectDependencies()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let dependentController = self as? CanInjectDependencies {
            dependentController.injectDependencies()
        }
    }

}
