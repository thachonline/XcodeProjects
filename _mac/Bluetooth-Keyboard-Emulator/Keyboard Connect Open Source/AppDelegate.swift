//
//  AppDelegate.swift
//  Keyboard Connect Open Source
//
//  Created by Arthur Yidi on 4/11/16.
//  Copyright © 2016 Arthur Yidi. All rights reserved.
//

import AppKit
import Foundation
import IOBluetooth

final class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let permissionManager = PermissionManager()
    private var btKey: BTKeyboard?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        startOrAskPermissions()
    }
    
    private func startOrAskPermissions() {
        if permissionManager.isAccessibilityAvailableWithoutAlert() {
            start()
        } else {
            askPermissions()
            startOrAskPermissions()
        }
    }
    
    private func askPermissions() {
        let alert = NSAlert()
        let appName = "Keyboard Connect Open Source"
        alert.messageText = "Enable \(appName)"
        alert.informativeText = "Once you have enabled \"\(appName)\" in System Preferences, click OK."
        alert.addButton(withTitle: "Retry")
        alert.addButton(withTitle: "Open System Preference")
        alert.addButton(withTitle: "Quit")
        
        let result = alert.runModal()
//        let isQuitButtonPressed = (result == .alertSecondButtonReturn)
//
//        if isQuitButtonPressed {
//            NSApp.terminate(self)
//        }
        
        switch result {
        case .alertFirstButtonReturn:
            break
        case .alertSecondButtonReturn:
            openSecurityPane()
        case .alertThirdButtonReturn:
            NSApp.terminate(self)
        default:
            assertionFailure()
        }
    }
    
    /// https://macosxautomation.com/system-prefs-links.html
    /// https://stackoverflow.com/a/6658201
    func openSecurityPane() {
        let prefpaneUrl = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(prefpaneUrl)

        /// https://github.com/cho45/KeyCast/blob/master/KeyCast/Accessibility.swift
        // openURL 使うのが最も簡単だが、アクセシビリティの項目まで選択された状態で開くことができない
//        NSWorkspace.shared.open( NSURL.fileURL(withPath: "/System/Library/PreferencePanes/Security.prefPane") )
        
        // ScriptingBridge を使い、表示したいところまで自動で移動させる
        // open System Preference -> Security and Privacy -> Accessibility
//        let prefs = SBApplication.applicationWithBundleIdentifier("com.apple.systempreferences")! as! SBSystemPreferencesApplication
//        prefs.activate()
//        for pane_ in prefs.panes! {
//            let pane = pane_ as! SBSystemPreferencesPane
//            if pane.id == "com.apple.preference.security" {
//                for anchor_ in pane.anchors! {
//                    let anchor = anchor_ as! SBSystemPreferencesAnchor
//                    if anchor.name == "Privacy_Accessibility" {
//                        println(pane, anchor)
//                        anchor.reveal!()
//                        break
//                    }
//                }
//                break
//            }
//        }
    }
    
    let eventHandler = EventHandler()
    
    private func start() {
        btKey = BTKeyboard()
        eventHandler.delegate = self
        eventHandler.start()
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {

    }
    
//    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
//        print("ShouldTerminate")
//        return .terminateNow
//    }

    func applicationWillTerminate(aNotification: NSNotification) {
        print("WillTerminate")
        btKey?.terminate()
    }
    
}

extension AppDelegate: EventHandlerDelegate {
    func send(keyCode: UInt8, modifier: UInt8) {
        btKey?.sendKey(keyCode: keyCode, modifier: modifier)
    }
    
    func quite() {
        btKey?.terminate()
        NSApp.terminate(nil)
    }
}
