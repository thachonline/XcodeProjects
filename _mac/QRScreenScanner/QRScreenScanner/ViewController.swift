//
//  ViewController.swift
//  QRScreenScanner
//
//  Created by Bondar Yaroslav on 7/23/19.
//  Copyright © 2019 Bondar Yaroslav. All rights reserved.
//

import Cocoa

typealias HistoryDataSource = [String: Any]

enum TableColumns: String {
    case date
    case value
    
    var title: String {
        switch self {
        case .date:
            return " Date"
        case .value:
            return " Value"
        }
    }
}

class ViewController: NSViewController {
    
    private var tableDataSource = [HistoryDataSource]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadDataSource()
        
        UserDefaults.standard.addObserver(self, forKeyPath: "historyDataSource", options: .new, context: nil)
        
        addTableView()
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: "historyDataSource")
    }
    
    private func reloadDataSource() {
        if let tableDataSource = UserDefaults.standard.array(forKey: "historyDataSource") as? [HistoryDataSource] {
            self.tableDataSource = tableDataSource
        }
        tableView.reloadData()
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "historyDataSource":
            reloadDataSource()
        default:
            assertionFailure()
        }
    }
    
    private let tableView = NSTableView()
    
    private func addTableView() {
        /// https://stackoverflow.com/a/27747282/5893286
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        
        let column1 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: TableColumns.date.rawValue))
        column1.width = 100
        column1.title = TableColumns.date.title
        tableView.addTableColumn(column1)
        
        let column2 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: TableColumns.value.rawValue))
        column2.width = view.frame.width - 100
        column2.title = TableColumns.value.title
        tableView.addTableColumn(column2)
        
        /// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/TableView/SortingTableViews/SortingTableViews.html
        let dateSortDescriptor = NSSortDescriptor(key: TableColumns.date.rawValue, ascending: false)
        let valueSortDescriptor = NSSortDescriptor(key: TableColumns.value.rawValue, ascending: true)
        tableView.sortDescriptors = [dateSortDescriptor, valueSortDescriptor]
        column1.sortDescriptorPrototype = dateSortDescriptor
        column2.sortDescriptorPrototype = valueSortDescriptor
        
        let tableContainer = NSScrollView(frame: view.bounds)
        tableContainer.autoresizingMask = [.width, .height]
        tableContainer.documentView = tableView
        tableContainer.hasVerticalScroller = true
        view.addSubview(tableContainer)
    }
    
    

//    @IBAction private  func captureScreen(_ sender: NSButton) {
//        let window = view.window!
//
//        window.orderOut(self)
//        //window.close()
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//
//            guard let img = CGDisplayCreateImage(CGMainDisplayID()) else {
//                assertionFailure()
//                return
//            }
//
//
//            self.screenImageView.image = NSImage(cgImage: img, size: .init(width: img.width, height: img.height))
//
//            window.makeKeyAndOrderFront(nil)
//            /// addition if need
//            //NSApp.activate(ignoringOtherApps: true)
//            /// not work
//            //window.orderBack(self)
//
//            print(
//                CodeDetector.shared.readQR(from: img)
//            )
//        }
//
//
//
//    }
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableDataSource.count
    }
    
    /// NSTableView set content Mode
    /// https://stackoverflow.com/q/19218807/5893286
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard
            let columnIdentifier = tableColumn?.identifier.rawValue,
            let columnType = TableColumns(rawValue: columnIdentifier)
        else {
            assertionFailure(tableColumn?.identifier.rawValue ?? "tableColumn nil")
            return nil
        }
        
        switch columnType {
            
        case .date:
            guard let date = tableDataSource[row][TableColumns.date.rawValue] as? Date else {
                assertionFailure()
                return nil
            }
            
            return dateFormatter.string(from: date)
        case .value:
            return tableDataSource[row][TableColumns.value.rawValue]
        }
    }
    
    //    func tableView(_ tableView: NSTableView, dataCellFor tableColumn: NSTableColumn?, row: Int) -> NSCell? {
    //        <#code#>
    //    }
    
    //    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    //        return nil
    //    }
}

extension ViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        tableDataSource.sort(sortDescriptors: tableView.sortDescriptors)
        tableView.reloadData()
    }
}

/// https://stackoverflow.com/a/42313342/5893286
extension MutableCollection where Self : RandomAccessCollection {
    /// Sort `self` in-place using criteria stored in a NSSortDescriptors array
    public mutating func sort(sortDescriptors theSortDescs: [NSSortDescriptor]) {
        sort { by:
            for sortDesc in theSortDescs {
                switch sortDesc.compare($0, to: $1) {
                case .orderedAscending: return true
                case .orderedDescending: return false
                case .orderedSame: continue
                }
            }
            return false
        }
    }
}

final class CodeDetector {
    
    static let shared = CodeDetector()
    
    /// native
    func readQR(from image: NSImage) -> [String] {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            assertionFailure("cgImage convert problem")
            return []
        }
        return readQR(from: cgImage)
    }
    
    func readQR(from image: CGImage) -> [String] {
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                     context: nil,
                                     options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        else {
            assertionFailure("nil in simulator, A7 core +")
            return []
        }
        
        let ciImage = CIImage(cgImage: image)
        
        guard let features = detector.features(in: ciImage) as? [CIQRCodeFeature] else {
            assertionFailure("CIDetector(ofType is different")
            return []
        }
        
        return features.compactMap({$0.messageString})
    }
}
