//
//  YearsView.swift
//  ScrollBar
//
//  Created by Bondar Yaroslav on 10/4/18.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import UIKit

final class YearsView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        autoresizingMask = [.flexibleHeight]
        backgroundColor = UIColor.lightGray
    }
    
    weak var view: UIView!
    
    private var labels = [UILabel]()
    
    func update(by dates: [Date]) {
        
        var years: [Int: (months: Set<Int>, lines: Int)] = [:]
        
        for item in dates {
            
            let componets = Calendar.current.dateComponents([.year, .month], from: item)
            
            guard let year = componets.year, let month = componets.month else {
                assertionFailure()
                return
            }
            
            if years[year] == nil {
                years[year] = (Set([month]), 1)
            } else {
                years[year]!.lines += 1
                years[year]!.months.insert(month)
            }
        }
        
        let yearsArray = years.sorted { year1, year2 in
            year1.key < year2.key
        }
        
        
        print("allItems count:", dates.count)
        print(yearsArray)
        print()
        
        
        
        
        
        
        if yearsArray.isEmpty {
            assertionFailure()
            return
        }
        
        guard let view = view else {
            assertionFailure()
            return
        }
        
        var labelsOffes: [CGFloat] = [0]
        
        for year in yearsArray.dropLast() {
            let yearContentRatio = CGFloat(year.value.lines) / CGFloat(dates.count)
            let yearHeight = yearContentRatio * view.frame.height
            labelsOffes.append(yearHeight)
        }
        
        print("view.frame.height:", view.frame.height)
        print("labelsOffes:", labelsOffes)
        print()
        
        
        
        
        labels.forEach { $0.removeFromSuperview() }
        labels = []
        
        for offet in labelsOffes {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: offet, width: 50, height: 30)
            label.backgroundColor = .red
            
            addSubview(label)
            labels.append(label)
        }
        
        //        labels.forEach { addSubview($0) }
    }
    
    func add(to view: UIView) {
        self.view = view
        updateFrame(by: view.frame)
        view.addSubview(self)
    }
    
    let width: CGFloat = 100
    func updateFrame(by newFrame: CGRect) {
        frame = CGRect(x: newFrame.width - width, y: 0, width: width, height: newFrame.height)
    }
}
