//
//  UIApplication+URL.swift
//  EmailSender
//
//  Created by Bondar Yaroslav on 06/04/2017.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import UIKit

/// UIApplication.shared
extension UIApplication {
    
    /// open url method, that throws 'canOpenURL'
    func open(url: URL) throws {
        if canOpenURL(url) {
            openURL(url)
        }
    }
    
    /// universal open url method
    func open(scheme: String) {
        guard let url = URL(string: scheme) else {
            return print("scheme \(scheme) is invalid")
        }
        if #available(iOS 10, *) {
            open(url, options: [:])
        } else {
            openURL(url)
        }
    }
    
    /// "mailto:" will open Mail app with clear send window
    func openMailApp() {
        open(scheme: "message://")
    }
    
    /// can call to any number, even on "something"
    func call(phoneNumber: String) {
        open(scheme: "tel://\(phoneNumber)")
    }
    
    /// will open app settings if they are exists
    /// can be not exist if there is no anything to set (you didn't get any privacy)
    func openSettings() {
        open(scheme: UIApplicationOpenSettingsURLString)
    }
}
