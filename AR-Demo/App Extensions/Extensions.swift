//
//  Extensions.swift
//  AR-Demo
//
//  Created by Vivek iLeaf on 10/24/17.
//  Copyright © 2017 Vivek iLeaf. All rights reserved.
//

import Foundation
import UIKit


extension Int
{
    
    var degreesToRadians: Double { return Double(self) * .pi/180}
}

extension UserDefaults {
    func bool(for setting: Setting) -> Bool
    {
        return bool(forKey: setting.rawValue)
    }
    func set(_ bool: Bool, for setting: Setting) {
        set(bool, forKey: setting.rawValue)
    }
}
extension UIViewController
{
     func showAlertViewDismissAutomatically(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.async { () -> Void in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) { () -> Void in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
