//
//  SetMenuSegue.swift
//  MenuDouble
//
//  Created by Bondar Yaroslav on 14/03/2017.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import UIKit

class SetMenuSegue: UIStoryboardSegue {
    override func perform() {
        
        guard let menuController = source as? MenuDoubleController else {
            fatalError("container is not MenuDoubleController subclass")
        }
        if identifier == "left" {
            menuController.leftVC = destination
            menuController.add(child: destination, to: menuController.leftContainer)
            
        } else if identifier == "right" {
            menuController.rightVC = destination
            menuController.add(child: destination, to: menuController.rightContainer)
            
        } else if identifier == "main" {
            menuController.mainVC = destination
            menuController.add(child: destination, to: menuController.mainContainer)
            
        } else {
            fatalError("segue identifier is not 'right' or 'left'")
        }
    }
}


import UIKit

class PushMenuSegue: UIStoryboardSegue {
    override func perform() {
        
        guard let menuController = source.parent as? MenuDoubleController else {
            fatalError("container is not MenuDoubleController subclass")
        }
        menuController.mainVC.removeFromContainer()
        menuController.mainVC = destination
        menuController.add(child: destination, to: menuController.mainContainer)
        menuController.openMain()
    }
}
