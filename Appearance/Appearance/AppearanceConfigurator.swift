//
//  AppearanceConfigurator.swift
//  Appearance
//
//  Created by Bondar Yaroslav on 31/01/2017.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import UIKit

struct Colors {
    private init() {}
    
    static let main = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
    static let text1 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
}

///appearance(whenContainedInInstancesOf: or appearanceForTraitCollection:whenContainedIn
// TODO: appearance(for: UITraitCollection)
class AppearanceConfigurator {
    
    class func configurate() {
        
        /// color of all buttons text (tintColor)
        /// can be overriden by doneButton.tintColor = UIColor.cyan
        /// or any other appearance()
        UIApplication.shared.delegate?.window??.tintColor = UIColor.magenta
        
        /// need View controller-based status bar appearance = NO in Info.plist
        UIApplication.shared.statusBarStyle = .lightContent
        
        configureNavigationBar()
        configureBarButtonItem()
        configureToolbar()
        configureButton()
        configureLabel()
        configureSearchBar()
    }
    
    class func configureSearchBar() {
        
        /// change the color of the text
        //UILabel.appearanceWhenContainedInInstancesOfClasses([UITextField.self]).textColor = UIColor.whiteColor()
        
        //        UISearchBar.appearance().searchBarStyle = UISearchBarStyle.minimal
        //        UISearchBar.appearance().scopeButtonTitles = nil
        
        /// cursor, buttons and others subviews color
        UISearchBar.appearance().tintColor = UIColor.yellow
        
        /// out of textField color
        UISearchBar.appearance().barTintColor = UIColor.black
        
        /// cursor only color
        //        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor.red
        
        /// textField backgroundColor. for UISearchBarStyle.prominent only
        //        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.blue
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).layer.backgroundColor = UIColor.blue.cgColor
        
        
        /// text color
        //        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor.blue
        // UISearchBar.appearance().textColor = UIColor.turquoise
        
        /// placeholder color
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).placeholderColor = UIColor.black
        
        /// search image color
        //        UISearchBar.appearance().searchImageColor = UIColor.turquoise
        
        /// clear button color
        //        UISearchBar.appearance().clearButtonColor = UIColor.turquoise
        
        UISearchBar.appearance().isRoundTextField = true
    }
    
    class func configureNavigationBar() {
        
        /// don't work if View controller-based status bar appearance = NO in Info.plist
        /// can be edited by:
        /// override func viewDidLoad() {
        ///     navigationController?.navigationBar.barStyle = .default
        /// }
        /// but it will change status bar color for all controller in that navigationController
        UINavigationBar.appearance().barStyle = .black
        
        /// back button
//        UINavigationBar.appearance().backIndicatorImage
//        UINavigationBar.appearance().backIndicatorTransitionMaskImage
        
        /// colors
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = Colors.main //bar's background
        UINavigationBar.appearance().tintColor = Colors.text1 //bar's buttons
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: Colors.text1
        ]
//
//        /// shadow line off.
//        /// need: UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }
    
    class func configureBarButtonItem() {
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.green
        
        /// don't work for UIBarButtonItem in navigation bar
        /// need UINavigationController and it's subclass
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [ViewController.self]).tintColor = UIColor.orange
    }
    
    class func configureToolbar() {
        UIToolbar.appearance().barTintColor = UINavigationBar.appearance().barTintColor
        UIToolbar.appearance().tintColor = UINavigationBar.appearance().tintColor
        UIToolbar.appearance().isTranslucent = false
    }
    
    class func configureButton() {
        /// don't work for font
        UIButton.appearance().titleLabel?.font = UIFont.systemFont(ofSize: 12)
    }
    
    class func configureLabel() {
        UILabel.appearance().textColor = UIColor.cyan
        UILabel.appearance().font = UIFont.systemFont(ofSize: 12)
    }
}
