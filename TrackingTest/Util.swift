//
//  Util.swift
//  TrackingTest
//
//  Created by admin on 9/17/17.
//  Copyright © 2017 admin. All rights reserved.
//

import Foundation
import UIKit

// MARK: Helper Extensions
extension UIViewController {
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
