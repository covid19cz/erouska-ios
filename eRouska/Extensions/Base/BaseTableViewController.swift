//
//  BaseTableViewController.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 19.02.2021.
//

import UIKit

class BaseTableViewController: UITableViewController {

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
