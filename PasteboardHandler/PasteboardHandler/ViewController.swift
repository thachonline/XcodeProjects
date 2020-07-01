//
//  ViewController.swift
//  PasteboardHandler
//
//  Created by Bondar Yaroslav on 6/30/20.
//  Copyright © 2020 Bondar Yaroslav. All rights reserved.
//

import UIKit

/// iOS 14 UIPasteboard behavior https://habr.com/ru/company/kaspersky/blog/508784/
/// UIPasteboard returns nil in the background https://stackoverflow.com/a/54484675/5893286

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// to work timer in background
        UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            print(Date(), UIPasteboard.general.string ?? "nil")
        }
        
        /// seems like forking in app change only like: UIPasteboard.general.string = "1"
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changedNotification),
                                               name: UIPasteboard.changedNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changedNotification),
                                               name: UIPasteboard.removedNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc private func changedNotification() {
        print("- changedNotification")
        printPastboard()
    }
    
    @objc private func willEnterForeground() {
        
        /// called on first appear
        print("- applicationState", UIApplication.shared.applicationState.rawValue)
        
        /// called on not first appear
        if UIApplication.shared.applicationState == .background {
            print("- willEnterForeground", UIPasteboard.general.string ?? "nil")
        }
    }
    
    
    private func printPastboard() {
        print("- \(UIPasteboard.general.changeCount) | \(Date()) | \(UIPasteboard.general.string ?? "nil")")
    }
}

