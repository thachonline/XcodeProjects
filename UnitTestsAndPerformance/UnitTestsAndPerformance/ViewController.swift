//
//  ViewController.swift
//  UnitTestsAndPerformance
//
//  Created by Yaroslav Bondar on 23/07/2019.
//  Copyright © 2019 Yaroslav Bondar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var isRetained = false
    var handler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isRetained {
            //handler = someFunc
            handler = {
                print("- handler", self)
            }
        } else {
            handler = { [weak self] in
                guard let self = self else {
                    return
                }
                print("- handler", self)
            }
        }
        
        handler?()
    }
    
    func someFunc() {
        print("- handler", self)
    }
}
