//
//  ViewController.swift
//  MagnifyView
//
//  Created by Bondar Yaroslav on 6/6/19.
//  Copyright © 2019 Bondar Yaroslav. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    private lazy var magnifyView: MagnifyView = {
        /// use "MagnifyView(frame" or "frame.size" to setup size
        //magnifyView.frame.size = .init(width: 100, height: 100)
        let magnifyView = MagnifyView(frame: .init(x: 0, y: 0, width: 100, height: 100))
        
        magnifyView.layer.borderColor = UIColor.lightGray.cgColor
        magnifyView.layer.borderWidth = 3
        magnifyView.zoom = 4.0
        magnifyView.yOffset = 60
        magnifyView.viewToMagnify = view
        return magnifyView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLabel()
    }
    
    private func addLabel() {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.frame = view.bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.text = "some test. some test. some test. some test. some test. some test. some test. some test. some test. some test. some test. some test. some test. some test. some test. some test. some test. some test. some test. some test. some test. some test."
        view.addSubview(label)
    }
}

// MARK: - touches
/// can be used UIPanGestureRecognizer
extension ViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let point = touches.first?.location(in: self.view) else {
            assertionFailure()
            return
        }
        
        magnifyView.touchPoint = point
        view.window?.addSubview(magnifyView)
        //self.view.addSubview(magnifyView)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let point = touches.first?.location(in: self.view) else {
            assertionFailure()
            return
        }
        magnifyView.touchPoint = point
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        magnifyView.removeFromSuperview()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        magnifyView.removeFromSuperview()
    }
}


import UIKit

// TODO: frame edge cases
// TODO: create new logic to render one time and only move view
/// https://github.com/damidund/Magnifying-Glass-Effect
final class MagnifyView: UIView {
    
    var viewToMagnify: UIView?
    
    var touchPoint: CGPoint = .zero {
        didSet {
            center = CGPoint(x: touchPoint.x, y: touchPoint.y - yOffset)
            setNeedsDisplay()
        }
    }
    
    var zoom: CGFloat = 2
    var yOffset: CGFloat = 60
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialInit()
    }
    
    private func initialInit() {
        layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height * 0.5
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            assertionFailure()
            return
        }
        context.translateBy(x: 1 * frame.width * 0.5, y: 1 * frame.height * 0.5)
        context.scaleBy(x: zoom, y: zoom)
        context.translateBy(x: -1 * touchPoint.x, y: -1 * touchPoint.y)
        viewToMagnify?.layer.render(in: context)
    }
}
