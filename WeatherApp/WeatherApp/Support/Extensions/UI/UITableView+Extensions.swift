//
//  UIColor+Adjust.swift
//  CustomViews
//
//  Created by Bondar Yaroslav on 08.02.17.
//  Copyright © 2016 Bondar Yaroslav. All rights reserved.
//

import UIKit

extension UITableView {

    func register <T: UITableViewCell>(nibCell identifier: T.Type) {
        let identifierString = String(describing: identifier)
        let nib = UINib(nibName: identifierString, bundle: nil)
        register(nib, forCellReuseIdentifier: identifierString)
    }

    func register <T: UITableViewHeaderFooterView>(nibHeaderFooter identifier: T.Type) {
        let identifierString = String(describing: identifier)
        let nib = UINib(nibName: identifierString, bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: identifierString)
    }

    /// Need to test
    func register <T: UITableViewCell>(class identifier: T.Type) {
        let identifierString = String(describing: identifier)
        register(T.self, forCellReuseIdentifier: identifierString)
    }
}


extension UITableView {
    
    /// use dequeueReusableCell for IndexPath bcz dequeueReusableCell withIdentifier can return nil
    func dequeue <T: UITableViewCell>(reusable identifier: T.Type) -> T {
        let identifierString = String(describing: identifier)
        return self.dequeueReusableCell(withIdentifier: identifierString) as! T
    }

    func dequeue <T: UITableViewCell>(reusable identifier: T.Type, for indexPath: IndexPath) -> T {
        let identifierString = String(describing: identifier)
        return self.dequeueReusableCell(withIdentifier: identifierString, for: indexPath) as! T
    }

    func dequeue <T: UITableViewHeaderFooterView>(reusableHeaderFooterView identifier: T.Type) -> T {
        let identifierString = String(describing: identifier)
        return self.dequeueReusableHeaderFooterView(withIdentifier: identifierString) as! T
    }
}
