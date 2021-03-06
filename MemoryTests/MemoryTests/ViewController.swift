//
//  ViewController.swift
//  MemoryTests
//
//  Created by Bondar Yaroslav on 13/04/2018.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import UIKit



class ViewController: UIViewController {

    deinit {
        print("- deinit ViewController")
    }
    
    lazy var service = Service()
    lazy var service2 = Service2()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        test2()
//        testAutoreleasepool()
    }
    
    
    
    func test1() {
        service.getSome {
            print("getSome 1")
            self.view.backgroundColor = .red
        }

    }
    
    func test2() {
        service.getSome { [weak self] in
            print("getSome 1")
            guard let `self` = self else {
                return
            }
            self.view.backgroundColor = .red
        }

    }
    
    func test3() {
        Service().getSome {
            print("getSome 2")
            self.view.backgroundColor = .blue
        }

    }
    
    func test4() {
        Service().getSome { [weak self] in
            print("getSome 2")
            guard let `self` = self else {
                return
            }
            self.view.backgroundColor = .blue
        }

    }
    
    func test5() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {  [weak self] in
            print("global 3")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {// [weak self] in
                print("main 3")
                guard let `self` = self else {
                    return
                }
                self.view.backgroundColor = .blue
            }
        }

    }
    
    func test6() {
        service.getSome { [weak self] in
            print("getSome 1")
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 3) {//  [weak self] in
                print("global 3")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {// [weak self] in
                    print("main 3")
                    guard let `self` = self else {
                        return
                    }
                    self.view.backgroundColor = .blue
                }
            }
        }
    }
    
    func test7() {
        service2.getSome { [weak self] in
            print("getSome 2")
            guard let `self` = self else {
                return
            }
            self.view.backgroundColor = .red
        }
        
    }
    
    
    func testAutoreleasepool() {
        while true {
//            autoreleasepool {
                DispatchQueue.global().async {
                    let q = "qweqweqwe q qe qwe q цй йцу qwqweqweqwe q qe qwe q цй йцу qwqweqweqwe q qe qwe q цй йцу qwqweqweqwe q qe qwe q цй йцу qwqweqweqwe q qe qwe q цй йцу qwqweqweqwe q qe qwe q цй йцу qwqweqweqwe q qe qwe q цй йцу qwqweqweqwe q qe qwe q цй йцу qwqweqweqwe q qe qwe q цй йцу qw"
                    let _ = [q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, q, ]
                }
//            }
        }
        
    }
}

typealias VoidHandler = () -> Void

class Service {
    
    deinit {
        print("- deinit Service")
    }
    
    func getSome(handler: @escaping VoidHandler) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            DispatchQueue.main.async {
                handler()
            }
        }
    }
}

class Service2 {
    
    deinit {
        print("- deinit Service2")
    }
    
    var handler: VoidHandler?
    
    func getSome(handler: @escaping VoidHandler) {
        self.handler = handler
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) { [weak self] in
            DispatchQueue.main.async {
                self?.handler?()
            }
        }
    }
}
