//
//  AppDelegate.swift
//  QRScreenScanner
//
//  Created by Bondar Yaroslav on 7/23/19.
//  Copyright © 2019 Bondar Yaroslav. All rights reserved.
//

import Cocoa

final class MenuManager {
    
    static let shared = MenuManager()
    
    private let mainMenu = NSMenu(title: "MainMenu")
    
    func setupMenu() {
        addAppMenu()
        //testMenu()
        
        /// call
        NSApp.mainMenu = mainMenu
    }
    
    /// add App Menu first
    private func addAppMenu() {
        let appMenu = NSMenu(title: "App")
        
        appMenu.addItem(withTitle: "About",
                        action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
                        keyEquivalent: "a")
        
        appMenu.addItem(withTitle: "Quit",
                        action: #selector(NSApplication.terminate(_:)),
                        keyEquivalent: "q")
        
        mainMenu.addSubmenu(menu: appMenu)
    }
    
//    private func testMenu() {
//        let editMenu = mainMenu.createSubmenu(title: "Edit")
//        //editMenu.autoenablesItems = false
//
//        let aboutMenuItem = NSMenuItem(title: "About 1", action: #selector(about), keyEquivalent: "z")
//        aboutMenuItem.target = self
//        editMenu.addItem(aboutMenuItem)
//
//        editMenu.addItem(withTitle: "About 2", action: #selector(about), keyEquivalent: "x").target = self
//    }
//
//    @objc private func quit() {
//        NSApp.terminate(nil)
//    }
//
//    @objc private func about() {
//        NSApp.orderFrontStandardAboutPanel(self)
//    }
}

extension NSMenu {
    
    /// for title "Edit" will add emojy menuItem. it bcz of `addItem(withTitle: "Edit"`.
    /// setSubmenu must be called before `NSApp.mainMenu = mainMenu` to add emojy menuItem.
    func createSubmenu(title: String) -> NSMenu {
        let menu = NSMenu(title: title)
        let menuItem = addItem(withTitle: title, action: nil, keyEquivalent: "")
        setSubmenu(menu, for: menuItem)
        return menu
    }
    
    func addSubmenu(menu: NSMenu) {
        let menuItem = addItem(withTitle: menu.title, action: nil, keyEquivalent: "")
        setSubmenu(menu, for: menuItem)
    }
}

//private var statusItem: NSStatusItem?

final class App {
    
    static let shared = App()
    
    let statusManager = StatusManager()
    let menuManager = MenuManager()
    
    private lazy var window: NSWindow = {
        let window = NSWindow(contentViewController: ViewController())
        window.center()
        return window
    }()
    
    func start() {
        //        ScreenManager.disableHardwareMirroring()
        //        ScreenManager.allDisplayImages()
        //        ScreenManager.toggleMirroring()
        
        //        let window = ScreenManager.compositedWindow(for: "Google Chrome")
        //        let w = ScreenManager.compositedWindowsByName()
        //let e = ScreenManager.windowsByName()
        //ScreenManager.visibleWindowsImages()
        
        
        menuManager.setupMenu()
        statusManager.setupStatusItem()
        showWindow()
    }
    
    func showWindow() {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        /// to fix frame of closed window
        //        window.setFrame(NSRect(x: 0, y: 0, width: 400, height: 300), display: true)
        //        window.center()
        
        /// without reference it will be deinited
        //        self.mainWindowController = mainWindowController
    }
}

final class StatusManager {
    
    static let shared = StatusManager()
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    func setupStatusItem() {
//        statusItem = createStatusItem()
        guard let button = statusItem.button else {
            assertionFailure("system error. try statusItem.title")
            return
        }
        //button.image = NSImage(named: NSImage.Name("StatusBarButtonImage"))
        button.title = "QR"
        button.action = #selector(clickStatusItem)
        button.target = self
    }
    
    /// without storyboard can be create by lazy var + `_ = statusItem`.
    /// otherwise will be errors "0 is not a valid connection ID".
    /// https://habr.com/ru/post/447754/
//    func createStatusItem() -> NSStatusItem {
//        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
//
//        guard let button = statusItem.button else {
//            assertionFailure("system error. try statusItem.title")
//            return statusItem
//        }
//        //button.image = NSImage(named: NSImage.Name("StatusBarButtonImage"))
//        button.title = "QR"
//        button.action = #selector(clickStatusItem)
//        button.target = self
//        return statusItem
//    }
    
    @objc private func clickStatusItem() {
        
        //        self.screenImageView.image = NSImage(cgImage: img, size: .init(width: img.width, height: img.height))
        //
        //        window.makeKeyAndOrderFront(nil)
        /// addition if need
        //NSApp.activate(ignoringOtherApps: true)
        /// not work
        //window.orderBack(self)
        
        //let qrValues = ScreenManager.allDisplayImages2()
        let qrValues = ScreenManager.getHiddenWindowsImages()
            .flatMap { CodeDetector.shared.readQR(from: $0) }
        saveQRValues(qrValues)
        App.shared.showWindow()
    }
    
    private func saveQRValues(_ qrValues: [String]) {
        let qrDataSources = qrValues.map { qrValue -> HistoryDataSource in
            [TableColumns.date.rawValue: Date(),TableColumns.value.rawValue: qrValue]
        }
        let tableDataSource: [HistoryDataSource]
        if let tableDataSourceOld = UserDefaults.standard.array(forKey: "historyDataSource") as? [HistoryDataSource] {
            tableDataSource = tableDataSourceOld + qrDataSources
        } else {
            tableDataSource = qrDataSources
        }
        UserDefaults.standard.set(tableDataSource, forKey: "historyDataSource")
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        App.shared.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {}
    
    /// to open app after close button click we only hide it
    /// https://stackoverflow.com/a/43332520
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in sender.windows {
                window.makeKeyAndOrderFront(self)
            }
        }
        
        return true
    }
}
